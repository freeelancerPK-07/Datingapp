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

// Sockets Connection Handler
io.on('connection', (socket) => {
  console.log(`[Socket Connected]: ${socket.id}`);

  // Join User Private Room
  socket.on('user:join', (userId: string) => {
    socket.join(`user_${userId}`);
    console.log(`[Socket] User ${userId} joined room user_${userId}`);
  });

  // Join Call Room (for live call events & billing ticks)
  socket.on('call:join', (callId: string) => {
    socket.join(`call_${callId}`);
    console.log(`[Socket] ${socket.id} joined call room call_${callId}`);
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
    io.to(`user_${data.callerId}`).emit('call:rejected', data);
  });

  // Call Signaling: Hangup / End Call
  socket.on('call:end', async (data: { callId: string; reason?: string }) => {
    console.log(`[Socket Call End]: Call ${data.callId} ended by client`);
    await callBillingManager.endCall(data.callId, data.reason || 'USER_HANGUP', io);
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
