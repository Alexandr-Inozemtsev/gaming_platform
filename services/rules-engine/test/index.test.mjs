/**
 * Назначение файла: валидировать правила двух MVP-игр и поведение ботов.
 * Роль в проекте: защищать rules-engine от регрессий при изменении схем состояния/валидации/скоринга.
 * Основные функции: тесты createInitialGameState, validateMove, applyMove, computeScore, legalMoves, chooseBotMove.
 * Связи с другими файлами: проверяет services/rules-engine/src/index.mjs.
 * Важно при изменении: сохранять покрытие для tile и roll-write, а также детерминизм RNG.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import {
  createInitialGameState,
  validateMove,
  applyMove,
  computeScore,
  rng,
  legalMoves,
  chooseBotMove
} from '../src/index.mjs';

const baseMatch = (gameId = 'tile_placement_demo') => ({
  id: 'm1',
  status: 'active',
  players: ['u1', 'u2'],
  currentPlayer: 'u1',
  moveNumber: 0,
  maxMoves: gameId === 'tile_placement_demo' ? 16 : 25,
  scores: { u1: 0, u2: 0 },
  log: [],
  winner: null,
  gameState: createInitialGameState(gameId, ['u1', 'u2'], 42)
});

test('tile state schema создаётся корректно', () => {
  const s = createInitialGameState('tile_placement_demo', ['u1', 'u2'], 1);
  assert.equal(s.grid.length, 4);
  assert.equal(s.hands.u1, 'A');
});

test('roll-write state schema создаётся корректно', () => {
  const s = createInitialGameState('roll_and_write_demo', ['u1', 'u2'], 1);
  assert.equal(s.sheet.u1.length, 5);
  assert.equal(Array.isArray(s.dice), true);
});

test('validateMove tile принимает легальный place', () => {
  const m = baseMatch('tile_placement_demo');
  assert.equal(validateMove(m, { playerId: 'u1', action: 'place', payload: { row: 0, col: 0 } }).ok, true);
});

test('validateMove tile отклоняет занятую клетку', () => {
  const m = baseMatch('tile_placement_demo');
  m.gameState.grid[0][0] = { owner: 'u1', symbol: 'A' };
  assert.equal(
    validateMove(m, { playerId: 'u1', action: 'place', payload: { row: 0, col: 0 } }).reason,
    'CELL_OCCUPIED'
  );
});

test('validateMove roll-write отклоняет неверное правило dice', () => {
  const m = baseMatch('roll_and_write_demo');
  m.gameState.dice = [1, 1];
  assert.equal(
    validateMove(m, { playerId: 'u1', action: 'write', payload: { row: 4, col: 4 } }).reason,
    'DICE_RULE_VIOLATION'
  );
});

test('legalMoves возвращает варианты для текущего игрока', () => {
  const m = baseMatch('tile_placement_demo');
  assert.equal(legalMoves(m, 'u1').length, 16);
  assert.equal(legalMoves(m, 'u2').length, 0);
});

test('applyMove tile меняет поле и переключает ход', () => {
  const m = baseMatch('tile_placement_demo');
  const r = applyMove(m, { playerId: 'u1', action: 'place', payload: { row: 0, col: 0 }, moveId: 'm1' });
  assert.equal(r.accepted, true);
  assert.equal(r.state.gameState.grid[0][0].owner, 'u1');
  assert.equal(r.state.currentPlayer, 'u2');
});

test('applyMove roll-write отмечает sheet', () => {
  const m = baseMatch('roll_and_write_demo');
  m.gameState.dice = [1, 1];
  const r = applyMove(m, { playerId: 'u1', action: 'write', payload: { row: 0, col: 0 }, moveId: 'm2' });
  assert.equal(r.accepted, true);
  assert.equal(r.state.gameState.sheet.u1[0][0], 1);
});

test('computeScore считает победителя tile', () => {
  const m = baseMatch('tile_placement_demo');
  m.gameState.grid[0][0] = { owner: 'u1', symbol: 'A' };
  m.gameState.grid[0][1] = { owner: 'u1', symbol: 'A' };
  m.gameState.grid[3][3] = { owner: 'u2', symbol: 'B' };
  const s = computeScore(m);
  assert.equal(s.winner, 'u1');
});

test('computeScore считает победителя roll-write', () => {
  const m = baseMatch('roll_and_write_demo');
  m.gameState.sheet.u1[0][0] = 1;
  m.gameState.sheet.u1[0][1] = 1;
  m.gameState.sheet.u2[0][0] = 1;
  const s = computeScore(m);
  assert.equal(s.winner, 'u1');
});

test('bot easy выбирает первый легальный ход', () => {
  const m = baseMatch('tile_placement_demo');
  const bot = chooseBotMove(m, 'u1', 'easy');
  assert.deepEqual(bot, { action: 'place', payload: { row: 0, col: 0 } });
});

test('bot normal возвращает легальный ход', () => {
  const m = baseMatch('tile_placement_demo');
  const bot = chooseBotMove(m, 'u1', 'normal');
  assert.equal(validateMove(m, { ...bot, playerId: 'u1' }).ok, true);
});

test('rng с одинаковым seed детерминирован', () => {
  const a = rng(77);
  const b = rng(77);
  assert.equal(a(), b());
  assert.equal(a(), b());
});
