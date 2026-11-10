import 'dotenv/config';
import express from 'express';
import http from 'http';
import cors from 'cors';
import dotenv from 'dotenv';
import { Server as SocketIOServer } from 'socket.io';
import { prisma } from './lib/prisma.js';
import { authRouter } from './routes/auth.routes.js';
import { profileRouter } from './routes/profile.routes.js';
import { creatorRouter } from './routes/creator.routes.js';
import { walletRouter } from './routes/wallet.routes.js';
import { callRouter } from './routes/call.routes.js';
import { adminRouter } from './routes/admin.routes.js';
import { uploadRouter } from './routes/upload.routes.js';
import path from 'path';
import { chatRouter } from './routes/chat.routes.js';
import { callBillingManager } from './services/call-billing.manager.js';

dotenv.config();

const app = express();
const server = http.createServer(app);

// WebSockets Server
export const io = new SocketIOServer(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Serve uploaded media files publicly
app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));

// API Routes
app.use('/api/v1/upload', uploadRouter);
app.use('/api/v1/auth', authRouter);
app.use('/api/v1/profile', profileRouter);
app.use('/api/v1/creators', creatorRouter);
app.use('/api/v1/wallet', walletRouter);
app.use('/api/v1/calls', callRouter);
app.use('/api/v1/chat', chatRouter);
app.use('/api/v1/admin', adminRouter);

// Health Check
app.get('/health', async (_req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.json({
      status: 'UP',
      database: 'Connected to PostgreSQL (linkup_db)',
      timestamp: new Date().toISOString(),
    });
  } catch (error: any) {
    res.status(500).json({
      status: 'ERROR',
      database: 'Failed to connect to PostgreSQL',
      error: error.message,
    });
  }
});

// Basic Root
app.get('/', (_req, res) => {
  res.json({
    app: 'LinkUp Backend API Engine',
    version: '1.0.0',
    documentation: '/docs',
    health: '/health',
    endpoints: [
      '/api/v1/auth',
      '/api/v1/profile',
      '/api/v1/creators',
      '/api/v1/wallet',
      '/api/v1/calls',
      '/api/v1/chat',
      '/api/v1/admin',
    ],
  });
});

// Buffered WebRTC signaling store per active call so delayed joiners never miss Offer/Answer/ICE
interface CallSignalState {
  offer?: { callId: string; sdp: any; fromSocketId: string };
  answer?: { callId: string; sdp: any; fromSocketId: string };
  callerCandidates: Array<{ callId: string; candidate: any }>;
  receiverCandidates: Array<{ callId: string; candidate: any }>;
  updatedAt: number;
}
const callSignals = new Map<string, CallSignalState>();

function getOrCreateCallSignal(callId: string): CallSignalState {
  const now = Date.now();
  if (callSignals.size > 100) {
    for (const [k, v] of callSignals.entries()) {
      if (now - v.updatedAt > 30 * 60 * 1000) callSignals.delete(k);
    }
  }
  let state = callSignals.get(callId);
  if (!state) {
    state = { callerCandidates: [], receiverCandidates: [], updatedAt: now };
    callSignals.set(callId, state);
  }
  state.updatedAt = now;
  return state;
}

