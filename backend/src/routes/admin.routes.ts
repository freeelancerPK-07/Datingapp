import { Router } from 'express';
import { prisma } from '../lib/prisma.js';

export const adminRouter = Router();

// =============================================================================
// COLUMN 1: WALLET & APP SETTINGS
// =============================================================================

/**
 * GET /api/v1/admin/settings
 * Retrieve global app settings: Freeze Balance, Video Connection Switch, Payment UPI
 */
adminRouter.get('/settings', async (_req, res) => {
  try {
    const settings = await prisma.adminSetting.upsert({
      where: { id: 1 },
      update: {},
      create: {
        id: 1,
        isFreezeBalance: false,
        isVideoConnectionEnabled: true,
        paymentUpiId: 'linkupapp@ybl',
      },
    });
    return res.json({ success: true, settings });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * PUT /api/v1/admin/settings
 * Update global app settings
 */
adminRouter.put('/settings', async (req, res) => {
  try {
    const { isFreezeBalance, isVideoConnectionEnabled, paymentUpiId } = req.body;

    const settings = await prisma.adminSetting.upsert({
      where: { id: 1 },
      update: {
        ...(typeof isFreezeBalance === 'boolean' && { isFreezeBalance }),
        ...(typeof isVideoConnectionEnabled === 'boolean' && { isVideoConnectionEnabled }),
        ...(paymentUpiId !== undefined && { paymentUpiId: String(paymentUpiId).trim() }),
      },
      create: {
        id: 1,
        isFreezeBalance: isFreezeBalance ?? false,
        isVideoConnectionEnabled: isVideoConnectionEnabled ?? true,
        paymentUpiId: paymentUpiId ? String(paymentUpiId).trim() : 'linkupapp@ybl',
      },
    });

    console.log('[ADMIN] App settings updated:', settings);
    return res.json({ success: true, settings, message: 'Settings saved successfully' });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// =============================================================================
// COLUMN 2: CREATOR MANAGEMENT & VERIFICATION
// =============================================================================

/**
 * GET /api/v1/admin/creators/pending
 * Retrieve pending creator verification applications for review
 */
adminRouter.get('/creators/pending', async (_req, res) => {
  try {
    const pending = await prisma.creatorApplication.findMany({
      where: { status: 'PENDING_VERIFICATION' },
      include: {
        user: {
          include: {
            profile: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return res.json({
      success: true,
      count: pending.length,
      data: pending,
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * POST /api/v1/admin/creators/:applicationId/approve
 * Admin approves a creator application -> Creator becomes active & visible in App
 */
adminRouter.post('/creators/:applicationId/approve', async (req, res) => {
  try {
    const { applicationId } = req.params;

    const application = await prisma.creatorApplication.findUnique({
      where: { id: applicationId },
      include: { user: true },
    });

    if (!application) {
      return res.status(404).json({ success: false, error: 'Creator application not found' });
    }

    // 1. Mark Application as APPROVED
    const updatedApp = await prisma.creatorApplication.update({
      where: { id: applicationId },
      data: {
        status: 'APPROVED',
        reviewedAt: new Date(),
      },
    });

    // 2. Create or Update Creator in the Database
    const creator = await prisma.creator.upsert({
      where: { userId: application.userId },
      update: {
        isActive: true,
        isApproved: true,
        profession: application.profession,
        videoCallPrice: application.videoCallPrice,
        voiceCallPrice: application.voiceCallPrice,
        languages: application.languages,
        tags: application.tags,
        age: application.age,
      },
      create: {
        userId: application.userId,
        isActive: true,
        isApproved: true,
        profession: application.profession,
        videoCallPrice: application.videoCallPrice,
        voiceCallPrice: application.voiceCallPrice,
        languages: application.languages,
        tags: application.tags,
        age: application.age,
        tier: 'VIP',
        rating: 5.0,
        reviewCount: 1,
      },
    });

    // 3. Update User Role & Verification status
    await prisma.user.update({
      where: { id: application.userId },
      data: {
        role: 'CREATOR',
        isVerified: true,
      },
    });

    // 4. Update User Profile with legalName and photoUrl if present
    if (application.legalName || application.photoUrl) {
      await prisma.userProfile.updateMany({
        where: { userId: application.userId },
        data: {
          ...(application.legalName && { name: application.legalName }),
          ...(application.photoUrl && { avatarUrl: application.photoUrl }),
          ...(application.bio && { bio: application.bio }),
        },
      });
    }

    console.log(`[ADMIN] Creator application ${applicationId} approved. Creator ${creator.id} is now LIVE on app!`);

    return res.json({
      success: true,
      message: 'Creator application approved! Profile is now active on mobile app.',
      creator,
      application: updatedApp,
    });
  } catch (error: any) {
    console.error('[ADMIN] Approve error:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * POST /api/v1/admin/creators/:applicationId/reject
 * Admin rejects a creator application with reason
 */
adminRouter.post('/creators/:applicationId/reject', async (req, res) => {
  try {
    const { applicationId } = req.params;
    const { reason } = req.body;

    const application = await prisma.creatorApplication.update({
      where: { id: applicationId },
      data: {
        status: 'REJECTED',
        rejectionReason: reason || 'Application did not meet verification criteria',
        reviewedAt: new Date(),
      },
    });

    return res.json({
      success: true,
      message: 'Creator application rejected',
      application,
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * GET /api/v1/admin/creators
 * Get all creators for directory management
 */
adminRouter.get('/creators', async (_req, res) => {
  try {
    const creators = await prisma.creator.findMany({
      include: {
        user: {
          include: {
            profile: true,
            wallet: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    const formatted = creators.map((c) => ({
      id: c.id,
      userId: c.userId,
      name: c.user.profile?.name || 'Creator',
      age: c.age || 23,
      photoUrl: c.user.profile?.avatarUrl || '',
      profession: c.profession,
      videoCallPrice: c.videoCallPrice,
      voiceCallPrice: c.voiceCallPrice,
      isActive: c.isActive,
      isApproved: c.isApproved,
      isFeatured: c.isFeatured,
      isOnline: c.isOnline,
      rating: Number(c.rating),
      reviewCount: c.reviewCount,
      languages: c.languages,
      tags: c.tags,
      email: c.user.email || 'N/A',
      phone: c.user.phone || 'N/A',
      walletBalance: c.user.wallet?.balance || 0,
      createdAt: c.createdAt,
    }));

    return res.json({
      success: true,
      count: formatted.length,
      data: formatted,
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * POST /api/v1/admin/creators/create-direct
 * Directly add a new creator from Admin Dashboard
 */
adminRouter.post('/creators/create-direct', async (req, res) => {
  try {
    const {
      name,
      age,
      profession,
      photoUrl,
      videoCallPrice,
      voiceCallPrice,
      bio,
      email,
      phone,
      isActive,
      isFeatured,
      languages,
      tags,
    } = req.body;

    if (!name || !profession) {
      return res.status(400).json({ success: false, error: 'Name and profession are required' });
    }

    // Create a new user record for this creator
    const user = await prisma.user.create({
      data: {
        email: email ? String(email).trim().toLowerCase() : null,
        phone: phone ? String(phone).trim() : null,
        role: 'CREATOR',
        isVerified: true,
        profile: {
          create: {
            name: String(name).trim(),
            bio: bio ? String(bio).trim() : 'Official LinkUp Verified Creator',
            avatarUrl: photoUrl ? String(photoUrl).trim() : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
            isCompleted: true,
            currentStep: 10,
          },
        },
        wallet: {
          create: {
            balance: 500,
          },
        },
        creator: {
          create: {
            age: Number(age) || 24,
            profession: String(profession).trim(),
            videoCallPrice: Number(videoCallPrice) || 500,
            voiceCallPrice: Number(voiceCallPrice) || 300,
            isActive: isActive ?? true,
            isApproved: true,
            isFeatured: isFeatured ?? false,
            languages: languages || ['English', 'Tamil'],
            tags: tags || ['Verified', 'Creator'],
            rating: 4.9,
            reviewCount: 12,
          },
        },
      },
      include: {
        profile: true,
        creator: true,
      },
    });

    return res.status(201).json({
      success: true,
      message: 'New creator added directly and published to app feed',
      data: user,
    });
  } catch (error: any) {
    console.error('[ADMIN] Create direct creator error:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * PUT /api/v1/admin/creators/:creatorId
 * Toggle active/inactive, featured on homepage, or edit details
 */
adminRouter.put('/creators/:creatorId', async (req, res) => {
  try {
    const { creatorId } = req.params;
    const {
      name,
      age,
      profession,
      photoUrl,
      videoCallPrice,
      voiceCallPrice,
      isActive,
      isFeatured,
      bio,
    } = req.body;

    const creator = await prisma.creator.findUnique({
      where: { id: creatorId },
      include: { user: true },
    });

    if (!creator) {
      return res.status(404).json({ success: false, error: 'Creator not found' });
    }

    // Update Creator Table
    const updated = await prisma.creator.update({
      where: { id: creatorId },
      data: {
        ...(typeof isActive === 'boolean' && { isActive }),
        ...(typeof isFeatured === 'boolean' && { isFeatured }),
        ...(profession && { profession: String(profession).trim() }),
        ...(videoCallPrice && { videoCallPrice: Number(videoCallPrice) }),
        ...(voiceCallPrice && { voiceCallPrice: Number(voiceCallPrice) }),
        ...(age && { age: Number(age) }),
      },
    });

    // Update Profile Name / Avatar if provided
    if (name || photoUrl || bio) {
      await prisma.userProfile.updateMany({
        where: { userId: creator.userId },
        data: {
          ...(name && { name: String(name).trim() }),
          ...(photoUrl && { avatarUrl: String(photoUrl).trim() }),
          ...(bio && { bio: String(bio).trim() }),
        },
      });
    }

    return res.json({
      success: true,
      message: 'Creator profile updated successfully',
      creator: updated,
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * DELETE /api/v1/admin/creators/:creatorId
 * Deactivate / remove creator from platform
 */
adminRouter.delete('/creators/:creatorId', async (req, res) => {
  try {
    const { creatorId } = req.params;
    await prisma.creator.update({
      where: { id: creatorId },
      data: { isActive: false, isApproved: false },
    });
    return res.json({ success: true, message: 'Creator deactivated' });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});
