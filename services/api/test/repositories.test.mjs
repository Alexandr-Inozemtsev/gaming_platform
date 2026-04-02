import test from 'node:test';
import assert from 'node:assert/strict';
import { createInMemoryRepositories } from '../src/repositories/in-memory.mjs';

test('repositories: users and matches basic CRUD wrappers work over state', () => {
  const state = { users: [], matches: [] };
  const repos = createInMemoryRepositories(state);

  repos.users.create({ id: 'u1', email: 'u1@test.dev' });
  assert.equal(repos.users.exists('u1'), true);
  assert.equal(repos.users.findByEmail('u1@test.dev')?.id, 'u1');

  repos.matches.create({ id: 'm1', gameId: 'big_walker_demo' });
  assert.equal(repos.matches.findById('m1')?.gameId, 'big_walker_demo');

  repos.matches.setAll([{ id: 'm2', gameId: 'tile_placement_demo' }]);
  assert.equal(repos.matches.all().length, 1);
  assert.equal(state.matches[0].id, 'm2');
});
