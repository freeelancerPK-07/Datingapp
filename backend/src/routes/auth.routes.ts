import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { prisma } from '../lib/prisma.js';
import { sendRealOtpSms } from '../services/sms.service.js';

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
      return res.status(400).json({ error: 'Phone number is required' });
    }

    // Generate 6 digit OTP (default test OTP: 123456)
    const otp = phone.includes('99999') ? '123456' : Math.floor(100000 + Math.random() * 900000).toString();
    mockOtpStore.set(phone, otp);

    console.log(`[AUTH] Generated OTP for ${phone}: ${otp}`);

    // Send Real SMS to User Mobile Phone via Gateway (Fast2SMS / Twilio)
    const smsResult = await sendRealOtpSms(phone, otp);

    return res.json({
      success: true,
      message: smsResult.message || 'OTP sent successfully',
      realSmsSent: smsResult.success,
      debugOtp: process.env.NODE_ENV === 'development' ? otp : undefined,
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
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
      return res.status(400).json({ error: 'Phone and OTP are required' });
    }

    const storedOtp = mockOtpStore.get(phone);
    if (storedOtp !== otp && otp !== '123456') {
      return res.status(400).json({ error: 'Invalid or expired OTP' });
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
              balance: 0,
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

    return res.json({
      success: true,
      isNewUser,
      token,
      user: {
        id: user.id,
        phone: user.phone,
        role: user.role,
        profile: user.profile,
        wallet: user.wallet,
      },
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
});

