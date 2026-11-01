import { Router } from 'express';
import { prisma } from '../lib/prisma.js';

export const callRouter = Router();

/**
 * POST /api/v1/calls/initiate
 * Pre-call feasibility check + session initialization + Agora token
 */
callRouter.post('/initiate', async (req, res) => {
  try {
    const { callerId, creatorId, callType = 'VIDEO' } = req.body;

    if (!callerId || !creatorId) {
      return res.status(400).json({ error: 'callerId and creatorId are required' });
    }

    // 1. Check Global Admin Killswitch
    const adminSettings = await prisma.adminSetting.findUnique({ where: { id: 1 } });
    if (adminSettings && !adminSettings.isVideoConnectionEnabled) {
      return res.status(403).json({
        error: 'Video connections are temporarily disabled for administrative maintenance',
      });
    }

    // 2. Fetch Creator and verify availability
    const creator = await prisma.creator.findUnique({
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
    const callerWallet = await prisma.wallet.findUnique({
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

    // 4. Generate unique Agora Channel Name & RTC Token
    const agoraChannel = `call_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
    const agoraToken = `mock_agora_token_${Date.now()}`; // Will use agora-token builder with real AppId

    // 5. Create CallSession in Database
    const callSession = await prisma.callSession.create({
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
      agoraChannel,
      agoraToken,
      ratePerMin,
      creator: {
        name: creator.user.profile?.name,
        photoUrl: creator.user.profile?.avatarUrl,
        profession: creator.profession,
      },
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
});

/**
 * POST /api/v1/calls/:id/end
 * Clean call settlement (atomic coin deduction & creator split)
 */
callRouter.post('/:id/end', async (req, res) => {
  try {
    const { id } = req.params;
    const { durationSeconds, endReason = 'USER_HANGUP' } = req.body;

    const call = await prisma.callSession.findUnique({
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
    const result = await prisma.$transaction(async (tx) => {
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
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
});

/**
 * GET /api/v1/calls/history?userId=...
 */
callRouter.get('/history', async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }

    const history = await prisma.callSession.findMany({
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
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
});