// Sockets Connection Handler
io.on('connection', (socket) => {
  console.log(`[Socket Connected]: ${socket.id}`);

  // Join User Private Room
  socket.on('user:join', (userId: string) => {
    socket.join(`user_${userId}`);
    console.log(`[Socket] User ${userId} joined room user_${userId}`);
  });

  // Join Call Room (for live call events & billing ticks & WebRTC)
  socket.on('call:join', (payload: string | { callId: string; isCaller?: boolean }) => {
    const callId = typeof payload === 'string' ? payload : payload?.callId;
    const isCaller = typeof payload === 'object' ? payload?.isCaller : undefined;
    if (!callId) return;

    socket.join(`call_${callId}`);
    const room = io.sockets.adapter.rooms.get(`call_${callId}`);
    const count = room ? room.size : 1;
    console.log(`[Socket] ${socket.id} joined call room call_${callId} (isCaller=${isCaller}). Total peers: ${count}`);

    // Inform joining socket of current room count and notify existing peer(s)
    socket.emit('call:room-state', { callId, peerCount: count });
    socket.to(`call_${callId}`).emit('call:peer-ready', { callId, socketId: socket.id, peerCount: count });

    // Replay buffered signaling in case the other peer sent Offer/Answer/ICE before this peer joined
    const state = callSignals.get(callId);
    if (state) {
      if (isCaller === false && state.offer && state.offer.fromSocketId !== socket.id) {
        console.log(`[WebRTC] Replaying buffered SDP Offer & ${state.callerCandidates.length} caller ICE candidates to receiver ${socket.id}`);
        socket.emit('webrtc:offer', { callId, sdp: state.offer.sdp });
        for (const cand of state.callerCandidates) {
          socket.emit('webrtc:ice-candidate', cand);
        }
      } else if (isCaller === true && state.answer && state.answer.fromSocketId !== socket.id) {
        console.log(`[WebRTC] Replaying buffered SDP Answer & ${state.receiverCandidates.length} receiver ICE candidates to caller ${socket.id}`);
        socket.emit('webrtc:answer', { callId, sdp: state.answer.sdp });
        for (const cand of state.receiverCandidates) {
          socket.emit('webrtc:ice-candidate', cand);
        }
      } else if (isCaller === undefined && state.offer && state.offer.fromSocketId !== socket.id) {
        socket.emit('webrtc:offer', { callId, sdp: state.offer.sdp });
        for (const cand of state.callerCandidates) {
          socket.emit('webrtc:ice-candidate', cand);
        }
      }
    }
  });

  // Call Signaling: Invite
  socket.on('call:invite', (data: { callerId: string; creatorId: string; callType: string; callId: string }) => {
    console.log(`[Socket Call Invite]: From ${data.callerId} to ${data.creatorId}`);
    socket.join(`call_${data.callId}`);
    io.to(`user_${data.creatorId}`).emit('call:incoming', data);
  });

  // Call Signaling: Accept (Starts Live 60-Second Billing Engine)
  socket.on('call:accept', async (data: { callId: string; callerId: string }) => {
    console.log(`[Socket Call Accept]: Call ${data.callId} accepted`);
    socket.join(`call_${data.callId}`);
    await callBillingManager.startCallBilling(data.callId, io);
  });

  // Call Signaling: Reject
  socket.on('call:reject', (data: { callId: string; callerId: string; reason?: string }) => {
    console.log(`[Socket Call Reject]: Call ${data.callId} rejected`);
    callSignals.delete(data.callId);
    io.to(`user_${data.callerId}`).emit('call:rejected', data);
  });

  // Call Signaling: Hangup / End Call
  socket.on('call:end', async (data: { callId: string; reason?: string }) => {
    console.log(`[Socket Call End]: Call ${data.callId} ended by client`);
    callSignals.delete(data.callId);
    await callBillingManager.endCall(data.callId, data.reason || 'USER_HANGUP', io);
  });

  // WebRTC Signaling: SDP Offer
  socket.on('webrtc:offer', (data: { callId: string; sdp: any }) => {
    if (!data?.callId || !data?.sdp) return;
    console.log(`[WebRTC] SDP Offer relayed in call_${data.callId} from ${socket.id}`);
    const state = getOrCreateCallSignal(data.callId);
    state.offer = { callId: data.callId, sdp: data.sdp, fromSocketId: socket.id };
    state.answer = undefined;
    state.receiverCandidates = [];
    socket.to(`call_${data.callId}`).emit('webrtc:offer', data);
  });

  // WebRTC Signaling: SDP Answer
  socket.on('webrtc:answer', (data: { callId: string; sdp: any }) => {
    if (!data?.callId || !data?.sdp) return;
    console.log(`[WebRTC] SDP Answer relayed in call_${data.callId} from ${socket.id}`);
    const state = getOrCreateCallSignal(data.callId);
    state.answer = { callId: data.callId, sdp: data.sdp, fromSocketId: socket.id };
    socket.to(`call_${data.callId}`).emit('webrtc:answer', data);
  });

  // WebRTC Signaling: Peer Ready Ping
  socket.on('webrtc:ready', (data: { callId: string }) => {
    if (!data?.callId) return;
    console.log(`[WebRTC] Peer Ready ping in call_${data.callId} from ${socket.id}`);
    socket.to(`call_${data.callId}`).emit('webrtc:ready', data);
  });

  // WebRTC Signaling: ICE Candidate
  socket.on('webrtc:ice-candidate', (data: { callId: string; candidate: any; isCaller?: boolean }) => {
    if (!data?.callId || !data?.candidate) return;
    const state = getOrCreateCallSignal(data.callId);
    const fromCaller = data.isCaller ?? (state.offer?.fromSocketId === socket.id);
    const entry = { callId: data.callId, candidate: data.candidate };
    if (fromCaller) {
      if (state.callerCandidates.length < 100) state.callerCandidates.push(entry);
    } else {
      if (state.receiverCandidates.length < 100) state.receiverCandidates.push(entry);
    }
    console.log(`[WebRTC] ICE candidate in call_${data.callId} (caller=${fromCaller}) from ${socket.id}: ${data.candidate?.candidate?.substring(0, 40)}...`);
    socket.to(`call_${data.callId}`).emit('webrtc:ice-candidate', entry);
  });

  socket.on('disconnect', () => {
    console.log(`[Socket Disconnected]: ${socket.id}`);
  });
});

const PORT = process.env.PORT || 5000;

server.listen(Number(PORT), '0.0.0.0', () => {
  console.log(`====================================================`);
  console.log(`🚀 LinkUp Full Backend Server running on port ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`🌐 LAN Access:   http://10.186.14.158:${PORT}/api/v1`);
  console.log(`👥 Creators API: http://localhost:${PORT}/api/v1/creators`);
  console.log(`💰 Wallet API:   http://localhost:${PORT}/api/v1/wallet/packages`);
  console.log(`💬 Chat API:     http://localhost:${PORT}/api/v1/chat/messages`);
  console.log(`====================================================`);
});
