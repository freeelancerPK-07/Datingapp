"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.chatRouter = void 0;
const express_1 = require("express");
const prisma_js_1 = require("../lib/prisma.js");
const server_js_1 = require("../server.js");
exports.chatRouter = (0, express_1.Router)();
/**
 * GET /api/v1/chat/messages?user1=...&user2=...
 * Fetch conversation history between two users
 */
exports.chatRouter.get('/messages', async (req, res) => {
    try {
        const { user1, user2 } = req.query;
        if (!user1 || !user2) {
            return res.status(400).json({ error: 'user1 and user2 are required' });
        }
        const messages = await prisma_js_1.prisma.chatMessage.findMany({
            where: {
                OR: [
                    { senderId: String(user1), receiverId: String(user2) },
                    { senderId: String(user2), receiverId: String(user1) },
                ],
            },
            orderBy: { createdAt: 'asc' },
        });
        return res.json({ success: true, count: messages.length, data: messages });
    }
    catch (error) {
        return res.status(500).json({ error: error.message });
    }
});
/**
 * POST /api/v1/chat/send
 * Send message (Text or Media / Locked Photo)
 */
exports.chatRouter.post('/send', async (req, res) => {
    try {
        const { senderId, receiverId, contentType = 'TEXT', textBody, mediaUrl, isLocked = false, unlockPrice = 0 } = req.body;
        if (!senderId || !receiverId) {
            return res.status(400).json({ error: 'senderId and receiverId are required' });
        }
        const message = await prisma_js_1.prisma.chatMessage.create({
            data: {
                senderId,
                receiverId,
                contentType,
                textBody,
                mediaUrl,
                isLocked,
                unlockPrice: isLocked ? Number(unlockPrice || 200) : 0,
                isUnlocked: !isLocked, // unlocked by default if not locked
            },
        });
        // Real-time broadcast via socket
        server_js_1.io.to(`user_${receiverId}`).emit('chat:receive_message', message);
        return res.json({ success: true, data: message });
    }
    catch (error) {
        return res.status(500).json({ error: error.message });
    }
});
/**
 * POST /api/v1/chat/unlock-photo
 * Deduct coins to unlock private creator media
 */
exports.chatRouter.post('/unlock-photo', async (req, res) => {
    try {
        const { messageId, userId } = req.body;
        if (!messageId || !userId) {
            return res.status(400).json({ error: 'messageId and userId are required' });
        }
        const message = await prisma_js_1.prisma.chatMessage.findUnique({
            where: { id: messageId },
        });
        if (!message) {
            return res.status(404).json({ error: 'Message not found' });
        }
        if (message.isUnlocked) {
            return res.json({ success: true, message: 'Already unlocked', data: message });
        }
        const price = message.unlockPrice;
        // Atomic transaction: Debit user, credit creator (70%), unlock photo
        const result = await prisma_js_1.prisma.$transaction(async (tx) => {
            const userWallet = await tx.wallet.findUnique({ where: { userId } });
            if (!userWallet || userWallet.balance < price || userWallet.isFrozen) {
                throw new Error('Insufficient coins to unlock this photo');
            }
            // Debit User
            const newBal = userWallet.balance - price;
            await tx.wallet.update({
                where: { id: userWallet.id },
                data: { balance: newBal, version: { increment: 1 } },
            });
            await tx.walletTransaction.create({
                data: {
                    walletId: userWallet.id,
                    type: 'PHOTO_PURCHASE',
                    coins: -price,
                    balanceAfter: newBal,
                    status: 'COMPLETED',
                    referenceId: message.id,
                    description: `Unlocked Creator Private Photo (-${price} Coins)`,
                },
            });
            // Credit Creator
            const creator = await tx.creator.findUnique({ where: { userId: message.senderId } });
            if (creator) {
                const creatorWallet = await tx.wallet.findUnique({ where: { userId: creator.userId } });
                if (creatorWallet) {
                    const creatorShare = Math.floor(price * 0.7);
                    const newCreatorBal = creatorWallet.balance + creatorShare;
                    await tx.wallet.update({
                        where: { id: creatorWallet.id },
                        data: { balance: newCreatorBal, version: { increment: 1 } },
                    });
                    await tx.walletTransaction.create({
                        data: {
                            walletId: creatorWallet.id,
                            type: 'PHOTO_PURCHASE',
                            coins: creatorShare,
                            balanceAfter: newCreatorBal,
                            status: 'COMPLETED',
                            referenceId: message.id,
                            description: `Private Photo Unlock Earning (+${creatorShare} Coins)`,
                        },
                    });
                }
            }
            // Mark message unlocked
            const unlockedMsg = await tx.chatMessage.update({
                where: { id: message.id },
                data: { isUnlocked: true },
            });
            return { unlockedMsg, remainingBalance: newBal };
        });
        return res.json({
            success: true,
            data: result.unlockedMsg,
            remainingBalance: result.remainingBalance,
        });
    }
    catch (error) {
        return res.status(400).json({ error: error.message });
    }
});
