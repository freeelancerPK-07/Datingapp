"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.creatorRouter = void 0;
const express_1 = require("express");
const crypto_1 = __importDefault(require("crypto"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const prisma_js_1 = require("../lib/prisma.js");
exports.creatorRouter = (0, express_1.Router)();
/**
 * GET /api/v1/creators
 * Get all active, approved creators for the home feed
 */
exports.creatorRouter.get('/', async (_req, res) => {
    try {
        const creators = await prisma_js_1.prisma.creator.findMany({
            where: {
                isActive: true,
                isApproved: true,
            },
            include: {
                user: {
                    include: {
                        profile: true,
                        creatorApplications: {
                            orderBy: { createdAt: 'desc' },
                            take: 1,
                        },
                    },
                },
            },
            orderBy: [
                { isFeatured: 'desc' },
                { rating: 'desc' },
                { createdAt: 'desc' },
            ],
        });
        const formatted = creators
            .map((c) => {
            const gallery = c.user.profile?.galleryPhotos || [];
            const photo = c.user.profile?.avatarUrl || c.user.creatorApplications?.[0]?.photoUrl || (gallery.length > 0 ? gallery[0] : '');
            const allPhotos = gallery.length > 0 ? gallery : (photo ? [photo] : []);
            return {
                id: c.id,
                userId: c.userId,
                name: c.user.profile?.name || c.user.creatorApplications?.[0]?.legalName || 'Creator',
                age: c.age || 23,
                photoUrl: photo,
                galleryPhotos: allPhotos,
                isOnline: c.isOnline,
                isVerified: c.user.isVerified,
                bio: c.user.profile?.bio || c.user.creatorApplications?.[0]?.bio || '',
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
            };
        })
            .filter((c) => c.photoUrl.trim().length > 0);
        return res.json({ success: true, count: formatted.length, data: formatted });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * GET /api/v1/creators/application-status
 * Check current user's creator application status
 */
exports.creatorRouter.get('/application-status', async (req, res) => {
    try {
        const { userId } = req.query;
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }
        const creator = await prisma_js_1.prisma.creator.findUnique({
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
        const application = await prisma_js_1.prisma.creatorApplication.findFirst({
            where: { userId: String(userId) },
            orderBy: { createdAt: 'desc' },
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
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * GET /api/v1/creators/:id
 * Get single creator profile
 */
exports.creatorRouter.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const creator = await prisma_js_1.prisma.creator.findUnique({
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
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * POST /api/v1/creators/apply
 * User applies to become a Creator -> Enters PENDING_VERIFICATION queue for Admin approval
 */
exports.creatorRouter.post('/apply', async (req, res) => {
    try {
        const { userId, legalName, age = 21, profession = 'Lifestyle & Dating', bio, photoUrl, galleryPhotos = [], govtIdType = 'Aadhaar Card', govtIdFrontUrl, govtIdBackUrl, selfieUrl, socialHandle, payoutUpiId, videoCallPrice = 500, voiceCallPrice = 300, languages = ['English', 'Tamil'], tags = ['Lifestyle', 'Dating'], subscriptionPlan = 'MONTHLY_299', } = req.body;
        let targetUserId = userId;
        const authHeader = req.headers.authorization;
        if (authHeader && authHeader.startsWith('Bearer ')) {
            try {
                const decoded = jsonwebtoken_1.default.verify(authHeader.substring(7), process.env.JWT_SECRET || 'linkup_super_secret_jwt_key_2026_secured');
                if (decoded?.userId) {
                    targetUserId = decoded.userId;
                }
            }
            catch (_) { }
        }
        const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(targetUserId);
        if (!isUuid) {
            const existing = await prisma_js_1.prisma.user.findFirst({
                include: { profile: true },
                orderBy: { createdAt: 'desc' },
            });
            targetUserId = existing ? existing.id : crypto_1.default.randomUUID();
        }
        let user = await prisma_js_1.prisma.user.findUnique({
            where: { id: targetUserId },
            include: { profile: true },
        });
        if (!user) {
            user = await prisma_js_1.prisma.user.create({
                data: {
                    id: targetUserId,
                    phone: `+91${Math.floor(6000000000 + Math.random() * 3999999999)}`,
                    role: 'USER',
                    profile: {
                        create: {
                            name: legalName || 'Creator Applicant',
                            bio: bio || '',
                            avatarUrl: photoUrl || '',
                            galleryPhotos: Array.isArray(galleryPhotos) ? galleryPhotos.filter(Boolean) : [],
                        },
                    },
                },
                include: { profile: true },
            });
        }
        const existingApp = await prisma_js_1.prisma.creatorApplication.findFirst({
            where: { userId: targetUserId },
            orderBy: { createdAt: 'desc' },
        });
        const appData = {
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
        };
        const application = existingApp
            ? await prisma_js_1.prisma.creatorApplication.update({
                where: { id: existingApp.id },
                data: appData,
            })
            : await prisma_js_1.prisma.creatorApplication.create({
                data: {
                    userId: targetUserId,
                    ...appData,
                },
            });
        const parsedGallery = Array.isArray(galleryPhotos) ? galleryPhotos.filter(Boolean) : [];
        if (bio || photoUrl || parsedGallery.length > 0) {
            await prisma_js_1.prisma.userProfile.updateMany({
                where: { userId: targetUserId },
                data: {
                    ...(bio && { bio }),
                    ...(photoUrl && { avatarUrl: photoUrl }),
                    ...(parsedGallery.length > 0 && { galleryPhotos: parsedGallery }),
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
    }
    catch (error) {
        console.error('[CREATOR] Application error:', error);
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * POST /api/v1/creators/register
 * Legacy direct registration fallback
 */
exports.creatorRouter.post('/register', async (req, res) => {
    try {
        const { userId, profession = 'Creator', videoCallPrice = 500, voiceCallPrice = 300, photoPrice = 200, tier = 'VIP', tags = ['Lifestyle', 'Creator'], languages = ['English', 'Tamil'], bio, } = req.body;
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }
        let user = await prisma_js_1.prisma.user.findUnique({ where: { id: userId } });
        if (!user) {
            user = await prisma_js_1.prisma.user.create({
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
        const creator = await prisma_js_1.prisma.creator.upsert({
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
        await prisma_js_1.prisma.user.update({
            where: { id: userId },
            data: { role: 'CREATOR', isVerified: true },
        });
        return res.json({
            success: true,
            message: 'Successfully registered as a Creator!',
            creator,
        });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * POST /api/v1/creators/toggle-online
 */
exports.creatorRouter.post('/toggle-online', async (req, res) => {
    try {
        const { userId, isOnline } = req.body;
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }
        const creator = await prisma_js_1.prisma.creator.update({
            where: { userId },
            data: { isOnline: Boolean(isOnline) },
        });
        return res.json({ success: true, isOnline: creator.isOnline });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * PUT /api/v1/creators/rates
 * Creator updates their own rates
 */
exports.creatorRouter.put('/rates', async (req, res) => {
    try {
        const { userId, videoCallPrice, voiceCallPrice, photoPrice } = req.body;
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }
        const creator = await prisma_js_1.prisma.creator.update({
            where: { userId },
            data: {
                ...(videoCallPrice !== undefined && { videoCallPrice: Number(videoCallPrice) }),
                ...(voiceCallPrice !== undefined && { voiceCallPrice: Number(voiceCallPrice) }),
                ...(photoPrice !== undefined && { photoPrice: Number(photoPrice) }),
            },
        });
        return res.json({ success: true, creator });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * GET /api/v1/creators/studio-stats
 * Real-time stats for the Creator Studio: who called, earnings, likes, rates
 */
exports.creatorRouter.get('/studio-stats', async (req, res) => {
    try {
        const { userId } = req.query;
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }
        const creator = await prisma_js_1.prisma.creator.findUnique({
            where: { userId: String(userId) },
            include: {
                user: {
                    include: {
                        profile: true,
                        creatorApplications: {
                            orderBy: { createdAt: 'desc' },
                            take: 1,
                        },
                    },
                },
                incomingCalls: {
                    include: {
                        caller: {
                            include: { profile: true },
                        },
                    },
                    orderBy: { createdAt: 'desc' },
                    take: 30,
                },
            },
        });
        if (!creator) {
            return res.status(404).json({ success: false, error: 'Creator profile not found' });
        }
        const application = creator.user.creatorApplications[0];
        // Compute earnings
        const totalCalls = creator.incomingCalls.length;
        const completedCalls = creator.incomingCalls.filter((c) => c.status === 'COMPLETED');
        const totalDurationSecs = completedCalls.reduce((acc, c) => acc + c.durationSecs, 0);
        const totalCoinsGross = completedCalls.reduce((acc, c) => acc + c.totalCoins, 0);
        const creatorCoinsEarned = Math.round(totalCoinsGross * 0.70); // 70% share
        const totalEarningsInr = (creatorCoinsEarned * 0.50).toFixed(2);
        const callersList = creator.incomingCalls.map((c) => ({
            id: c.id,
            callerId: c.callerId,
            callerName: c.caller.profile?.name || 'LinkUp User',
            callerAvatar: c.caller.profile?.avatarUrl || '',
            callType: c.callType,
            durationSecs: c.durationSecs,
            durationFormatted: `${Math.floor(c.durationSecs / 60)}m ${c.durationSecs % 60}s`,
            coinsEarned: Math.round(c.totalCoins * 0.70),
            status: c.status,
            createdAt: c.createdAt,
        }));
        return res.json({
            success: true,
            data: {
                creatorId: creator.id,
                userId: creator.userId,
                name: creator.user.profile?.name || application?.legalName || 'Creator',
                photoUrl: creator.user.profile?.avatarUrl || application?.photoUrl || '',
                profession: creator.profession,
                isOnline: creator.isOnline,
                tier: creator.tier,
                payoutUpiId: application?.payoutUpiId || '',
                rates: {
                    videoCallPrice: creator.videoCallPrice,
                    voiceCallPrice: creator.voiceCallPrice,
                    photoPrice: creator.photoPrice,
                },
                stats: {
                    totalCalls,
                    completedCalls: completedCalls.length,
                    totalDurationMinutes: Math.round(totalDurationSecs / 60),
                    creatorCoinsEarned,
                    totalEarningsInr,
                    profileLikes: creator.reviewCount * 3 + 15,
                    followers: creator.followers,
                    rating: Number(creator.rating),
                },
                recentCallers: callersList,
            },
        });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
