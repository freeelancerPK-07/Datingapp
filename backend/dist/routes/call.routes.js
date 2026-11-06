"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.callRouter = void 0;
const express_1 = require("express");
const prisma_js_1 = require("../lib/prisma.js");
const agora_js_1 = require("../lib/agora.js");
exports.callRouter = (0, express_1.Router)();
/**
 * POST /api/v1/calls/initiate
 * Pre-call feasibility check + session initialization + Agora token
 */
exports.callRouter.post('/initiate', async (req, res) => {
    try {
        const { callerId, creatorId, callType = 'VIDEO' } = req.body;
        if (!callerId || !creatorId) {
            return res.status(400).json({ error: 'callerId and creatorId are required' });
        }
        // 1. Check Global Admin Killswitch
        const adminSettings = await prisma_js_1.prisma.adminSetting.findUnique({ where: { id: 1 } });
        if (adminSettings && !adminSettings.isVideoConnectionEnabled) {
            return res.status(403).json({
                error: 'Video connections are temporarily disabled for administrative maintenance',
            });
        }
        // 2. Fetch Creator and verify availability
        const creator = await prisma_js_1.prisma.creator.findUnique({
            where: { id: creatorId },
            include: { user: { include: { profile: true } } },
        });
        if (!creator) {
            return res.status(404).json({ error: 'Creator not found' });
        }
        if (!creator.isOnline || !creator.isAvailable) {
            return res.status(400).json({ error: 'Creator is currently busy or offline' });
        }
        const ratePerMin = callType === 'VIDEO' ? creator.videoCallPrice : creator.voiceCallPrice;
        // 3. Fetch Caller Wallet & Check Balance
        const callerWallet = await prisma_js_1.prisma.wallet.findUnique({
            where: { userId: callerId },
        });
        if (!callerWallet) {
            return res.status(404).json({ error: 'Caller wallet not found' });
        }
        if (callerWallet.isFrozen || (adminSettings && adminSettings.isFreezeBalance)) {
            return res.status(403).json({ error: 'Your diamond balance is currently frozen' });
        }
        if (callerWallet.balance < ratePerMin) {
            return res.status(402).json({
                error: 'Insufficient coins to start this connection',
                requiredCoins: ratePerMin,
                currentBalance: callerWallet.balance,
            });
        }
        // 4. Generate unique Agora Channel Name & Production RTC Tokens
        const safeCallerId = String(callerId).replace(/[^a-zA-Z0-9]/g, '').substring(0, 8);
        const safeCreatorId = String(creatorId).replace(/[^a-zA-Z0-9]/g, '').substring(0, 8);
        const agoraChannel = `call_${safeCallerId}_${safeCreatorId}_${Date.now()}`;
        const tokens = (0, agora_js_1.generateAgoraTokens)(agoraChannel, 0, 1, 7200);
        // 5. Create CallSession in Database
        const callSession = await prisma_js_1.prisma.callSession.create({
            data: {
                callerId,
                creatorId,
                callType: callType === 'VOICE' ? 'VOICE' : 'VIDEO',
                ratePerMin,
                status: 'INITIATED',
                agoraChannel,
            },
        });
        return res.json({
            success: true,
            callId: callSession.id,
            agoraAppId: tokens.appId,
            agoraChannel: tokens.channelName,
            agoraToken: tokens.callerToken,
            callerToken: tokens.callerToken,
            creatorToken: tokens.creatorToken,
            ratePerMin,
            creator: {
                name: creator.user.profile?.name,
                photoUrl: creator.user.profile?.avatarUrl,
                profession: creator.profession,
            },
        });
    }
    catch (error) {
        return res.status(500).json({ error: error.message });
    }
});
/**
 * GET /api/v1/calls/incoming
 * Poll for pending incoming calls for a creator
 */
