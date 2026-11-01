import { Router } from 'express';
import { prisma } from '../lib/prisma.js';

export const adminRouter = Router();

/**
 * GET /api/v1/admin/settings
 */
adminRouter.get('/settings', async (_req, res) => {
  try {
    const settings = await prisma.adminSetting.findUnique({
      where: { id: 1 },
    });
    return res.json({ success: true, settings });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
});

/**
 * PUT /api/v1/admin/settings
 */
adminRouter.put('/settings', async (req, res) => {
  try {
    const { isFreezeBalance, isVideoConnectionEnabled, paymentUpiId } = req.body;

    const settings = await prisma.adminSetting.upsert({
      where: { id: 1 },
      update: {
        ...(typeof isFreezeBalance === 'boolean' && { isFreezeBalance }),
        ...(typeof isVideoConnectionEnabled === 'boolean' && { isVideoConnectionEnabled }),
        ...(paymentUpiId && { paymentUpiId }),
      },
      create: {
        id: 1,
        isFreezeBalance: isFreezeBalance ?? false,
        isVideoConnectionEnabled: isVideoConnectionEnabled ?? true,
        paymentUpiId: paymentUpiId ?? 'linkup@ybl',
      },
    });

    return res.json({ success: true, settings });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
});

