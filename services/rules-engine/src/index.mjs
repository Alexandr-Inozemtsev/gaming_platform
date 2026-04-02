/**
 * Назначение файла: реализовать детерминированный rules-engine для двух MVP-игр и ботов.
 * Роль в проекте: быть сервер-авторитетным источником правил, валидации и подсчёта очков для API/realtime.
 * Основные функции: schema state для tile/roll-write, validateMove/applyMove/computeScore/rng, генерация легальных ходов для ботов.
 * Связи с другими файлами: используется в services/api/src/app.mjs и тестах services/rules-engine/test/index.test.mjs.
 * Важно при изменении: не ломать формат gameState и сохранять полную детерминированность по seed.
 */

export { SUPPORTED_GAMES } from '../../../libraries/games/src/definitions.mjs';
import { createInitialGameState as createInitialStateFromLibrary } from '../../../libraries/games/src/definitions.mjs';

/**
 * Генератор псевдослучайных чисел с фиксируемым seed нужен для воспроизводимости матчей и ботов.
 */
export const rng = (seed = 1) => {
  let x = Math.abs(Math.trunc(seed)) || 1;
  return () => {
    x = (1664525 * x + 1013904223) % 4294967296;
    return x / 4294967296;
  };
};

/**
 * Инициализируем специфичное состояние игры, чтобы API не дублировал правила в нескольких местах.
 */
export const createInitialGameState = (gameId, players, seed = 1) =>
  createInitialStateFromLibrary(gameId, players, seed, { rng });

const inBounds = (size, row, col) => row >= 0 && col >= 0 && row < size && col < size;

const scoreTilePlacement = (grid, row, col, symbol) => {
  const dirs = [
    [1, 0],
    [-1, 0],
    [0, 1],
    [0, -1]
  ];
  let points = 1;
  for (const [dr, dc] of dirs) {
    const nr = row + dr;
    const nc = col + dc;
    if (inBounds(grid.length, nr, nc) && grid[nr][nc] === symbol) points += 1;
  }
  return points;
};

const nextPlayer = (players, current) => players[(players.indexOf(current) + 1) % players.length];

/**
 * Возвращаем легальные ходы для бота, чтобы easy/normal использовали единый источник правды.
 */
export const legalMoves = (state, playerId) => {
  if (state.status !== 'active' || state.currentPlayer !== playerId) return [];

  if (state.gameState.gameId === 'big_walker_demo') {
    return [{ action: 'roll', payload: {} }];
  }

  if (state.gameState.gameId === 'tile_placement_demo') {
    const moves = [];
    for (let r = 0; r < state.gameState.size; r += 1) {
      for (let c = 0; c < state.gameState.size; c += 1) {
        if (state.gameState.grid[r][c] === null) {
          moves.push({ action: 'place', payload: { row: r, col: c } });
        }
      }
    }
    return moves;
  }

  const sum = state.gameState.dice[0] + state.gameState.dice[1];
  const moves = [];
  for (let r = 0; r < state.gameState.size; r += 1) {
    for (let c = 0; c < state.gameState.size; c += 1) {
      if (state.gameState.sheet[playerId][r][c] === 0 && r + c + 2 === sum) {
        moves.push({ action: 'write', payload: { row: r, col: c } });
      }
    }
  }
  return moves;
};

/**
 * Валидация хода проверяет общие и игровые ограничения, чтобы нелегальные ходы отвергались сервером.
 */
