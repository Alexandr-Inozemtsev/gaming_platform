export const GAME_DEFINITIONS = [
  { id: 'big_walker_demo', title: 'Большая бродилка', genre: 'fairy_travel' },
  { id: 'tile_placement_demo', title: 'Tile Placement Demo', genre: 'abstract' },
  { id: 'roll_and_write_demo', title: 'Roll & Write Demo', genre: 'dice' }
];

export const SUPPORTED_GAMES = GAME_DEFINITIONS.map((item) => item.id).filter((id) => id !== 'big_walker_demo');

export const createInitialGameState = (gameId, players, seed = 1, { rng } = {}) => {
  if (gameId === 'tile_placement_demo') {
    return {
      gameId,
      size: 4,
      grid: Array.from({ length: 4 }, () => Array.from({ length: 4 }, () => null)),
      hands: Object.fromEntries(players.map((p, idx) => [p, idx % 2 === 0 ? 'A' : 'B'])),
      seed,
      turn: 0
    };
  }

  if (gameId === 'roll_and_write_demo') {
    const random = rng ? rng(seed) : () => 0.5;
    return {
      gameId,
      size: 5,
      sheet: Object.fromEntries(players.map((p) => [p, Array.from({ length: 5 }, () => Array.from({ length: 5 }, () => 0))])),
      dice: [1 + Math.floor(random() * 6), 1 + Math.floor(random() * 6)],
      seed,
      turn: 0
    };
  }

  throw new Error('UNSUPPORTED_GAME');
};
