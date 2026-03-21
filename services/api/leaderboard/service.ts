import type { LeaderboardPeriod, LeaderboardRow } from './controller';

export interface LeaderboardService {
  get(period: LeaderboardPeriod): LeaderboardRow[];
}
