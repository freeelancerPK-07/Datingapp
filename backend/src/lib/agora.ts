import pkg from 'agora-access-token';
const { RtcTokenBuilder, RtcRole } = pkg as any;

const DEFAULT_AGORA_APP_ID = '07c1a3f8e9fc43a09d9f186c48d556dc';
const DEFAULT_AGORA_APP_CERTIFICATE = '44875f9999944d989c5259698b6f94f2';

export function getAgoraConfig() {
  const envAppId = (process.env.AGORA_APP_ID || '').trim();
  const envCert = (process.env.AGORA_APP_CERTIFICATE || '').trim();

  const appId = envAppId || DEFAULT_AGORA_APP_ID;
  const appCertificate = envAppId ? envCert : (envCert || DEFAULT_AGORA_APP_CERTIFICATE);

  return {
    appId,
    appCertificate,
    isConfigured: appId.length > 0,
    hasCertificate: appCertificate.length > 0,
  };
}

export const AGORA_APP_ID = (process.env.AGORA_APP_ID || DEFAULT_AGORA_APP_ID).trim();

export interface AgoraCallTokens {
  appId: string;
  channelName: string;
  callerToken: string;
  creatorToken: string;
  expiresInSecs: number;
  isConfigured: boolean;
}

/**
 * Generates official Agora RTC token for a channel.
 * - Secured Mode (App ID + Primary Certificate): generates signed RTC token.
 * - Testing Mode (App ID only without Certificate): returns empty string "".
 */
export function generateAgoraTokenForChannel(
  channelName: string,
  uid = 0,
  durationSeconds = 7200
): string {
  const { appId, appCertificate, isConfigured, hasCertificate } = getAgoraConfig();
  if (!isConfigured || !hasCertificate) {
    return '';
  }

  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + durationSeconds;

  return RtcTokenBuilder.buildTokenWithUid(
    appId,
    appCertificate,
    channelName,
    uid,
    RtcRole.PUBLISHER,
    privilegeExpiredTs
  );
}

/**
 * Generates official Agora RTC tokens for both Caller and Creator.
 * Both join with uid = 0 (Agora auto-assigns non-colliding UIDs cleanly).
 */
export function generateAgoraTokens(
  channelName: string,
  callerUid = 0,
  creatorUid = 0,
  durationSeconds = 7200
): AgoraCallTokens {
  const { appId, isConfigured } = getAgoraConfig();
  const callerToken = generateAgoraTokenForChannel(channelName, callerUid, durationSeconds);
  const creatorToken = generateAgoraTokenForChannel(channelName, creatorUid, durationSeconds);

  return {
    appId,
    channelName,
    callerToken,
    creatorToken,
    expiresInSecs: durationSeconds,
    isConfigured,
  };
}
