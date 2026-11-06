"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AGORA_APP_ID = void 0;
exports.generateAgoraTokens = generateAgoraTokens;
const agora_access_token_1 = __importDefault(require("agora-access-token"));
const { RtcTokenBuilder, RtcRole } = agora_access_token_1.default;
exports.AGORA_APP_ID = process.env.AGORA_APP_ID || '07c1a3f8e9fc43a09d9f186c48d556dc';
const AGORA_APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE || '44875f9999944d989c5259698b6f94f2';
/**
 * Generates official Agora RTC tokens for both Caller and Creator.
 * The App Certificate is NEVER sent to the client.
 */
function generateAgoraTokens(channelName, callerUid = 0, creatorUid = 1, durationSeconds = 7200) {
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const privilegeExpiredTs = currentTimestamp + durationSeconds;
    const callerToken = RtcTokenBuilder.buildTokenWithUid(exports.AGORA_APP_ID, AGORA_APP_CERTIFICATE, channelName, callerUid, RtcRole.PUBLISHER, privilegeExpiredTs);
    const creatorToken = RtcTokenBuilder.buildTokenWithUid(exports.AGORA_APP_ID, AGORA_APP_CERTIFICATE, channelName, creatorUid, RtcRole.PUBLISHER, privilegeExpiredTs);
    return {
        appId: exports.AGORA_APP_ID,
        channelName,
        callerToken,
        creatorToken,
        expiresInSecs: durationSeconds,
    };
}
