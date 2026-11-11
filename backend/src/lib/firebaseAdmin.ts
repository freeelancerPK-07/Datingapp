import { initializeApp, getApps, cert, type App } from 'firebase-admin/app';
import { getAuth, type DecodedIdToken } from 'firebase-admin/auth';

let firebaseApp: App | null = null;

function getFirebaseAdminApp(): App | null {
  if (firebaseApp) return firebaseApp;
  const existing = getApps();
  if (existing.length > 0) {
    firebaseApp = existing[0];
    return firebaseApp;
  }

  try {
    // 1. Prefer full Service Account JSON env var (FIREBASE_SERVICE_ACCOUNT_JSON)
    const rawJson = (process.env.FIREBASE_SERVICE_ACCOUNT_JSON || '').trim();
    if (rawJson) {
      const parsed = JSON.parse(rawJson);
      if (parsed.private_key && typeof parsed.private_key === 'string') {
        parsed.private_key = parsed.private_key.replace(/\\n/g, '\n');
      }
      firebaseApp = initializeApp({
        credential: cert(parsed),
        projectId: parsed.project_id || 'linkup-b19f5',
      });
      console.log('[FirebaseAdmin] Initialized via FIREBASE_SERVICE_ACCOUNT_JSON');
      return firebaseApp;
    }

    // 2. Fallback to individual env vars
    const clientEmail = (process.env.FIREBASE_CLIENT_EMAIL || '').trim();
    const privateKey = (process.env.FIREBASE_PRIVATE_KEY || '').replace(/\\n/g, '\n').trim();
    const projectId = (process.env.FIREBASE_PROJECT_ID || 'linkup-b19f5').trim();

    if (clientEmail && privateKey) {
      firebaseApp = initializeApp({
        credential: cert({
          projectId,
          clientEmail,
          privateKey,
        }),
        projectId,
      });
      console.log('[FirebaseAdmin] Initialized via FIREBASE_CLIENT_EMAIL / PRIVATE_KEY');
      return firebaseApp;
    }
  } catch (err: any) {
    console.error('[FirebaseAdmin] Initialization failed:', err?.message || err);
  }

  return null;
}

export function isFirebaseAdminConfigured(): boolean {
  return getFirebaseAdminApp() !== null;
}

export async function verifyFirebaseIdToken(idToken: string): Promise<DecodedIdToken | null> {
  const app = getFirebaseAdminApp();
  if (!app) return null;
  try {
    return await getAuth(app).verifyIdToken(idToken);
  } catch (err: any) {
    console.warn('[FirebaseAdmin] ID token verification failed:', err?.message);
    return null;
  }
}

export async function deleteFirebaseUser(params: {
  email?: string | null;
  phone?: string | null;
}): Promise<{ deleted: boolean; reason: string }> {
  const app = getFirebaseAdminApp();
  if (!app) {
    return {
      deleted: false,
      reason: 'FIREBASE_SERVICE_ACCOUNT_JSON_NOT_CONFIGURED',
    };
  }

  const auth = getAuth(app);
  let deletedAny = false;

  try {
    if (params.email && params.email.trim().length > 0) {
      const cleanEmail = params.email.trim().toLowerCase();
      if (cleanEmail) {
        try {
          const fbUser = await auth.getUserByEmail(cleanEmail);
          await auth.deleteUser(fbUser.uid);
          console.log(`[FirebaseAdmin] Deleted Firebase Auth user ${fbUser.uid} (${cleanEmail})`);
          deletedAny = true;
        } catch (err: any) {
          if (err?.code !== 'auth/user-not-found') {
            console.error('[FirebaseAdmin] Error deleting by email:', err?.message);
            return { deleted: false, reason: err?.message || 'firebase-delete-error' };
          }
        }
      }
    }

    if (!deletedAny && params.phone) {
      const cleanPhone = params.phone.trim();
      if (cleanPhone.startsWith('+')) {
        try {
          const fbUser = await auth.getUserByPhoneNumber(cleanPhone);
          await auth.deleteUser(fbUser.uid);
          console.log(`[FirebaseAdmin] Deleted Firebase Auth user ${fbUser.uid} (${cleanPhone})`);
          deletedAny = true;
        } catch (err: any) {
          if (err?.code !== 'auth/user-not-found') {
            console.error('[FirebaseAdmin] Error deleting by phone:', err?.message);
          }
        }
      }
    }

    return deletedAny
      ? { deleted: true, reason: 'deleted' }
      : { deleted: false, reason: 'user-not-found-in-firebase' };
  } catch (err: any) {
    console.error('[FirebaseAdmin] Unexpected error:', err?.message);
    return { deleted: false, reason: err?.message || 'unexpected-error' };
  }
}
