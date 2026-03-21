export type LeaderboardPeriod = 'all-time' | 'weekly';

export interface LeaderboardRow {
  userId: string;
  score: number;
}
