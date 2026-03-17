export type GameCode = 'tile_placement_demo' | 'roll_and_write_demo';

const supportedGames: GameCode[] = ['tile_placement_demo', 'roll_and_write_demo'];

export const isSupportedGame = (game: string): game is GameCode => {
  return supportedGames.includes(game as GameCode);
};
