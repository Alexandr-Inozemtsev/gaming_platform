import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';

test('p2 e2e: campaign -> match finish -> leaderboard + queue', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'en' } });
  const u1 = app.auth.register({ email: 'p2e2e_u1@test.dev', password: 'secret01' });
  const u2 = app.auth.register({ email: 'p2e2e_u2@test.dev', password: 'secret02' });

  const campaign = app.campaigns.create({ name: 'Dungeon Crawl', levels: [{ gameId: 'tile_placement_demo' }] });
  const started = app.campaigns.start({ campaignId: campaign.id, players: [u1.id, u2.id] });
  const live = app.state.matches.find((row) => row.id === started.match.id);
  live.maxMoves = 2;

  app.matches.move({ matchId: live.id, playerId: u1.id, action: 'place', moveId: 'e2e-1', payload: { row: 0, col: 0 } });
  app.matches.move({ matchId: live.id, playerId: u2.id, action: 'place', moveId: 'e2e-2', payload: { row: 0, col: 1 } });

  const board = app.leaderboards.get({ period: 'all-time' });
  assert.equal(Array.isArray(board), true);

  const publish = app.analytics.publish({ topic: 'ab.variant', payload: { variantId: 'B' } });
  assert.equal(publish.ok, true);
  const queue = app.analytics.queryQueue({ topic: 'ab.variant' });
  assert.equal(queue.length > 0, true);
});
