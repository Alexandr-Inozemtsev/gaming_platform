/**
 * Назначение файла: реализовать минимальное ядро правил для MVP-игр платформы настолок.
 * Роль в проекте: быть единой точкой детерминированной игровой логики для API и realtime.
 * Основные функции: validateMove(), applyMove(), computeScore(), rng(seed).
 * Связи с другими файлами: используется в services/api/src/app.mjs и тестах services/rules-engine/test/*.mjs.
 * Важно при изменении: сохранять детерминизм и обратную совместимость формата состояния матча.
 */

export const SUPPORTED_GAMES = ['tile_placement_demo', 'roll_and_write_demo'];

/**
 * Проверяем ход до применения, чтобы API мог отклонить неверные действия ещё до изменения состояния.
 */
export const validateMove = (state, move) => {
  if (!state || state.status !== 'active') return { ok: false, reason: 'MATCH_NOT_ACTIVE' };
  if (!move || typeof move.playerId !== 'string' || typeof move.action !== 'string') {
    return { ok: false, reason: 'INVALID_MOVE_SHAPE' };
  }
  if (state.currentPlayer !== move.playerId) return { ok: false, reason: 'NOT_YOUR_TURN' };
  if (!['place', 'roll', 'write', 'pass'].includes(move.action)) {
    return { ok: false, reason: 'UNKNOWN_ACTION' };
  }
  return { ok: true };
};

/**
 * Применяем ход иммутабельно, чтобы упростить снапшоты и диагностику состояния на сервере.
 */
export const applyMove = (state, move) => {
  const check = validateMove(state, move);
  if (!check.ok) {
    return { state, accepted: false, reason: check.reason };
  }

  const nextMoveNumber = state.moveNumber + 1;
  const nextLog = [...state.log, { ...move, moveNumber: nextMoveNumber }];

  const nextScores = { ...state.scores };
  nextScores[move.playerId] = (nextScores[move.playerId] ?? 0) + (move.points ?? 1);

  const currentIndex = state.players.indexOf(state.currentPlayer);
  const nextCurrentPlayer = state.players[(currentIndex + 1) % state.players.length];
  const shouldFinish = nextMoveNumber >= state.maxMoves;

  const nextState = {
    ...state,
    moveNumber: nextMoveNumber,
    currentPlayer: shouldFinish ? state.currentPlayer : nextCurrentPlayer,
    log: nextLog,
    scores: nextScores,
    status: shouldFinish ? 'finished' : 'active',
    winner: shouldFinish ? computeScore({ ...state, scores: nextScores, status: 'finished' }).winner : null
  };

  return { state: nextState, accepted: true };
};

/**
 * Считаем счёт через проход по словарю очков, что достаточно для MVP и прозрачно для тестов.
 */
export const computeScore = (state) => {
  const entries = Object.entries(state.scores ?? {});
  if (entries.length === 0) return { winner: null, leaderboard: [] };

  const leaderboard = entries
    .map(([playerId, score]) => ({ playerId, score }))
    .sort((a, b) => b.score - a.score);

  return { winner: leaderboard[0].playerId, leaderboard };
};

/**
 * Линейный конгруэнтный генератор выбран из-за простоты, скорости и повторяемости по seed.
 */
export const rng = (seed = 1) => {
  let x = Math.abs(Math.trunc(seed)) || 1;
  return () => {
    x = (1664525 * x + 1013904223) % 4294967296;
    return x / 4294967296;
  };
};