export const validateMove = (state, move) => {
  if (!state || state.status !== 'active') return { ok: false, reason: 'MATCH_NOT_ACTIVE' };
  if (!move || typeof move.playerId !== 'string' || typeof move.action !== 'string') {
    return { ok: false, reason: 'INVALID_MOVE_SHAPE' };
  }
  if (state.currentPlayer !== move.playerId) return { ok: false, reason: 'NOT_YOUR_TURN' };

  if (state.gameState.gameId === 'big_walker_demo') {
    if (move.action !== 'roll') return { ok: false, reason: 'UNKNOWN_ACTION' };
    return { ok: true };
  }

  if (state.gameState.gameId === 'tile_placement_demo') {
    if (move.action !== 'place') return { ok: false, reason: 'UNKNOWN_ACTION' };
    const row = move.payload?.row;
    const col = move.payload?.col;
    if (!Number.isInteger(row) || !Number.isInteger(col)) return { ok: false, reason: 'INVALID_COORDS' };
    if (!inBounds(state.gameState.size, row, col)) return { ok: false, reason: 'OUT_OF_BOUNDS' };
    if (state.gameState.grid[row][col] !== null) return { ok: false, reason: 'CELL_OCCUPIED' };
    if (state.campaignProgress?.requiredAction && state.campaignProgress.requiredAction !== move.action) {
      return { ok: false, reason: 'CAMPAIGN_ACTION_REQUIRED' };
    }
    return { ok: true };
  }

  if (move.action !== 'write') return { ok: false, reason: 'UNKNOWN_ACTION' };
  const row = move.payload?.row;
  const col = move.payload?.col;
  if (!Number.isInteger(row) || !Number.isInteger(col)) return { ok: false, reason: 'INVALID_COORDS' };
  if (!inBounds(state.gameState.size, row, col)) return { ok: false, reason: 'OUT_OF_BOUNDS' };
  if (state.gameState.sheet[move.playerId][row][col] !== 0) return { ok: false, reason: 'CELL_OCCUPIED' };
  const sum = state.gameState.dice[0] + state.gameState.dice[1];
  if (row + col + 2 !== sum) return { ok: false, reason: 'DICE_RULE_VIOLATION' };
  if (state.campaignProgress?.maxCellValue && state.gameState.sheet[move.playerId][row][col] > state.campaignProgress.maxCellValue) {
    return { ok: false, reason: 'CAMPAIGN_CELL_RESTRICTION' };
  }
  return { ok: true };
};

/**
 * Подсчёт очков делается по gameState, чтобы результат не зависел от клиентских данных.
 */
export const computeScore = (state) => {
  if (state.gameState.gameId === 'big_walker_demo') {
    const leaderboard = state.players
      .map((playerId) => ({ playerId, score: state.gameState.positions[playerId] ?? 0 }))
      .sort((a, b) => b.score - a.score);
    const winner = leaderboard.find((item) => item.score >= state.gameState.boardLength)?.playerId ?? leaderboard[0]?.playerId ?? null;
    return { winner, leaderboard };
  }

  if (state.gameState.gameId === 'tile_placement_demo') {
    const scores = Object.fromEntries(state.players.map((p) => [p, 0]));
    for (let r = 0; r < state.gameState.size; r += 1) {
      for (let c = 0; c < state.gameState.size; c += 1) {
        const cell = state.gameState.grid[r][c];
        if (cell) scores[cell.owner] += scoreTilePlacement(state.gameState.grid, r, c, cell.symbol);
      }
    }
    const leaderboard = Object.entries(scores)
      .map(([playerId, score]) => ({ playerId, score }))
      .sort((a, b) => b.score - a.score);
    if (state.campaignProgress?.scoreMultiplier) {
      for (const item of leaderboard) item.score = Math.round(item.score * state.campaignProgress.scoreMultiplier);
      leaderboard.sort((a, b) => b.score - a.score);
    }
    return { winner: leaderboard[0]?.playerId ?? null, leaderboard };
  }

  const scores = Object.fromEntries(state.players.map((p) => [p, 0]));
  for (const p of state.players) {
    for (let r = 0; r < state.gameState.size; r += 1) {
      for (let c = 0; c < state.gameState.size; c += 1) {
        scores[p] += state.gameState.sheet[p][r][c];
      }
    }
  }
  const leaderboard = Object.entries(scores)
    .map(([playerId, score]) => ({ playerId, score }))
    .sort((a, b) => b.score - a.score);
  if (state.campaignProgress?.scoreMultiplier) {
    for (const item of leaderboard) item.score = Math.round(item.score * state.campaignProgress.scoreMultiplier);
    leaderboard.sort((a, b) => b.score - a.score);
  }
  return { winner: leaderboard[0]?.playerId ?? null, leaderboard };
};

