"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteUserPermanently = deleteUserPermanently;
const prisma_js_1 = require("./prisma.js");
/**
 * Permanently and atomically deletes a user and all related records from PostgreSQL.
 * Wipes ChatMessages, CallSessions, CreatorApplications, Creator, WalletTransactions,
 * Wallet, UserProfile, and User.
 */
async function deleteUserPermanently(userId) {
    const user = await prisma_js_1.prisma.user.findUnique({
        where: { id: userId },
        include: { creator: true, wallet: true },
    });
    if (!user) {
        return false;
    }
    const creatorId = user.creator?.id;
    const walletId = user.wallet?.id;
    await prisma_js_1.prisma.$transaction(async (tx) => {
        // 1. Delete all ChatMessages where user was sender OR receiver
        await tx.chatMessage.deleteMany({
            where: {
                OR: [
                    { senderId: userId },
                    { receiverId: userId },
                ],
            },
        });
        // 2. Delete all CallSessions where user was caller OR creator
        const callWhereOr = [{ callerId: userId }];
        if (creatorId) {
            callWhereOr.push({ creatorId });
        }
        await tx.callSession.deleteMany({
            where: {
                OR: callWhereOr,
            },
        });
        // 3. Delete all CreatorApplications
        await tx.creatorApplication.deleteMany({
            where: { userId },
        });
        // 4. Delete Creator record
        if (creatorId) {
            await tx.creator.deleteMany({
                where: { id: creatorId },
            });
        }
        // 5. Delete WalletTransactions
        if (walletId) {
            await tx.walletTransaction.deleteMany({
                where: { walletId },
            });
        }
        // 6. Delete Wallet
        await tx.wallet.deleteMany({
            where: { userId },
        });
        // 7. Delete UserProfile
        await tx.userProfile.deleteMany({
            where: { userId },
        });
        // 8. Delete User
        await tx.user.delete({
            where: { id: userId },
        });
    });
    console.log(`[USER_CLEANUP] Successfully purged user ${userId} permanently from DB.`);
    return true;
}
