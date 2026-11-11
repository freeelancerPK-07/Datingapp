import { prisma } from './prisma.js';
import { deleteFirebaseUser } from './firebaseAdmin.js';

export interface DeleteUserResult {
  success: boolean;
  firebaseDeleted: boolean;
  firebaseReason?: string;
}

/**
 * Permanently and atomically deletes a user and all related records from
 * Supabase PostgreSQL AND Firebase Authentication.
 */
export async function deleteUserPermanently(userId: string): Promise<DeleteUserResult> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: { creator: true, wallet: true },
  });

  if (!user) {
    return { success: false, firebaseDeleted: false, firebaseReason: 'user-not-found' };
  }

  const creatorId = user.creator?.id;
  const walletId = user.wallet?.id;

  await prisma.$transaction(async (tx) => {
    await tx.chatMessage.deleteMany({
      where: {
        OR: [
          { senderId: userId },
          { receiverId: userId },
        ],
      },
    });

    const callWhereOr: any[] = [{ callerId: userId }];
    if (creatorId) {
      callWhereOr.push({ creatorId });
    }
    await tx.callSession.deleteMany({
      where: {
        OR: callWhereOr,
      },
    });

    await tx.creatorApplication.deleteMany({
      where: { userId },
    });

    if (creatorId) {
      await tx.creator.deleteMany({
        where: { id: creatorId },
      });
    }

    if (walletId) {
      await tx.walletTransaction.deleteMany({
        where: { walletId },
      });
    }

    await tx.wallet.deleteMany({
      where: { userId },
    });

    await tx.userProfile.deleteMany({
      where: { userId },
    });

    await tx.user.delete({
      where: { id: userId },
    });
  });

  // Sync deletion to Firebase Authentication
  const fbRes = await deleteFirebaseUser({
    email: user.email,
    phone: user.phone,
  });

  console.log(
    `[USER_CLEANUP] Purged user ${userId} from Supabase PostgreSQL. Firebase Auth deleted=${fbRes.deleted} (${fbRes.reason})`
  );

  return {
    success: true,
    firebaseDeleted: fbRes.deleted,
    firebaseReason: fbRes.reason,
  };
}
