import { Router } from 'express';
import { prisma } from '../lib/prisma.js';
import { deleteUserPermanently } from '../lib/userCleanup.js';

export const profileRouter = Router();

/**
 * GET /api/v1/profile/me?userId=...
 * Fetch user's profile and wallet
 */
profileRouter.get('/me', async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }

    const user = await prisma.user.findUnique({
      where: { id: String(userId) },
      include: {
        profile: true,
        wallet: true,
      },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    return res.json({
      success: true,
      user: {
        id: user.id,
        phone: user.phone,
        email: user.email,
        role: user.role,
        isVerified: user.isVerified,
        profile: user.profile,
        wallet: user.wallet,
      },
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
});

/**
 * PUT /api/v1/profile/onboarding
 * Save progressive onboarding data (10 steps)
 */
profileRouter.put('/onboarding', async (req, res) => {
  try {
    const {
      userId,
      name,
      bio,
      city,
      state,
      country,
      avatarUrl,
      galleryPhotos,
      interests,
      languages,
      currentStep,
      isCompleted,
    } = req.body;

    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }

    const profile = await prisma.userProfile.upsert({
      where: { userId },
      update: {
        ...(name !== undefined && { name }),
        ...(bio !== undefined && { bio }),
        ...(city !== undefined && { city }),
        ...(state !== undefined && { state }),
        ...(country !== undefined && { country }),
        ...(avatarUrl !== undefined && { avatarUrl }),
        ...(galleryPhotos !== undefined && { galleryPhotos }),
        ...(interests !== undefined && { interests }),
        ...(languages !== undefined && { languages }),
        ...(currentStep !== undefined && { currentStep }),
        ...(isCompleted !== undefined && { isCompleted }),
      },
      create: {
        userId,
        name: name || '',
        bio: bio || '',
        city: city || '',
        state: state || '',
        country: country || 'India',
        avatarUrl: avatarUrl || '',
        galleryPhotos: galleryPhotos || [],
        interests: interests || [],
        languages: languages || [],
        currentStep: currentStep || 1,
        isCompleted: isCompleted || false,
      },
    });

    return res.json({ success: true, profile });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
});

/**
 * DELETE /api/v1/profile/delete-account
 * User permanently deletes their own account from the mobile app
 */
profileRouter.delete('/delete-account', async (req, res) => {
  try {
    const { userId } = req.body;
    if (!userId) {
      return res.status(400).json({ success: false, error: 'userId is required' });
    }

    const success = await deleteUserPermanently(String(userId));
    if (!success) {
      return res.status(404).json({ success: false, error: 'User not found in database' });
    }

    return res.json({
      success: true,
      message: 'Your account and all associated data have been permanently deleted from database.',
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});
