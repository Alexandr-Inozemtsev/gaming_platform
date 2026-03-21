import type { PublishEventRequest, QueryEventRequest } from './controller';

export interface AnalyticsService {
  publish(input: PublishEventRequest): { ok: true; queued: { id: string } };
  query(input: QueryEventRequest): Array<Record<string, unknown>>;
}
