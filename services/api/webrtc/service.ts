import type { GroupCallConfig, WebRtcTokenRequest } from './controller';

export interface WebRtcService {
  createToken(input: WebRtcTokenRequest): { token: string; expiresAt: string; roomId: string };
  groupConfig(roomId: string): GroupCallConfig;
}
