import { Router } from 'express';
import { prisma } from '../lib/prisma.js';

export const creatorRouter = Router();

/**
 * GET /api/v1/creators
 * Get all active, approved creators for the home feed
 */
creatorRouter.get('/', async (_req, res) => {
  try {
    const creators = await prisma.creator.findMany({
      where: {
        isActive: true,
        isApproved: true,
      },
      include: {
        user: {
          include: {
            profile: true,
          },
        },
      },
      orderBy: [
        { isFeatured: 'desc' },
        { rating: 'desc' },
      ],
    });

    const formatted = creators.map((c) => ({
      id: c.id,
      userId: c.userId,
      name: c.user.profile?.name || 'Creator',
      age: c.age || 23,
      photoUrl: c.user.profile?.avatarUrl || '',
      isOnline: c.isOnline,
      isVerified: c.user.isVerified,
      bio: c.user.profile?.bio || '',
      videoCallPrice: c.videoCallPrice,
      voiceCallPrice: c.voiceCallPrice,
      photoPrice: c.photoPrice,
      rating: Number(c.rating),
      reviewCount: c.reviewCount,
      profession: c.profession,
      followers: c.followers,
      tier: c.tier,
      location: `${c.user.profile?.city || 'Chennai'}, India`,
      tags: c.tags,
      languages: c.languages,
      isFeatured: c.isFeatured,
    }));

    return res.json({ success: true, count: formatted.length, data: formatted });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * GET /api/v1/creators/application-status
 * Check current user's creator application status
 */
creatorRouter.get('/application-status', async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId) {
      return res.status(400).json({ success: false, error: 'userId is required' });
    }

    const creator = await prisma.creator.findUnique({
      where: { userId: String(userId) },
    });

    if (creator && creator.isApproved && creator.isActive) {
      return res.json({
        success: true,
        status: 'APPROVED',
        isApproved: true,
        creator,
      });
    }

    const application = await prisma.creatorApplication.findUnique({
      where: { userId: String(userId) },
    });

    if (!application) {
      return res.json({
        success: true,
        status: 'NOT_APPLIED',
        isApproved: false,
      });
    }

    return res.json({
      success: true,
      status: application.status,
      isApproved: application.status === 'APPROVED',
      rejectionReason: application.rejectionReason,
      application,
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * GET /api/v1/creators/:id
 * Get single creator profile
 */
creatorRouter.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const creator = await prisma.creator.findUnique({
      where: { id },
      include: {
        user: {
          include: { profile: true },
        },
      },
    });

    if (!creator) {
      return res.status(404).json({ success: false, error: 'Creator not found' });
    }

    return res.json({
      success: true,
      data: {
        id: creator.id,
        userId: creator.userId,
        name: creator.user.profile?.name,
        photoUrl: creator.user.profile?.avatarUrl,
        bio: creator.user.profile?.bio,
        videoCallPrice: creator.videoCallPrice,
        voiceCallPrice: creator.voiceCallPrice,
        photoPrice: creator.photoPrice,
        rating: Number(creator.rating),
        reviewCount: creator.reviewCount,
        profession: creator.profession,
        followers: creator.followers,
        tier: creator.tier,
        tags: creator.tags,
        languages: creator.languages,
        isFeatured: creator.isFeatured,
      },
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * POST /api/v1/creators/apply
 * User applies to become a Creator -> Enters PENDING_VERIFICATION queue for Admin approval
 */
creatorRouter.post('/apply', async (req, res) => {
  try {
    const {
      userId,
      legalName,
      age = 21,
      profession = 'Lifestyle & Dating',
      bio,
      photoUrl,
      govtIdType = 'Aadhaar Card',
      govtIdFrontUrl,
      govtIdBackUrl,
      selfieUrl,
      socialHandle,
      payoutUpiId,
      videoCallPrice = 500,
      voiceCallPrice = 300,
      languages = ['English', 'Tamil'],
      tags = ['Lifestyle', 'Dating'],
      subscriptionPlan = 'MONTHLY_299',
    } = req.body;

    if (!userId) {
      return res.status(400).json({ success: false, error: 'userId is required' });
    }

    let user = await prisma.user.findUnique({
      where: { id: userId },
      include: { profile: true },
    });

    if (!user) {
      user = await prisma.user.create({
        data: {
          id: userId,
          phone: `+91${Math.floor(6000000000 + Math.random() * 3999999999)}`,
          role: 'USER',
          profile: {
            create: {
              name: legalName || 'Creator Applicant',
              bio: bio || '',
              avatarUrl: photoUrl || '',
            },
          },
        },
        include: { profile: true },
      });
    }

    const application = await prisma.creatorApplication.upsert({
      where: { userId },
      update: {
        legalName: legalName || user.profile?.name || 'Applicant',
        age: Number(age) || 21,
        profession: String(profession).trim(),
        bio: bio || user.profile?.bio || '',
        photoUrl: photoUrl || user.profile?.avatarUrl || '',
        govtIdType,
        govtIdFrontUrl,
        govtIdBackUrl,
        selfieUrl,
        socialHandle,
        payoutUpiId: payoutUpiId || '',
        videoCallPrice: Number(videoCallPrice) || 500,
        voiceCallPrice: Number(voiceCallPrice) || 300,
        languages: Array.isArray(languages) ? languages : ['English', 'Tamil'],
        tags: Array.isArray(tags) ? tags : ['Lifestyle', 'Dating'],
        subscriptionPlan,
        subscriptionPaid: true,
        status: 'PENDING_VERIFICATION',
        rejectionReason: null,
      },
      create: {
        userId,
        legalName: legalName || user.profile?.name || 'Applicant',
        age: Number(age) || 21,
        profession: String(profession).trim(),
        bio: bio || user.profile?.bio || '',
        photoUrl: photoUrl || user.profile?.avatarUrl || '',
        govtIdType,
        govtIdFrontUrl,
        govtIdBackUrl,
        selfieUrl,
        socialHandle,
        payoutUpiId: payoutUpiId || '',
        videoCallPrice: Number(videoCallPrice) || 500,
        voiceCallPrice: Number(voiceCallPrice) || 300,
        languages: Array.isArray(languages) ? languages : ['English', 'Tamil'],
        tags: Array.isArray(tags) ? tags : ['Lifestyle', 'Dating'],
        subscriptionPlan,
        subscriptionPaid: true,
        status: 'PENDING_VERIFICATION',
      },
    });

    if (bio || photoUrl) {
      await prisma.userProfile.updateMany({
        where: { userId },
        data: {
          ...(bio && { bio }),
          ...(photoUrl && { avatarUrl: photoUrl }),
        },
      });
    }

    console.log(`[CREATOR] Application submitted by ${application.legalName} (${userId}). Sent to Admin Queue.`);

    return res.json({
      success: true,
      status: 'PENDING_VERIFICATION',
      message: 'Application submitted successfully! Your creator profile is now under Admin review.',
      application,
    });
  } catch (error: any) {
    console.error('[CREATOR] Application error:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * POST /api/v1/creators/register
 * Legacy direct registration fallback
 */
creatorRouter.post('/register', async (req, res) => {
  try {
    const {
      userId,
      profession = 'Creator',
      videoCallPrice = 500,
      voiceCallPrice = 300,
      photoPrice = 200,
      tier = 'VIP',
      tags = ['Lifestyle', 'Creator'],
      languages = ['English', 'Tamil'],
      bio,
    } = req.body;

    if (!userId) {
      return res.status(400).json({ success: false, error: 'userId is required' });
    }

    let user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      user = await prisma.user.create({
        data: {
          id: userId,
          phone: `+91${Math.floor(6000000000 + Math.random() * 3999999999)}`,
          role: 'CREATOR',
          profile: {
            create: {
              name: 'Creator Applicant',
              bio: bio || '',
            },
          },
        },
      });
    }

    // Auto-create application and auto-approve for backward compatibility
    const creator = await prisma.creator.upsert({
      where: { userId },
      update: {
        profession,
        videoCallPrice: Number(videoCallPrice),
        voiceCallPrice: Number(voiceCallPrice),
        photoPrice: Number(photoPrice),
        tier,
        tags,
        languages,
        isActive: true,
        isApproved: true,
        isOnline: true,
        isAvailable: true,
      },
      create: {
        userId,
        profession,
        videoCallPrice: Number(videoCallPrice),
        voiceCallPrice: Number(voiceCallPrice),
        photoPrice: Number(photoPrice),
        tier,
        tags,
        languages,
        isActive: true,
        isApproved: true,
        isOnline: true,
        isAvailable: true,
      },
    });

    await prisma.user.update({
      where: { id: userId },
      data: { role: 'CREATOR', isVerified: true },
    });

    return res.json({
      success: true,
      message: 'Successfully registered as a Creator!',
      creator,
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * POST /api/v1/creators/toggle-online
 */
creatorRouter.post('/toggle-online', async (req, res) => {
  try {
    const { userId, isOnline } = req.body;
    if (!userId) {
      return res.status(400).json({ success: false, error: 'userId is required' });
    }

    const creator = await prisma.creator.update({
      where: { userId },
      data: { isOnline: Boolean(isOnline) },
    });

    return res.json({ success: true, isOnline: creator.isOnline });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});
