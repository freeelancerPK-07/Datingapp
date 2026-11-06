"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.adminRouter = void 0;
const express_1 = require("express");
const prisma_js_1 = require("../lib/prisma.js");
const userCleanup_js_1 = require("../lib/userCleanup.js");
exports.adminRouter = (0, express_1.Router)();
// =============================================================================
// COLUMN 1: WALLET & APP SETTINGS
// =============================================================================
/**
 * GET /api/v1/admin/settings
 * Retrieve global app settings: Freeze Balance, Video Connection Switch, Payment UPI
 */
exports.adminRouter.get('/settings', async (_req, res) => {
    try {
        const settings = await prisma_js_1.prisma.adminSetting.upsert({
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
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * PUT /api/v1/admin/settings
 * Update global app settings
 */
exports.adminRouter.put('/settings', async (req, res) => {
    try {
        const { isFreezeBalance, isVideoConnectionEnabled, paymentUpiId } = req.body;
        const settings = await prisma_js_1.prisma.adminSetting.upsert({
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
    }
    catch (error) {
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
exports.adminRouter.get('/creators/pending', async (_req, res) => {
    try {
        const pending = await prisma_js_1.prisma.creatorApplication.findMany({
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
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * POST /api/v1/admin/creators/:applicationId/approve
 * Admin approves a creator application -> Creator becomes active & visible in App
 */
exports.adminRouter.post('/creators/:applicationId/approve', async (req, res) => {
    try {
        const { applicationId } = req.params;
        const application = await prisma_js_1.prisma.creatorApplication.findUnique({
            where: { id: applicationId },
            include: { user: true },
        });
        if (!application) {
            return res.status(404).json({ success: false, error: 'Creator application not found' });
        }
        // 1. Mark Application as APPROVED
        const updatedApp = await prisma_js_1.prisma.creatorApplication.update({
            where: { id: applicationId },
            data: {
                status: 'APPROVED',
                reviewedAt: new Date(),
            },
        });
        // 2. Create or Update Creator in the Database
        const creator = await prisma_js_1.prisma.creator.upsert({
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
        await prisma_js_1.prisma.user.update({
            where: { id: application.userId },
            data: {
                role: 'CREATOR',
                isVerified: true,
            },
        });
        // 4. Update User Profile with legalName, photoUrl, and galleryPhotos
        const userProf = await prisma_js_1.prisma.userProfile.findUnique({ where: { userId: application.userId } });
        const existingGallery = userProf?.galleryPhotos || [];
        const appPhoto = application.photoUrl;
        const finalGallery = existingGallery.length > 0 ? existingGallery : (appPhoto ? [appPhoto] : []);
        await prisma_js_1.prisma.userProfile.updateMany({
            where: { userId: application.userId },
            data: {
                ...(application.legalName && { name: application.legalName }),
                ...(application.photoUrl && { avatarUrl: application.photoUrl }),
                ...(application.bio && { bio: application.bio }),
                galleryPhotos: finalGallery,
            },
        });
        console.log(`[ADMIN] Creator application ${applicationId} approved. Creator ${creator.id} is now LIVE on app!`);
        return res.json({
            success: true,
            message: 'Creator application approved! Profile is now active on mobile app.',
            creator,
            application: updatedApp,
        });
    }
    catch (error) {
        console.error('[ADMIN] Approve error:', error);
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * POST /api/v1/admin/creators/:applicationId/reject
 * Admin rejects a creator application with reason
 */
exports.adminRouter.post('/creators/:applicationId/reject', async (req, res) => {
    try {
        const { applicationId } = req.params;
        const { reason } = req.body;
        const application = await prisma_js_1.prisma.creatorApplication.update({
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
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * GET /api/v1/admin/creators
 * Get all creators for directory management
 */
exports.adminRouter.get('/creators', async (_req, res) => {
    try {
        const creators = await prisma_js_1.prisma.creator.findMany({
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
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * POST /api/v1/admin/creators/create-direct
 * Directly add a new creator from Admin Dashboard
 */
exports.adminRouter.post('/creators/create-direct', async (req, res) => {
    try {
        const { name, age, profession, photoUrl, videoCallPrice, voiceCallPrice, bio, email, phone, isActive, isFeatured, languages, tags, } = req.body;
        if (!name || !profession) {
            return res.status(400).json({ success: false, error: 'Name and profession are required' });
        }
        // Create a new user record for this creator
        const user = await prisma_js_1.prisma.user.create({
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
    }
    catch (error) {
        console.error('[ADMIN] Create direct creator error:', error);
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * PUT /api/v1/admin/creators/:creatorId
 * Toggle active/inactive, featured on homepage, or edit details
 */
exports.adminRouter.put('/creators/:creatorId', async (req, res) => {
    try {
        const { creatorId } = req.params;
        const { name, age, profession, photoUrl, videoCallPrice, voiceCallPrice, isActive, isFeatured, bio, } = req.body;
        const creator = await prisma_js_1.prisma.creator.findUnique({
            where: { id: creatorId },
            include: { user: true },
        });
        if (!creator) {
            return res.status(404).json({ success: false, error: 'Creator not found' });
        }
        // Update Creator Table
        const updated = await prisma_js_1.prisma.creator.update({
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
            await prisma_js_1.prisma.userProfile.updateMany({
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
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * DELETE /api/v1/admin/creators/:creatorId
 * Deactivate / remove creator from platform
 */
exports.adminRouter.delete('/creators/:creatorId', async (req, res) => {
    try {
        const { creatorId } = req.params;
        await prisma_js_1.prisma.creator.update({
            where: { id: creatorId },
            data: { isActive: false, isApproved: false },
        });
        return res.json({ success: true, message: 'Creator deactivated' });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * GET /api/v1/admin/overview
 * Real-time SaaS Dashboard statistics & analytics
 */
exports.adminRouter.get('/overview', async (_req, res) => {
    try {
        const todayStart = new Date();
        todayStart.setHours(0, 0, 0, 0);
        const [totalUsers, activeToday, totalCreators, liveCreators, activeCreators, pendingApprovals, totalCalls, completedCalls, diamondsAggregate, revenueAggregate, recentTransactions, recentCalls,] = await Promise.all([
            prisma_js_1.prisma.user.count(),
            prisma_js_1.prisma.user.count({ where: { updatedAt: { gte: todayStart } } }),
            prisma_js_1.prisma.creator.count(),
            prisma_js_1.prisma.creator.count({ where: { isActive: true, isOnline: true } }),
            prisma_js_1.prisma.creator.count({ where: { isActive: true } }),
            prisma_js_1.prisma.creatorApplication.count({ where: { status: 'PENDING_VERIFICATION' } }),
            prisma_js_1.prisma.callSession.count(),
            prisma_js_1.prisma.callSession.count({ where: { status: 'COMPLETED' } }),
            prisma_js_1.prisma.walletTransaction.aggregate({
                _sum: { coins: true },
                where: { type: 'PURCHASE' },
            }),
            prisma_js_1.prisma.walletTransaction.aggregate({
                _sum: { amountInr: true },
                where: { type: 'PURCHASE' },
            }),
            prisma_js_1.prisma.walletTransaction.findMany({
                take: 6,
                orderBy: { createdAt: 'desc' },
                include: {
                    wallet: {
                        include: {
                            user: {
                                include: { profile: true },
                            },
                        },
                    },
                },
            }),
            prisma_js_1.prisma.callSession.findMany({
                take: 6,
                orderBy: { createdAt: 'desc' },
                include: {
                    caller: {
                        include: { profile: true },
                    },
                    creator: {
                        include: {
                            user: {
                                include: { profile: true },
                            },
                        },
                    },
                },
            }),
        ]);
        const totalDiamondsSold = diamondsAggregate._sum.coins || 0;
        const totalRevenue = Number(revenueAggregate._sum.amountInr || 0);
        return res.json({
            success: true,
            data: {
                stats: {
                    totalUsers,
                    activeToday: activeToday || Math.min(totalUsers, Math.max(1, Math.round(totalUsers * 0.4))),
                    totalCreators,
                    activeCreators,
                    inactiveCreators: Math.max(0, totalCreators - activeCreators),
                    liveCreators,
                    totalDiamondsSold,
                    totalRevenue,
                    totalCalls,
                    completedCalls,
                    pendingApprovals,
                },
                recentTransactions: recentTransactions.map((t) => ({
                    id: t.id,
                    userName: t.wallet.user.profile?.name || 'User',
                    userEmail: t.wallet.user.email || t.wallet.user.phone || 'Customer',
                    coins: t.coins,
                    amountInr: Number(t.amountInr || 0),
                    type: t.type,
                    status: t.status,
                    createdAt: t.createdAt,
                    description: t.description,
                })),
                recentCalls: recentCalls.map((c) => ({
                    id: c.id,
                    callerName: c.caller.profile?.name || 'Caller',
                    creatorName: c.creator.user.profile?.name || 'Creator',
                    callType: c.callType,
                    durationSecs: c.durationSecs,
                    durationFormatted: `${Math.floor(c.durationSecs / 60)}m ${c.durationSecs % 60}s`,
                    coins: c.totalCoins,
                    status: c.status,
                    createdAt: c.createdAt,
                })),
            },
        });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * GET /api/v1/admin/users
 * Real Users list with search, filter & wallet balances
 */
exports.adminRouter.get('/users', async (req, res) => {
    try {
        const { q, role, status } = req.query;
        const where = {};
        if (role && role !== 'ALL') {
            where.role = String(role);
        }
        if (status === 'ACTIVE') {
            where.isActive = true;
        }
        else if (status === 'BLOCKED') {
            where.isActive = false;
        }
        if (q) {
            const query = String(q).trim().toLowerCase();
            where.OR = [
                { email: { contains: query, mode: 'insensitive' } },
                { phone: { contains: query, mode: 'insensitive' } },
                { profile: { name: { contains: query, mode: 'insensitive' } } },
            ];
        }
        const users = await prisma_js_1.prisma.user.findMany({
            where,
            include: {
                profile: true,
                wallet: true,
                creator: true,
            },
            orderBy: { createdAt: 'desc' },
            take: 100,
        });
        const formatted = users.map((u) => ({
            id: u.id,
            name: u.profile?.name || (u.role === 'CREATOR' ? 'Creator Account' : 'LinkUp Member'),
            email: u.email || '',
            phone: u.phone || '',
            avatarUrl: u.profile?.avatarUrl || '',
            role: u.role,
            isActive: u.isActive,
            isVerified: u.isVerified,
            walletBalance: u.wallet?.balance || 0,
            createdAt: u.createdAt,
            city: u.profile?.city || 'India',
            isCreator: !!u.creator,
        }));
        return res.json({ success: true, count: formatted.length, data: formatted });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * PUT /api/v1/admin/users/:userId/toggle-status
 * Block / Unblock user
 */
exports.adminRouter.put('/users/:userId/toggle-status', async (req, res) => {
    try {
        const { userId } = req.params;
        const user = await prisma_js_1.prisma.user.findUnique({ where: { id: userId } });
        if (!user) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }
        const updated = await prisma_js_1.prisma.user.update({
            where: { id: userId },
            data: { isActive: !user.isActive },
        });
        return res.json({
            success: true,
            message: updated.isActive ? 'User account unblocked' : 'User account blocked',
            user: updated,
        });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * DELETE /api/v1/admin/users/:userId
 * Admin permanently deletes a user or creator account from PostgreSQL
 */
exports.adminRouter.delete('/users/:userId', async (req, res) => {
    try {
        const { userId } = req.params;
        const success = await (0, userCleanup_js_1.deleteUserPermanently)(userId);
        if (!success) {
            return res.status(404).json({ success: false, error: 'User not found in database' });
        }
        return res.json({
            success: true,
            message: 'Account permanently purged from database and platform.',
        });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * GET /api/v1/admin/transactions
 * Real payment and diamond transaction history
 */
exports.adminRouter.get('/transactions', async (req, res) => {
    try {
        const { status, type } = req.query;
        const where = {};
        if (status && status !== 'ALL')
            where.status = String(status);
        if (type && type !== 'ALL')
            where.type = String(type);
        const transactions = await prisma_js_1.prisma.walletTransaction.findMany({
            where,
            include: {
                wallet: {
                    include: {
                        user: {
                            include: { profile: true },
                        },
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
            take: 100,
        });
        const formatted = transactions.map((t) => ({
            id: t.id,
            userId: t.wallet.userId,
            userName: t.wallet.user.profile?.name || 'LinkUp User',
            userContact: t.wallet.user.phone || t.wallet.user.email || 'N/A',
            coins: t.coins,
            amountInr: Number(t.amountInr || 0),
            type: t.type,
            status: t.status,
            description: t.description || `${t.coins} Diamonds Purchase`,
            referenceId: t.referenceId || `TXN-${t.id.slice(0, 8)}`,
            createdAt: t.createdAt,
        }));
        return res.json({ success: true, count: formatted.length, data: formatted });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
/**
 * GET /api/v1/admin/calls
 * Real video/voice call logs and sessions
 */
exports.adminRouter.get('/calls', async (req, res) => {
    try {
        const { status, callType } = req.query;
        const where = {};
        if (status && status !== 'ALL')
            where.status = String(status);
        if (callType && callType !== 'ALL')
            where.callType = String(callType);
        const calls = await prisma_js_1.prisma.callSession.findMany({
            where,
            include: {
                caller: {
                    include: { profile: true },
                },
                creator: {
                    include: {
                        user: {
                            include: { profile: true },
                        },
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
            take: 100,
        });
        const formatted = calls.map((c) => ({
            id: c.id,
            callerName: c.caller.profile?.name || 'User',
            callerAvatar: c.caller.profile?.avatarUrl || '',
            creatorName: c.creator.user.profile?.name || 'Creator',
            creatorAvatar: c.creator.user.profile?.avatarUrl || '',
            callType: c.callType,
            durationSecs: c.durationSecs,
            durationFormatted: `${Math.floor(c.durationSecs / 60)}m ${c.durationSecs % 60}s`,
            coins: c.totalCoins,
            ratePerMin: c.ratePerMin,
            status: c.status,
            createdAt: c.createdAt,
            agoraChannel: c.agoraChannel,
        }));
        return res.json({ success: true, count: formatted.length, data: formatted });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
