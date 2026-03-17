export interface RealtimeEvent {
  channel: string;
  payload: Record<string, unknown>;
}

export const createPingEvent = (): RealtimeEvent => ({
  channel: 'system.ping',
  payload: { ts: Date.now() }
});