export const applyLegacyConfig = (state, legacyConfig = {}) => ({
  ...state,
  legacyState: {
    level: Number(legacyConfig.level ?? 1),
    bonus: Number(legacyConfig.bonus ?? 0),
    history: [...(state.legacyState?.history ?? []), { ts: new Date().toISOString(), level: Number(legacyConfig.level ?? 1) }]
  }
});

export const applyEnemyMove = (state, enemyPlayerId = 'enemy_ai') => {
  const move = chooseBotMove(state, enemyPlayerId, 'normal');
  if (!move) return { accepted: false, reason: 'NO_ENEMY_MOVE' };
  return applyMove(state, { ...move, playerId: enemyPlayerId, moveId: `enemy_${Date.now()}`, ts: new Date().toISOString() });
};

/**
 * Применение хода обновляет gameState, логи, очерёдность и при необходимости завершает матч.
 */
export const applyMove = (state, move) => {
  const check = validateMove(state, move);
  if (!check.ok) return { state, accepted: false, reason: check.reason };

  const nextMoveNumber = state.moveNumber + 1;
  const nextState = structuredClone(state);
  nextState.moveNumber = nextMoveNumber;
  nextState.log.push({ ...move, moveNumber: nextMoveNumber });

  if (state.gameState.gameId === 'big_walker_demo') {
    const current = nextState.gameState.positions[move.playerId] ?? 0;
    const random = rng(nextState.gameState.seed + nextMoveNumber);
    const dice = 1 + Math.floor(random() * 6);
    const nextPosition = Math.min(nextState.gameState.boardLength, current + dice);
    nextState.gameState.dice = dice;
    nextState.gameState.positions[move.playerId] = nextPosition;
  } else if (state.gameState.gameId === 'tile_placement_demo') {
    const { row, col } = move.payload;
    nextState.gameState.grid[row][col] = { owner: move.playerId, symbol: nextState.gameState.hands[move.playerId] };
  } else {
    const { row, col } = move.payload;
    nextState.gameState.sheet[move.playerId][row][col] = 1;
    const r = rng(nextState.gameState.seed + nextMoveNumber);
    nextState.gameState.dice = [1 + Math.floor(r() * 6), 1 + Math.floor(r() * 6)];
  }

  nextState.currentPlayer = nextPlayer(nextState.players, state.currentPlayer);
  nextState.gameState.turn += 1;

  const legalLeft = legalMoves(nextState, nextState.currentPlayer).length;
  const boardFull = nextState.gameState.gameId === 'big_walker_demo'
    ? nextState.players.some((playerId) => (nextState.gameState.positions[playerId] ?? 0) >= nextState.gameState.boardLength)
    : nextState.gameState.gameId === 'tile_placement_demo'
      ? nextState.gameState.grid.flat().every((c) => c !== null)
      : nextState.players.every((p) => nextState.gameState.sheet[p].flat().every((c) => c !== 0));

  if (boardFull || legalLeft === 0 || nextMoveNumber >= state.maxMoves) {
    const score = computeScore(nextState);
    nextState.status = 'finished';
    nextState.winner = score.winner;
    nextState.scores = Object.fromEntries(score.leaderboard.map((s) => [s.playerId, s.score]));
  }

  return { state: nextState, accepted: true };
};

/**
 * Бот easy выбирает случайный легальный ход, бот normal выбирает ход с лучшей мгновенной оценкой.
 */
export const chooseBotMove = (state, playerId, level = 'easy') => {
  const moves = legalMoves(state, playerId);
  if (moves.length === 0) return null;
  if (level === 'easy') return moves[0];

  let best = moves[0];
  let bestScore = -Infinity;
  for (const move of moves) {
    const simulated = applyMove(state, { ...move, playerId, moveId: `bot_${move.action}_${Date.now()}` });
    if (!simulated.accepted) continue;
    const board = computeScore(simulated.state).leaderboard;
    const me = board.find((x) => x.playerId === playerId)?.score ?? 0;
    if (me > bestScore) {
      bestScore = me;
      best = move;
    }
  }
  return best;
};
