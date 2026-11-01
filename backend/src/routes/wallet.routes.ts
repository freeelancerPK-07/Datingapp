import { Router } from 'express';
import { prisma } from '../lib/prisma.js';

export const walletRouter = Router();

// Official 6 fixed packages matching Flutter kCoinPackages
const KOIN_PACKAGES = [
  { coins: 200, priceInr: 199, tag: null },
  { coins: 300, priceInr: 299, tag: null },
  { coins: 400, priceInr: 399, tag: 'Popular' },
  { coins: 500, priceInr: 499, tag: null },
  { coins: 600, priceInr: 599, tag: 'Best Value' },
  { coins: 700, priceInr: 699, tag: 'VIP Pack' },
];

/**
 * GET /api/v1/wallet/packages
 */
walletRouter.get('/packages', (_req, res) => {
  return res.json({ success: true, packages: KOIN_PACKAGES });
});

/**
 * GET /api/v1/wallet/balance?userId=...
 */
walletRouter.get('/balance', async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }

    const wallet = await prisma.wallet.findUnique({
      where: { userId: String(userId) },
    });

    if (!wallet) {
      return res.status(404).json({ error: 'Wallet not found' });
    }

    return res.json({
      success: true,
      balance: wallet.balance,
      reservedBalance: wallet.reservedBalance,
      isFrozen: wallet.isFrozen,
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
});

/**
 * POST /api/v1/wallet/recharge
 * Credits coins & records in double-entry ledger
 */
walletRouter.post('/recharge', async (req, res) => {
  try {
    const { userId, coins, amountInr, paymentId } = req.body;
    if (!userId || !coins) {
      return res.status(400).json({ error: 'userId and coins are required' });
    }

    // Atomic transaction: update wallet balance + create ledger transaction
    const result = await prisma.$transaction(async (tx) => {
      const wallet = await tx.wallet.findUnique({
        where: { userId },
      });

      if (!wallet) {
        throw new Error('Wallet not found');
      }

      if (wallet.isFrozen) {
        throw new Error('Wallet is currently frozen by administration');
      }

      const newBalance = wallet.balance + Number(coins);

      // 1. Update wallet
      const updatedWallet = await tx.wallet.update({
        where: { id: wallet.id },
        data: {
          balance: newBalance,
          version: { increment: 1 },
        },
      });

      // 2. Add immutable transaction record
      const transaction = await tx.walletTransaction.create({
        data: {
          walletId: wallet.id,
          type: 'PURCHASE',
          coins: Number(coins),
          amountInr: amountInr ? Number(amountInr) : null,
          balanceAfter: newBalance,
          status: 'COMPLETED',
          referenceId: paymentId || `PAY-${Date.now()}`,
          description: `Recharged ${coins} Coins via UPI`,
        },
      });

      return { updatedWallet, transaction };
    });

    return res.json({
      success: true,
      message: 'Coins recharged successfully',
      newBalance: result.updatedWallet.balance,
      transaction: result.transaction,
    });
  } catch (error: any) {
    return res.status(400).json({ error: error.message });
  }
});

/**
 * GET /api/v1/wallet/transactions?userId=...
 */
walletRouter.get('/transactions', async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }

    const wallet = await prisma.wallet.findUnique({
      where: { userId: String(userId) },
    });

    if (!wallet) {
      return res.status(404).json({ error: 'Wallet not found' });
    }

    const transactions = await prisma.walletTransaction.findMany({
      where: { walletId: wallet.id },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });

    return res.json({ success: true, data: transactions });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
});

