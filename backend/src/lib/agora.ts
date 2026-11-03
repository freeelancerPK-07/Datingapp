import pkg from 'agora-access-token';
const { RtcTokenBuilder, RtcRole } = pkg as any;

export const AGORA_APP_ID = process.env.AGORA_APP_ID || '07c1a3f8e9fc43a09d9f186c48d556dc';
const AGORA_APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE || '44875f9999944d989c5259698b6f94f2';

export interface AgoraCallTokens {
  appId: string;
  channelName: string;
  callerToken: string;
  creatorToken: string;
  expiresInSecs: number;
}

/**
 * Generates official Agora RTC tokens for both Caller and Creator.
 * The App Certificate is NEVER sent to the client.
 */
export function generateAgoraTokens(
  channelName: string,
  callerUid = 0,
  creatorUid = 1,
  durationSeconds = 7200
): AgoraCallTokens {
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + durationSeconds;

  const callerToken = RtcTokenBuilder.buildTokenWithUid(
    AGORA_APP_ID,
    AGORA_APP_CERTIFICATE,
    channelName,
    callerUid,
    RtcRole.PUBLISHER,
    privilegeExpiredTs
  );

  const creatorToken = RtcTokenBuilder.buildTokenWithUid(
    AGORA_APP_ID,
    AGORA_APP_CERTIFICATE,
    channelName,
    creatorUid,
    RtcRole.PUBLISHER,
    privilegeExpiredTs
  );

  return {
    appId: AGORA_APP_ID,
    channelName,
    callerToken,
    creatorToken,
    expiresInSecs: durationSeconds,
  };
}

