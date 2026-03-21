import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';

test('campaign create/start and leaderboard flow', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'en' } });
  const u1 = app.auth.register({ email: 'campaign_u1@test.dev', password: 'secret01' });
  const u2 = app.auth.register({ email: 'campaign_u2@test.dev', password: 'secret02' });

  const campaign = app.campaigns.create({
    name: 'Save the Plumpkin',
    levels: [{ gameId: 'tile_placement_demo' }]
  });

  const started = app.campaigns.start({ campaignId: campaign.id, players: [u1.id, u2.id] });
  assert.equal(started.match.campaignId, campaign.id);
  const live = app.state.matches.find((row) => row.id === started.match.id);
  live.maxMoves = 2;

  app.matches.move({ matchId: live.id, playerId: u1.id, action: 'place', moveId: 'cp-1', payload: { row: 0, col: 0 } });
  const finalState = app.matches.move({ matchId: live.id, playerId: u2.id, action: 'place', moveId: 'cp-2', payload: { row: 0, col: 1 } });
  assert.equal(finalState.status, 'finished');

  const board = app.leaderboards.get({ period: 'all-time' });
  assert.equal(Array.isArray(board), true);
  if (finalState.winner) assert.equal(board.some((row) => row.userId === finalState.winner), true);
});
