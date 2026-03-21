export interface WebRtcTokenRequest {
  userId: string;
  roomId: string;
  ttlSec?: number;
}

export interface GroupCallConfig {
  roomId: string;
  maxParticipants: number;
  turnFallbackAfterIceFailures: number;
}
