"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.io = void 0;
require("dotenv/config");
const express_1 = __importDefault(require("express"));
const http_1 = __importDefault(require("http"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const socket_io_1 = require("socket.io");
const prisma_js_1 = require("./lib/prisma.js");
const auth_routes_js_1 = require("./routes/auth.routes.js");
const profile_routes_js_1 = require("./routes/profile.routes.js");
const creator_routes_js_1 = require("./routes/creator.routes.js");
const wallet_routes_js_1 = require("./routes/wallet.routes.js");
const call_routes_js_1 = require("./routes/call.routes.js");
const admin_routes_js_1 = require("./routes/admin.routes.js");
const upload_routes_js_1 = require("./routes/upload.routes.js");
const path_1 = __importDefault(require("path"));
const chat_routes_js_1 = require("./routes/chat.routes.js");
const call_billing_manager_js_1 = require("./services/call-billing.manager.js");
dotenv_1.default.config();
const app = (0, express_1.default)();
const server = http_1.default.createServer(app);
// WebSockets Server
exports.io = new socket_io_1.Server(server, {
    cors: {
        origin: '*',
        methods: ['GET', 'POST'],
    },
});
// Middleware
app.use((0, cors_1.default)());
app.use(express_1.default.json({ limit: '50mb' }));
app.use(express_1.default.urlencoded({ limit: '50mb', extended: true }));
// Serve uploaded media files publicly
app.use('/uploads', express_1.default.static(path_1.default.join(process.cwd(), 'uploads')));
// API Routes
app.use('/api/v1/upload', upload_routes_js_1.uploadRouter);
app.use('/api/v1/auth', auth_routes_js_1.authRouter);
app.use('/api/v1/profile', profile_routes_js_1.profileRouter);
app.use('/api/v1/creators', creator_routes_js_1.creatorRouter);
app.use('/api/v1/wallet', wallet_routes_js_1.walletRouter);
app.use('/api/v1/calls', call_routes_js_1.callRouter);
app.use('/api/v1/chat', chat_routes_js_1.chatRouter);
app.use('/api/v1/admin', admin_routes_js_1.adminRouter);
// Health Check
app.get('/health', async (_req, res) => {
    try {
        await prisma_js_1.prisma.$queryRaw `SELECT 1`;
        res.json({
            status: 'UP',
            database: 'Connected to PostgreSQL (linkup_db)',
            timestamp: new Date().toISOString(),
        });
    }
    catch (error) {
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
exports.io.on('connection', (socket) => {
    console.log(`[Socket Connected]: ${socket.id}`);
    // Join User Private Room
    socket.on('user:join', (userId) => {
        socket.join(`user_${userId}`);
        console.log(`[Socket] User ${userId} joined room user_${userId}`);
    });
    // Join Call Room (for live call events & billing ticks & WebRTC)
    socket.on('call:join', (callId) => {
        socket.join(`call_${callId}`);
        const room = exports.io.sockets.adapter.rooms.get(`call_${callId}`);
        const count = room ? room.size : 1;
        console.log(`[Socket] ${socket.id} joined call room call_${callId}. Total peers: ${count}`);
        // Notify the other peer in this room that a peer is ready
        socket.to(`call_${callId}`).emit('call:peer-ready', { callId, socketId: socket.id, peerCount: count });
    });
    // Call Signaling: Invite
    socket.on('call:invite', (data) => {
        console.log(`[Socket Call Invite]: From ${data.callerId} to ${data.creatorId}`);
        socket.join(`call_${data.callId}`);
        exports.io.to(`user_${data.creatorId}`).emit('call:incoming', data);
    });
    // Call Signaling: Accept (Starts Live 60-Second Billing Engine)
    socket.on('call:accept', async (data) => {
        console.log(`[Socket Call Accept]: Call ${data.callId} accepted`);
        socket.join(`call_${data.callId}`);
        await call_billing_manager_js_1.callBillingManager.startCallBilling(data.callId, exports.io);
    });
    // Call Signaling: Reject
    socket.on('call:reject', (data) => {
        console.log(`[Socket Call Reject]: Call ${data.callId} rejected`);
        exports.io.to(`user_${data.callerId}`).emit('call:rejected', data);
    });
    // Call Signaling: Hangup / End Call
    socket.on('call:end', async (data) => {
        console.log(`[Socket Call End]: Call ${data.callId} ended by client`);
        await call_billing_manager_js_1.callBillingManager.endCall(data.callId, data.reason || 'USER_HANGUP', exports.io);
    });
    // WebRTC Signaling: SDP Offer
    socket.on('webrtc:offer', (data) => {
        console.log(`[WebRTC] SDP Offer relayed in call_${data.callId} from ${socket.id}`);
        socket.to(`call_${data.callId}`).emit('webrtc:offer', data);
    });
    // WebRTC Signaling: SDP Answer
    socket.on('webrtc:answer', (data) => {
        console.log(`[WebRTC] SDP Answer relayed in call_${data.callId} from ${socket.id}`);
        socket.to(`call_${data.callId}`).emit('webrtc:answer', data);
    });
    // WebRTC Signaling: Peer Ready Ping
    socket.on('webrtc:ready', (data) => {
        console.log(`[WebRTC] Peer Ready ping in call_${data.callId} from ${socket.id}`);
        socket.to(`call_${data.callId}`).emit('webrtc:ready', data);
    });
    // WebRTC Signaling: ICE Candidate
    socket.on('webrtc:ice-candidate', (data) => {
        console.log(`[WebRTC] ICE candidate in call_${data.callId} from ${socket.id}: ${data.candidate?.candidate?.substring(0, 40)}...`);
        socket.to(`call_${data.callId}`).emit('webrtc:ice-candidate', data);
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
