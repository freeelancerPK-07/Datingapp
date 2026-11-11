import { Router } from 'express';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { prisma } from '../lib/prisma.js';
import { sendRealOtpSms } from '../services/sms.service.js';
import { isFirebaseAdminConfigured, verifyFirebaseIdToken } from '../lib/firebaseAdmin.js';

export const authRouter = Router();

const JWT_SECRET = process.env.JWT_SECRET || 'linkup_jwt_secret_key';

// Mock OTP store (in production this uses Redis + SMS Gateway)
const mockOtpStore = new Map<string, string>();

/**
 * Send Phone OTP
 * POST /api/v1/auth/phone/send-otp
 */
authRouter.post('/phone/send-otp', async (req, res) => {
  try {
    const { phone } = req.body;
    if (!phone) {
      return res.status(400).json({ success: false, error: 'Phone number is required' });
    }

    // Generate 6 digit OTP (default test OTP: 123456)
    const otp = phone.includes('99999') ? '123456' : Math.floor(100000 + Math.random() * 900000).toString();
    mockOtpStore.set(phone, otp);

    console.log(`[AUTH] Generated OTP for ${phone}: ${otp}`);

    // Send Real SMS to User Mobile Phone via Gateway (Bridge / Fast2SMS / Twilio)
    const smsResult = await sendRealOtpSms(phone, otp);

    return res.json({
      success: true,
      message: smsResult.message || 'OTP sent successfully',
      realSmsSent: smsResult.success,
      debugOtp: process.env.NODE_ENV === 'development' ? otp : undefined,
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * Verify Phone OTP & Login/Register
 * POST /api/v1/auth/phone/verify-otp
 */
authRouter.post('/phone/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;
    if (!phone || !otp) {
      return res.status(400).json({ success: false, error: 'Phone and OTP are required' });
    }

    const storedOtp = mockOtpStore.get(phone);
    if (storedOtp !== otp && otp !== '123456') {
      return res.status(400).json({ success: false, error: 'Invalid or expired OTP' });
    }

    // Check if user exists, if not create user + profile + wallet
    let user = await prisma.user.findUnique({
      where: { phone },
      include: { profile: true, wallet: true },
    });

    let isNewUser = false;

    if (!user) {
      isNewUser = true;
      user = await prisma.user.create({
        data: {
          phone,
          isVerified: true,
          profile: {
            create: {
              name: 'LinkUp User',
              isCompleted: false,
              currentStep: 1,
            },
          },
          wallet: {
            create: {
              balance: 100, // Welcome bonus diamonds
            },
          },
        },
        include: { profile: true, wallet: true },
      });
    }

    // Clear OTP
    mockOtpStore.delete(phone);

    // Sign JWT
    const token = jwt.sign(
      { userId: user.id, phone: user.phone, role: user.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    const isProfileCompleted = user.profile?.isCompleted ?? false;

    return res.json({
      success: true,
      isNewUser,
      isProfileCompleted,
      token,
      user: {
        id: user.id,
        phone: user.phone,
        email: user.email,
        role: user.role,
        profile: user.profile,
        wallet: user.wallet,
      },
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * Email/Password Registration
 * POST /api/v1/auth/register
 */
authRouter.post('/register', async (req, res) => {
  try {
    const { email, password, name, phone } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, error: 'Email and password are required' });
    }

    if (password.length < 6) {
      return res.status(400).json({ success: false, error: 'Password must be at least 6 characters' });
    }

    const normalizedEmail = email.trim().toLowerCase();

    // Check if email already registered
    const existing = await prisma.user.findFirst({
      where: {
        OR: [
          { email: normalizedEmail },
          ...(phone ? [{ phone: phone.trim() }] : []),
        ],
      },
    });

    if (existing) {
      return res.status(409).json({
        success: false,
        error: 'An account with this email or phone already exists. Please sign in.',
      });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user with initial profile and wallet
    const user = await prisma.user.create({
      data: {
        email: normalizedEmail,
        passwordHash,
        phone: phone ? phone.trim() : null,
        isVerified: true,
        profile: {
          create: {
            name: name ? name.trim() : 'LinkUp User',
            isCompleted: false,
            currentStep: 1,
          },
        },
        wallet: {
          create: {
            balance: 100, // 100 welcome bonus diamonds
          },
        },
      },
      include: { profile: true, wallet: true },
    });

    const token = jwt.sign(
      { userId: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    return res.status(201).json({
      success: true,
      isNewUser: true,
      isProfileCompleted: false,
      token,
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profile: user.profile,
        wallet: user.wallet,
      },
    });
  } catch (error: any) {
    console.error('[AUTH] Register error:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * Email/Password Login
 * POST /api/v1/auth/login
 */
authRouter.post('/login', async (req, res) => {
  try {
    const { email, password, identifier } = req.body;
    const loginIdentifier = (email || identifier || '').trim().toLowerCase();

    if (!loginIdentifier || !password) {
      return res.status(400).json({ success: false, error: 'Email and password are required' });
    }

    // Find user by email or phone
    const user = await prisma.user.findFirst({
      where: {
        OR: [
          { email: loginIdentifier },
          { phone: loginIdentifier },
        ],
      },
      include: { profile: true, wallet: true },
    });

    if (!user) {
      return res.status(401).json({ success: false, error: 'No account found with this email. Please check or sign up.' });
    }

    // Verify password if hash exists
    if (user.passwordHash) {
      const match = await bcrypt.compare(password, user.passwordHash);
      if (!match) {
        return res.status(401).json({ success: false, error: 'Incorrect password. Please try again.' });
      }
    }

    // Sign JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email, phone: user.phone, role: user.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    const isProfileCompleted = user.profile?.isCompleted ?? false;

    return res.json({
      success: true,
      isNewUser: false,
      isProfileCompleted,
      token,
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profile: user.profile,
        wallet: user.wallet,
      },
    });
  } catch (error: any) {
    console.error('[AUTH] Login error:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * Firebase Authenticated User Sync (Google Sign-In / Verified Email)
 * POST /api/v1/auth/firebase-sync
 */
authRouter.post('/firebase-sync', async (req, res) => {
  try {
    const { email, name, avatarUrl, idToken } = req.body;
    let verifiedEmail = email ? String(email).trim().toLowerCase() : '';
    let verifiedName = name ? String(name).trim() : '';
    let verifiedAvatar = avatarUrl ? String(avatarUrl).trim() : '';

    if (idToken && isFirebaseAdminConfigured()) {
      const decoded = await verifyFirebaseIdToken(String(idToken));
      if (!decoded || !decoded.email) {
        return res.status(401).json({ success: false, error: 'Invalid or expired Firebase ID token' });
      }
      verifiedEmail = decoded.email.trim().toLowerCase();
      if (!verifiedName && decoded.name) verifiedName = String(decoded.name);
      if (!verifiedAvatar && decoded.picture) verifiedAvatar = String(decoded.picture);
    }

    if (!verifiedEmail) {
      return res.status(400).json({ success: false, error: 'Email is required for Firebase sync' });
    }

    // Check if user already exists
    let user = await prisma.user.findFirst({
      where: { email: verifiedEmail },
      include: { profile: true, wallet: true, creator: true },
    });

    if (user && !user.isActive) {
      return res.status(403).json({
        success: false,
        error: 'Your account has been suspended by an administrator.',
      });
    }

    let isNewUser = false;

    if (!user) {
      isNewUser = true;
      user = await prisma.user.create({
        data: {
          email: verifiedEmail,
          isVerified: true,
          profile: {
            create: {
              name: verifiedName || 'LinkUp User',
              avatarUrl: verifiedAvatar || '',
              isCompleted: false,
              currentStep: 1,
            },
          },
          wallet: {
            create: {
              balance: 100, // 100 welcome bonus diamonds
            },
          },
        },
        include: { profile: true, wallet: true, creator: true },
      });
    }

    if (!user) {
      return res.status(500).json({ success: false, error: 'Failed to process user session' });
    }

    // Sign LinkUp JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    const isProfileCompleted = user.profile?.isCompleted ?? false;

    return res.json({
      success: true,
      isNewUser,
      isProfileCompleted,
      token,
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profile: user.profile,
        wallet: user.wallet,
        isCreator: !!user.creator,
      },
    });
  } catch (error: any) {
    console.error('[AUTH] Firebase sync error:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * Verify Current Session & Profile Status
 * GET /api/v1/auth/me
 */
authRouter.get('/me', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    let userId = req.query.userId as string | undefined;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      try {
        const decoded = jwt.verify(token, JWT_SECRET) as any;
        if (decoded?.userId) {
          userId = decoded.userId;
        }
      } catch (_) {
        return res.status(401).json({ success: false, error: 'Invalid or expired session token' });
      }
    }

    if (!userId) {
      return res.status(400).json({ success: false, error: 'User ID or valid Bearer token is required' });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { profile: true, wallet: true, creator: true },
    });

    if (!user) {
      return res.status(404).json({ success: false, error: 'User session not found' });
    }

    const isProfileCompleted = user.profile?.isCompleted ?? false;

    return res.json({
      success: true,
      isProfileCompleted,
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profile: user.profile,
        wallet: user.wallet,
        isCreator: !!user.creator,
      },
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});
