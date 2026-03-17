import { describe, expect, it } from 'vitest';
import { isSupportedGame } from '../src/index';

describe('rules-engine supported games', () => {
  it('supports configured MVP game', () => {
    expect(isSupportedGame('tile_placement_demo')).toBe(true);
  });

  it('rejects unknown game', () => {
    expect(isSupportedGame('unknown_game')).toBe(false);
  });
});