exports.callRouter.get('/incoming', async (req, res) => {
    try {
        const { userId, creatorId } = req.query;
        if (!userId && !creatorId) {
            return res.status(400).json({ success: false, error: 'userId or creatorId is required' });
        }
        let creator = null;
        if (creatorId) {
            creator = await prisma_js_1.prisma.creator.findUnique({ where: { id: String(creatorId) } });
        }
        else if (userId) {
            creator = await prisma_js_1.prisma.creator.findUnique({ where: { userId: String(userId) } });
        }
        if (!creator) {
            return res.json({ success: true, incomingCall: null });
        }
        const cutoff = new Date(Date.now() - 45 * 1000);
        const call = await prisma_js_1.prisma.callSession.findFirst({
            where: {
                creatorId: creator.id,
                status: { in: ['INITIATED', 'RINGING'] },
                createdAt: { gte: cutoff },
            },
            include: {
                caller: { include: { profile: true } },
            },
            orderBy: { createdAt: 'desc' },
        });
        if (!call) {
            return res.json({ success: true, incomingCall: null });
        }
        return res.json({
            success: true,
            incomingCall: {
                callId: call.id,
                callType: call.callType,
                ratePerMin: call.ratePerMin,
                agoraChannel: call.agoraChannel,
                createdAt: call.createdAt,
                caller: {
                    id: call.callerId,
                    name: call.caller.profile?.name || 'LinkUp User',
                    photoUrl: call.caller.profile?.avatarUrl || '',
                },
            },
        });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * GET /api/v1/calls/:id/status
 * Real-time call status poll for caller & creator
 */
exports.callRouter.get('/:id/status', async (req, res) => {
    try {
        const { id } = req.params;
        const call = await prisma_js_1.prisma.callSession.findUnique({
            where: { id },
            include: {
                caller: { include: { profile: true } },
                creator: { include: { user: { include: { profile: true } } } },
            },
        });
        if (!call) {
            return res.status(404).json({ success: false, error: 'Call session not found' });
        }
        return res.json({
            success: true,
            data: {
                id: call.id,
                status: call.status,
                startedAt: call.startedAt,
                durationSecs: call.durationSecs,
                agoraChannel: call.agoraChannel,
                ratePerMin: call.ratePerMin,
                caller: {
                    id: call.callerId,
                    name: call.caller.profile?.name || 'User',
                    photoUrl: call.caller.profile?.avatarUrl || '',
                },
                creator: {
                    id: call.creatorId,
                    userId: call.creator.userId,
                    name: call.creator.user.profile?.name || 'Creator',
                    photoUrl: call.creator.user.profile?.avatarUrl || '',
                },
            },
        });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * POST /api/v1/calls/:id/accept
 * Creator accepts incoming call
 */
exports.callRouter.post('/:id/accept', async (req, res) => {
    try {
        const { id } = req.params;
        const call = await prisma_js_1.prisma.callSession.findUnique({ where: { id } });
        if (!call) {
            return res.status(404).json({ success: false, error: 'Call not found' });
        }
        if (call.status !== 'INITIATED' && call.status !== 'RINGING') {
            return res.status(400).json({ success: false, error: `Call cannot be accepted in status ${call.status}` });
        }
        const updated = await prisma_js_1.prisma.callSession.update({
            where: { id },
            data: {
                status: 'CONNECTED',
                startedAt: new Date(),
            },
        });
        return res.json({ success: true, data: updated });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * POST /api/v1/calls/:id/reject
 * Creator rejects incoming call or caller cancels
 */
exports.callRouter.post('/:id/reject', async (req, res) => {
    try {
        const { id } = req.params;
        const { reason = 'CREATOR_DECLINED' } = req.body;
        const updated = await prisma_js_1.prisma.callSession.update({
            where: { id },
            data: {
                status: 'REJECTED',
                endedAt: new Date(),
                endReason: reason,
            },
        });
        return res.json({ success: true, data: updated });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * POST /api/v1/calls/:id/end
 * Clean call settlement (atomic coin deduction & creator split)
 */
exports.callRouter.post('/:id/end', async (req, res) => {
    try {
        const { id } = req.params;
        const { durationSeconds, endReason = 'USER_HANGUP' } = req.body;
        const call = await prisma_js_1.prisma.callSession.findUnique({
            where: { id },
            include: { creator: { include: { user: true } } },
        });
        if (!call) {
            return res.status(404).json({ error: 'Call session not found' });
        }
        if (call.status === 'COMPLETED') {
            return res.json({ success: true, message: 'Call already settled' });
        }
        const duration = Number(durationSeconds || 0);
        // Calculate minutes (e.g. 1 - 60s = 1 min; 61s - 120s = 2 min)
        const billableMinutes = duration > 0 ? Math.ceil(duration / 60) : 0;
        const totalCoins = billableMinutes * call.ratePerMin;
        // Atomic settlement: debit user, credit creator (70%), platform (30%)
        const result = await prisma_js_1.prisma.$transaction(async (tx) => {
            let updatedUserWallet = null;
            if (totalCoins > 0) {
                // Debit Caller
                const callerWallet = await tx.wallet.findUnique({ where: { userId: call.callerId } });
                if (callerWallet) {
                    const newCallerBal = Math.max(0, callerWallet.balance - totalCoins);
                    updatedUserWallet = await tx.wallet.update({
                        where: { id: callerWallet.id },
                        data: { balance: newCallerBal, version: { increment: 1 } },
                    });
                    await tx.walletTransaction.create({
                        data: {
                            walletId: callerWallet.id,
                            type: 'CALL_USAGE',
                            coins: -totalCoins,
                            balanceAfter: newCallerBal,
                            status: 'COMPLETED',
                            referenceId: call.id,
                            description: `Call with ${call.creatorId} (${duration}s)`,
                        },
                    });
                }
                // Credit Creator (70%)
                const creatorWallet = await tx.wallet.findUnique({ where: { userId: call.creator.userId } });
                if (creatorWallet) {
                    const creatorShare = Math.floor(totalCoins * 0.7);
                    const newCreatorBal = creatorWallet.balance + creatorShare;
                    await tx.wallet.update({
                        where: { id: creatorWallet.id },
                        data: { balance: newCreatorBal, version: { increment: 1 } },
                    });
                    await tx.walletTransaction.create({
                        data: {
                            walletId: creatorWallet.id,
                            type: 'CALL_USAGE',
                            coins: creatorShare,
                            balanceAfter: newCreatorBal,
                            status: 'COMPLETED',
                            referenceId: call.id,
                            description: `Earnings from Call (${duration}s)`,
                        },
                    });
                }
            }
            // Update CallSession
            const updatedCall = await tx.callSession.update({
                where: { id: call.id },
                data: {
                    status: 'COMPLETED',
                    endedAt: new Date(),
                    durationSecs: duration,
                    totalCoins,
                    endReason,
                },
            });
            return { updatedCall, updatedUserWallet };
        });
        return res.json({
            success: true,
            message: 'Call settled successfully',
            durationSeconds: duration,
            billableMinutes,
            totalCoins,
            remainingBalance: result.updatedUserWallet?.balance,
        });
    }
    catch (error) {
        return res.status(500).json({ error: error.message });
    }
});
/**
 * GET /api/v1/calls/history?userId=...
 */
exports.callRouter.get('/history', async (req, res) => {
    try {
        const { userId } = req.query;
        if (!userId) {
            return res.status(400).json({ error: 'userId is required' });
        }
        const history = await prisma_js_1.prisma.callSession.findMany({
            where: { callerId: String(userId) },
            include: {
                creator: {
                    include: {
                        user: { include: { profile: true } },
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
            take: 30,
        });
        const formatted = history.map((c) => ({
            id: c.id,
            creatorId: c.creatorId,
            name: c.creator.user.profile?.name || 'Creator',
            photoUrl: c.creator.user.profile?.avatarUrl || '',
            type: c.status,
            callType: c.callType,
            timestamp: c.createdAt,
            durationSeconds: c.durationSecs,
            coinsUsed: c.totalCoins,
        }));
        return res.json({ success: true, data: formatted });
    }
    catch (error) {
        return res.status(500).json({ error: error.message });
    }
});
