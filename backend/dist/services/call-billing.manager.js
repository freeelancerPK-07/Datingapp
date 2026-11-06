"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.callBillingManager = void 0;
const prisma_js_1 = require("../lib/prisma.js");
class CallBillingManager {
    activeCalls = new Map();
    /**
     * Start 60-Second Recurring Billing for an Active Call
     */
    async startCallBilling(callId, io) {
        if (this.activeCalls.has(callId)) {
            console.log(`[Call Manager] Call ${callId} is already actively billing`);
            return;
        }
        const call = await prisma_js_1.prisma.callSession.findUnique({
            where: { id: callId },
            include: {
                creator: { include: { user: true } },
            },
        });
        if (!call || call.status === 'COMPLETED') {
            console.error(`[Call Manager] Call ${callId} not found or already completed`);
            return;
        }
        // Mark Connected in DB & mark Creator BUSY
        await prisma_js_1.prisma.$transaction([
            prisma_js_1.prisma.callSession.update({
                where: { id: callId },
                data: { status: 'CONNECTED', startedAt: new Date() },
            }),
            prisma_js_1.prisma.creator.update({
                where: { id: call.creatorId },
                data: { isAvailable: false },
            }),
        ]);
        const activeCall = {
            callId,
            callerId: call.callerId,
            creatorId: call.creatorId,
            ratePerMin: call.ratePerMin,
            startedAt: new Date(),
            elapsedSeconds: 0,
        };
        // 60-Second Tick Interval
        activeCall.intervalRef = setInterval(async () => {
            await this.processMinuteDebit(activeCall, io);
        }, 60000); // 60 seconds
        this.activeCalls.set(callId, activeCall);
        console.log(`[Call Manager] 🚀 Started live billing for Call ${callId} (${call.ratePerMin} coins/min)`);
        // Notify participants
        io.to(`call_${callId}`).emit('call:connected', {
            callId,
            startedAt: activeCall.startedAt,
            ratePerMin: activeCall.ratePerMin,
        });
    }
    /**
     * Minute-by-Minute Atomic Debit Engine
     */
    async processMinuteDebit(activeCall, io) {
        const { callId, callerId, creatorId, ratePerMin } = activeCall;
        try {
            // 1. Fetch current caller wallet
            const wallet = await prisma_js_1.prisma.wallet.findUnique({ where: { userId: callerId } });
            if (!wallet || wallet.balance < ratePerMin || wallet.isFrozen) {
                console.warn(`[Call Manager] ⚠️ Insufficient balance or frozen wallet for Call ${callId}`);
                await this.endCall(callId, 'INSUFFICIENT_BALANCE', io);
                return;
            }
            // 2. Atomic SQL Transaction: Debit caller, credit creator, update call stats
            const result = await prisma_js_1.prisma.$transaction(async (tx) => {
                const newCallerBal = wallet.balance - ratePerMin;
                // Debit Caller
                const updatedWallet = await tx.wallet.update({
                    where: { id: wallet.id },
                    data: { balance: newCallerBal, version: { increment: 1 } },
                });
                await tx.walletTransaction.create({
                    data: {
                        walletId: wallet.id,
                        type: 'CALL_USAGE',
                        coins: -ratePerMin,
                        balanceAfter: newCallerBal,
                        status: 'COMPLETED',
                        referenceId: callId,
                        description: `Live Call Minute Debit (-${ratePerMin} Coins)`,
                    },
                });
                // Credit Creator (70%)
                const creator = await tx.creator.findUnique({ where: { id: creatorId } });
                if (creator) {
                    const creatorWallet = await tx.wallet.findUnique({ where: { userId: creator.userId } });
                    if (creatorWallet) {
                        const creatorShare = Math.floor(ratePerMin * 0.7);
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
                                referenceId: callId,
                                description: `Live Call Earning (+${creatorShare} Coins)`,
                            },
                        });
                    }
                }
                // Increment duration
                activeCall.elapsedSeconds += 60;
                await tx.callSession.update({
                    where: { id: callId },
                    data: {
                        durationSecs: activeCall.elapsedSeconds,
                        totalCoins: { increment: ratePerMin },
                    },
                });
                return { remainingBalance: updatedWallet.balance };
            });
            console.log(`[Call Manager] ⏱️ 60s Debit successful. Remaining Coins: ${result.remainingBalance}`);
            // Emit live tick to mobile client
            io.to(`call_${callId}`).emit('call:tick', {
                callId,
                elapsedSeconds: activeCall.elapsedSeconds,
                coinsDeducted: ratePerMin,
                remainingBalance: result.remainingBalance,
            });
            // Low balance warning if next minute cannot be afforded
            if (result.remainingBalance < ratePerMin) {
                console.warn(`[Call Manager] 🔔 Low balance warning triggered for User ${callerId}`);
                io.to(`call_${callId}`).emit('call:balance_warning', {
                    callId,
                    secondsRemaining: 30,
                    currentBalance: result.remainingBalance,
                    requiredRate: ratePerMin,
                });
            }
        }
        catch (error) {
            console.error(`[Call Manager] Error during minute debit:`, error);
        }
    }
    /**
     * Terminate and Settle Call
     */
    async endCall(callId, endReason = 'USER_HANGUP', io) {
        const active = this.activeCalls.get(callId);
        if (active?.intervalRef) {
            clearInterval(active.intervalRef);
        }
        this.activeCalls.delete(callId);
        const call = await prisma_js_1.prisma.callSession.findUnique({
            where: { id: callId },
        });
        if (!call)
            return;
        // Release Creator availability & mark call COMPLETED
        await prisma_js_1.prisma.$transaction([
            prisma_js_1.prisma.callSession.update({
                where: { id: callId },
                data: {
                    status: 'COMPLETED',
                    endedAt: new Date(),
                    endReason,
                },
            }),
            prisma_js_1.prisma.creator.update({
                where: { id: call.creatorId },
                data: { isAvailable: true },
            }),
        ]);
        console.log(`[Call Manager] 🏁 Call ${callId} ended (${endReason}). Creator released.`);
        if (io) {
            io.to(`call_${callId}`).emit('call:ended', {
                callId,
                durationSeconds: call.durationSecs,
                totalCoins: call.totalCoins,
                endReason,
            });
        }
    }
}
exports.callBillingManager = new CallBillingManager();
