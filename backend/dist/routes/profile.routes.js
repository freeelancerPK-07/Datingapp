"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.profileRouter = void 0;
const express_1 = require("express");
const prisma_js_1 = require("../lib/prisma.js");
const userCleanup_js_1 = require("../lib/userCleanup.js");
exports.profileRouter = (0, express_1.Router)();
/**
 * GET /api/v1/profile/me?userId=...
 * Fetch user's profile and wallet
 */
exports.profileRouter.get('/me', async (req, res) => {
    try {
        const { userId } = req.query;
        if (!userId) {
            return res.status(400).json({ error: 'userId is required' });
        }
        const user = await prisma_js_1.prisma.user.findUnique({
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
    }
    catch (error) {
        return res.status(500).json({ error: error.message });
    }
});
/**
 * PUT /api/v1/profile/onboarding
 * Save progressive onboarding data (10 steps)
 */
exports.profileRouter.put('/onboarding', async (req, res) => {
    try {
        const { userId, name, bio, city, state, country, avatarUrl, galleryPhotos, interests, languages, currentStep, isCompleted, } = req.body;
        if (!userId) {
            return res.status(400).json({ error: 'userId is required' });
        }
        const profile = await prisma_js_1.prisma.userProfile.upsert({
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
    }
    catch (error) {
        return res.status(500).json({ error: error.message });
    }
});
/**
 * DELETE /api/v1/profile/delete-account
 * User permanently deletes their own account from the mobile app
 */
exports.profileRouter.delete('/delete-account', async (req, res) => {
    try {
        const { userId } = req.body;
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }
        const success = await (0, userCleanup_js_1.deleteUserPermanently)(String(userId));
        if (!success) {
            return res.status(404).json({ success: false, error: 'User not found in database' });
        }
        return res.json({
            success: true,
            message: 'Your account and all associated data have been permanently deleted from database.',
        });
    }
    catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});
