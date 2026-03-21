export interface ModuleDescriptor {
  name: string;
  responsibility: string;
}

export const MODULE_DESCRIPTOR: ModuleDescriptor = {
  name: 'LeaderboardModule',
  responsibility: 'global all-time and weekly leaderboard APIs'
};
