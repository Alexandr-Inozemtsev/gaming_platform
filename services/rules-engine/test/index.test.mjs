/**
 * Назначение файла: проверить корректность и детерминизм функций rules-engine.
 * Роль в проекте: обеспечить стабильность базовой игровой логики MVP перед использованием в API.
 * Основные функции: тестирование validateMove/applyMove/computeScore/rng.
 * Связи с другими файлами: проверяет services/rules-engine/src/index.mjs.
 * Важно при изменении: сохранять минимум 10 unit-тестов как критерий готовности Prompt C.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { validateMove, applyMove, computeScore, rng } from '../src/index.mjs';

const baseState = () => ({
  id: 'm1',
  status: 'active',
  players: ['u1', 'u2'],
  currentPlayer: 'u1',
  moveNumber: 0,
  maxMoves: 3,
  scores: { u1: 0, u2: 0 },
  log: [],
  winner: null
});

test('validateMove принимает валидный ход', () => {
  const res = validateMove(baseState(), { playerId: 'u1', action: 'place' });
  assert.equal(res.ok, true);
});

test('validateMove отклоняет ход неактивного матча', () => {
  const s = baseState();
  s.status = 'finished';
  assert.equal(validateMove(s, { playerId: 'u1', action: 'place' }).ok, false);
});

test('validateMove отклоняет неизвестное действие', () => {
  assert.equal(validateMove(baseState(), { playerId: 'u1', action: 'hack' }).ok, false);
});

test('validateMove отклоняет ход не того игрока', () => {
  const res = validateMove(baseState(), { playerId: 'u2', action: 'place' });
  assert.equal(res.reason, 'NOT_YOUR_TURN');
});

test('applyMove увеличивает номер хода', () => {
  const result = applyMove(baseState(), { playerId: 'u1', action: 'place', points: 2 });
  assert.equal(result.accepted, true);
  assert.equal(result.state.moveNumber, 1);
});

test('applyMove переключает активного игрока', () => {
  const result = applyMove(baseState(), { playerId: 'u1', action: 'pass' });
  assert.equal(result.state.currentPlayer, 'u2');
});

test('applyMove завершает матч на maxMoves', () => {
  let s = baseState();
  s = applyMove(s, { playerId: 'u1', action: 'place' }).state;
  s = applyMove(s, { playerId: 'u2', action: 'place' }).state;
  s = applyMove(s, { playerId: 'u1', action: 'place' }).state;
  assert.equal(s.status, 'finished');
});

test('computeScore возвращает победителя', () => {
  const score = computeScore({ scores: { u1: 5, u2: 3 } });
  assert.equal(score.winner, 'u1');
});

test('rng с одинаковым seed выдаёт одинаковую последовательность', () => {
  const a = rng(42);
  const b = rng(42);
  assert.equal(a(), b());
  assert.equal(a(), b());
});

test('rng даёт число в диапазоне [0,1)', () => {
  const next = rng(7);
  const value = next();
  assert.equal(value >= 0 && value < 1, true);
});
