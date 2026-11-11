import pkg from 'agora-access-token';
const { RtcTokenBuilder, RtcRole } = pkg as any;

const PLACEHOLDER_APP_ID = '07c1a3f8e9fc43a09d9f186c48d556dc';
const PLACEHOLDER_CERT = '44875f9999944d989c5259698b6f94f2';

export function getAgoraConfig() {
  const rawAppId = (process.env.AGORA_APP_ID || '').trim();
  const rawCert = (process.env.AGORA_APP_CERTIFICATE || '').trim();

  const isConfigured = rawAppId.length > 0 && rawAppId !== PLACEHOLDER_APP_ID;
  const hasCertificate = rawCert.length > 0 && rawCert !== PLACEHOLDER_CERT;

  return {
    appId: rawAppId,
    appCertificate: hasCertificate ? rawCert : '',
    isConfigured,
    hasCertificate,
  };
}

export const AGORA_APP_ID = (process.env.AGORA_APP_ID || '').trim();

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
 * - If App Certificate is configured (Secured Mode): generates signed RTC token.
 * - If App Certificate is empty (Testing Mode - App ID only): returns empty string "" as Agora expects.
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
