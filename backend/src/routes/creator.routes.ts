import { Router } from 'express';
import { prisma } from '../lib/prisma.js';

export const creatorRouter = Router();

/**
 * GET /api/v1/creators
 * Get all active creators
 */
creatorRouter.get('/', async (_req, res) => {
  try {
    const creators = await prisma.creator.findMany({
      include: {
        user: {
          include: {
            profile: true,
          },
        },
      },
      orderBy: { rating: 'desc' },
    });

    const formatted = creators.map((c) => ({
      id: c.id,
      userId: c.userId,
      name: c.user.profile?.name || 'Creator',
      age: 23,
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
      location: `${c.user.profile?.city || 'Mumbai'}, India`,
      tags: c.tags,
      languages: c.languages,
    }));

    return res.json({ success: true, count: formatted.length, data: formatted });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
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
      return res.status(404).json({ error: 'Creator not found' });
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
      },
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
});

