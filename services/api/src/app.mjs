/**
 * Назначение файла: реализовать безопасное API-ядро MVP с поддержкой двух игр, ботов и персистентности матчей.
 * Роль в проекте: объединять auth/catalog/matches/store/moderation/analytics в едином серверном состоянии.
 * Основные функции: security-политики, создание матчей c gameState, проверка/применение ходов через rules-engine, восстановление после перезапуска.
 * Связи с другими файлами: использует services/rules-engine/src/index.mjs и HTTP-слой services/api/src/server.mjs.
 * Важно при изменении: не доверять клиенту игровой state, сохранять идемпотентность moveId и не писать секреты в репозиторий.
 */

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import {
  applyMove,
  applyEnemyMove,
  SUPPORTED_GAMES,
  rng,
  createInitialGameState,
  chooseBotMove,
  legalMoves
} from '../../rules-engine/src/index.mjs';

class HttpError extends Error {
  constructor(status, code, details = undefined) {
    super(code);
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

const nowIso = () => new Date().toISOString();
const newId = (prefix) => `${prefix}_${Math.random().toString(36).slice(2, 10)}`;
const BAN_DURATIONS = ['1h', '24h', '7d', 'permanent'];
const DEFAULT_POLICY = ['no negotiation', 'bluff', 'party', 'physical'];

const hashPassword = (password) => {
  const salt = crypto.randomBytes(16).toString('hex');
  const derived = crypto.scryptSync(password, salt, 64).toString('hex');
  return `scrypt$${salt}$${derived}`;
};

const verifyPassword = (password, storedHash) => {
  const [alg, salt, stored] = String(storedHash).split('$');
  if (alg !== 'scrypt' || !salt || !stored) return false;
  const derived = crypto.scryptSync(password, salt, 64).toString('hex');
  return crypto.timingSafeEqual(Buffer.from(derived), Buffer.from(stored));
};

const createRateLimiter = ({ limit, windowMs }) => {
  const buckets = new Map();
  return {
    hit: (key) => {
      const now = Date.now();
      const item = buckets.get(key) ?? { count: 0, resetAt: now + windowMs };
      if (now > item.resetAt) {
        item.count = 0;
        item.resetAt = now + windowMs;
      }
      item.count += 1;
      buckets.set(key, item);
      if (item.count > limit) throw new HttpError(429, 'RATE_LIMIT_EXCEEDED', { key, resetAt: item.resetAt });
    }
  };
};

const assertString = (value, field, { min = 1 } = {}) => {
  if (typeof value !== 'string' || value.trim().length < min) throw new HttpError(400, 'VALIDATION_ERROR', { field });
};

const assertArray = (value, field, { min = 1 } = {}) => {
  if (!Array.isArray(value) || value.length < min) throw new HttpError(400, 'VALIDATION_ERROR', { field });
};

const assertNumber = (value, field, { min = Number.NEGATIVE_INFINITY, max = Number.POSITIVE_INFINITY } = {}) => {
  if (typeof value !== 'number' || Number.isNaN(value) || value < min || value > max) {
    throw new HttpError(400, 'VALIDATION_ERROR', { field });
  }
};

const createTokens = (userId) => ({
  accessToken: `access.${userId}.${Date.now()}`,
  refreshToken: `refresh.${userId}.${Date.now()}`
});

const toSerializableMatch = (match) => ({
  ...match,
  acceptedMoveIds: [...match.acceptedMoveIds],
  snapshots: (match.snapshots ?? []).map((snap) => ({
    moveNumber: snap.moveNumber,
    state: { ...snap.state, snapshots: [] }
  })),
  rngState: undefined
});

const restoreMatch = (raw) => ({
  ...raw,
  acceptedMoveIds: new Set(raw.acceptedMoveIds ?? []),
  rngState: rng((raw.gameState?.seed ?? 1) + raw.moveNumber)
});

export const createApiApp = ({ gateway, config = {} } = {}) => {
  const securityConfig = {
    RATE_LIMIT_LOGIN: Number(config.RATE_LIMIT_LOGIN ?? 10),
    RATE_LIMIT_MOVE: Number(config.RATE_LIMIT_MOVE ?? 60),
    REFRESH_TTL_DAYS: Number(config.REFRESH_TTL_DAYS ?? 30),
    DEFAULT_LANG: config.DEFAULT_LANG ?? 'ru',
    MATCH_STATE_SNAPSHOT_EVERY_N_MOVES: Number(config.MATCH_STATE_SNAPSHOT_EVERY_N_MOVES ?? 1),
    REQUIRE_TLS_IN_PROD: String(config.REQUIRE_TLS_IN_PROD ?? 'true') === 'true',
    MATCH_STORE_FILE: config.MATCH_STORE_FILE ?? path.join(process.cwd(), '.data', 'matches.json'),
    REGION_MODE: config.REGION_MODE ?? 'global',
    VIDEO_POLICY: config.VIDEO_POLICY ?? 'invite_only'
  };

  // Выделяем флаг редактора в конфиг, чтобы корректно принимать/блокировать репорты на варианты правил.
  const editorEnabled = String(config.EDITOR_ENABLED ?? 'true') === 'true';

  const state = {
    users: [],
    sessions: new Map(),
    matches: [],
    inventory: new Map(),
    purchases: [],
    campaigns: [],
    levels: [],
    leaderboardEntries: [],
    legacyStates: new Map(),
    gameVariants: [],
    skuCatalog: [
      { sku: 'game.tile_pack', title: 'Tile Placement License', type: 'GAME_LICENSE', priceSandbox: 4.99, isNew: true },
      { sku: 'game.roll_pack', title: 'Roll&Write License', type: 'GAME_LICENSE', priceSandbox: 4.99, isNew: false },
      { sku: 'skin.dice.neon', title: 'Dice Neon Skin', type: 'COSMETIC', priceSandbox: 1.49, isNew: true },
      { sku: 'skin.board.forest', title: 'Board Forest Skin', type: 'COSMETIC', priceSandbox: 1.99, isNew: false }
    ],
    reports: [],
    moderationCases: [],
    moderationAuditLogs: [],
    sanctions: [],
    analytics: [],
    eventQueue: [],
    securityLogs: [],
    requestLogs: [],
    technicalMetrics: {
      reconnectCount: 0,
      wsDisconnects: 0,
      videoConnectFailures: 0
    }
  };

  const persistMatches = () => {
    const target = securityConfig.MATCH_STORE_FILE;
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.writeFileSync(target, JSON.stringify(state.matches.map(toSerializableMatch), null, 2));
  };

  const recalculateLeaderboards = () => {
    const now = Date.now();
    const weekMs = 7 * 86_400_000;
    const aggregate = (rows) => {
      const totals = new Map();
      for (const row of rows) totals.set(row.userId, (totals.get(row.userId) ?? 0) + row.score);
      return [...totals.entries()].map(([userId, score]) => ({ userId, score })).sort((a, b) => b.score - a.score);
    };
    return {
      allTime: aggregate(state.leaderboardEntries),
      weekly: aggregate(state.leaderboardEntries.filter((row) => now - Date.parse(row.ts) <= weekMs))
    };
  };

  const loadMatches = () => {
    const target = securityConfig.MATCH_STORE_FILE;
    if (!fs.existsSync(target)) return;
    const raw = JSON.parse(fs.readFileSync(target, 'utf8'));
    state.matches = raw.map(restoreMatch);
  };

  loadMatches();

  const loginLimiter = createRateLimiter({ limit: securityConfig.RATE_LIMIT_LOGIN, windowMs: 60_000 });
  const moveLimiter = createRateLimiter({ limit: securityConfig.RATE_LIMIT_MOVE, windowMs: 60_000 });

  const games = [
    { id: 'tile_placement_demo', title: 'Tile Placement Demo', langs: ['ru', 'en'] },
    { id: 'roll_and_write_demo', title: 'Roll & Write Demo', langs: ['ru', 'en'] }
  ];

  const applyVariantToInitialState = ({ gameId, players, seed, variant }) => {
    const initialState = createInitialGameState(gameId, players, seed);
    if (!variant) return initialState;
    const nextState = structuredClone(initialState);
    if (typeof variant.boardSize === 'number') {
      if (gameId === 'tile_placement_demo') {
        nextState.size = variant.boardSize;
        nextState.grid = Array.from({ length: variant.boardSize }, () => Array.from({ length: variant.boardSize }, () => null));
      } else if (gameId === 'roll_and_write_demo') {
        nextState.size = variant.boardSize;
        nextState.sheet = Object.fromEntries(
          players.map((p) => [p, Array.from({ length: variant.boardSize }, () => Array.from({ length: variant.boardSize }, () => 0))])
        );
      }
    }
    return nextState;
  };

  const validateVariantPayload = ({ gameId, boardSize, winCondition, scoringMultipliers, turnTimer }) => {
    assertString(gameId, 'gameId');
    if (!SUPPORTED_GAMES.includes(gameId)) throw new HttpError(400, 'UNSUPPORTED_GAME');
    assertNumber(boardSize, 'boardSize', { min: 3, max: 8 });
    assertString(winCondition, 'winCondition', { min: 3 });
    if (typeof scoringMultipliers !== 'object' || scoringMultipliers === null) {
      throw new HttpError(400, 'VALIDATION_ERROR', { field: 'scoringMultipliers' });
    }
    for (const [key, value] of Object.entries(scoringMultipliers)) {
      if (typeof key !== 'string' || !key.length) throw new HttpError(400, 'VALIDATION_ERROR', { field: 'scoringMultipliers.key' });
      assertNumber(value, `scoringMultipliers.${key}`, { min: 0.1, max: 10 });
    }
    if (turnTimer !== undefined && turnTimer !== null) assertNumber(turnTimer, 'turnTimer', { min: 5, max: 300 });
    return { ok: true };
  };

  const addSecurityLog = (kind, payload) => state.securityLogs.push({ id: newId('seclog'), kind, payload, ts: nowIso() });

  const parseDurationToExpiresAt = (duration) => {
    if (duration === 'permanent') return null;
    const map = { '1h': 3_600_000, '24h': 86_400_000, '7d': 604_800_000 };
    const ms = map[duration];
    if (!ms) throw new HttpError(400, 'MODERATION_DURATION_UNSUPPORTED', { duration, allowed: BAN_DURATIONS });
    return new Date(Date.now() + ms).toISOString();
  };

  const findActiveSanction = ({ userId, type, nowTs = Date.now() }) =>
    state.sanctions.find((item) => item.userId === userId && item.type === type && item.active && (!item.expiresAt || Date.parse(item.expiresAt) > nowTs));

  const assertUserIsNotBanned = (userId) => {
    if (findActiveSanction({ userId, type: 'ban' })) throw new HttpError(403, 'USER_BANNED');
  };

  const addModerationAudit = ({ moderatorUserId, action, caseId = null, userId = null, payload = {} }) => {
    state.moderationAuditLogs.push({
      id: newId('modaudit'),
      moderatorUserId,
      action,
      caseId,
      userId,
      payload,
      ts: nowIso()
    });
  };

  // Проверяем существование пользователя, чтобы бизнес-операции не выполнялись для несуществующих id.
  const assertKnownUser = (userId, field = 'userId') => {
    if (!state.users.some((user) => user.id === userId)) throw new HttpError(404, 'USER_NOT_FOUND', { field, userId });
  };

  // Служебный bot-id в MVP генерируется как "<userId>_bot", поэтому исключаем его из проверки зарегистрированных пользователей.
  const isBotUserId = (userId) => typeof userId === 'string' && (userId.endsWith('_bot') || userId === 'enemy_ai');

  const auth = {
    register: ({ email, password, lang = securityConfig.DEFAULT_LANG }) => {
      assertString(email, 'email', { min: 5 });
      assertString(password, 'password', { min: 6 });
      if (state.users.some((u) => u.email === email)) throw new HttpError(409, 'USER_EXISTS');
      const user = { id: newId('user'), email, passwordHash: hashPassword(password), lang, createdAt: nowIso() };
      state.users.push(user);
      state.inventory.set(user.id, []);
      state.analytics.push({
        id: newId('event'),
        eventName: 'onboarding_complete',
        userId: user.id,
        sessionId: null,
        payload: { lang },
        source: 'backend',
        ts: nowIso()
      });
      return { id: user.id, email: user.email, lang: user.lang };
    },
    login: ({ email, password, ip = 'local' }) => {
      assertString(email, 'email', { min: 5 });
      assertString(password, 'password');
      loginLimiter.hit(`login:${ip}`);
      const user = state.users.find((u) => u.email === email);
      if (!user || !verifyPassword(password, user.passwordHash)) {
        addSecurityLog('SUSPICIOUS_LOGIN', { email, ip });
        throw new HttpError(401, 'INVALID_CREDENTIALS');
      }
      assertUserIsNotBanned(user.id);
      const tokens = createTokens(user.id);
      state.sessions.set(tokens.refreshToken, { userId: user.id, expiresAt: Date.now() + securityConfig.REFRESH_TTL_DAYS * 86400000 });
      state.analytics.push({
        id: newId('event'),
        eventName: 'login_success',
        userId: user.id,
        sessionId: tokens.refreshToken,
        payload: { ip },
        source: 'backend',
        ts: nowIso()
      });
      return { user: { id: user.id, email: user.email }, ...tokens };
    },
    refresh: ({ refreshToken }) => {
      assertString(refreshToken, 'refreshToken', { min: 10 });
      const session = state.sessions.get(refreshToken);
      if (!session) throw new HttpError(401, 'SESSION_NOT_FOUND');
      if (Date.now() > session.expiresAt) throw new HttpError(401, 'SESSION_EXPIRED');
      const tokens = createTokens(session.userId);
      state.sessions.set(tokens.refreshToken, { userId: session.userId, expiresAt: Date.now() + securityConfig.REFRESH_TTL_DAYS * 86400000 });
      state.sessions.delete(refreshToken);
      return tokens;
    },
    logoutAll: ({ userId }) => {
      assertString(userId, 'userId');
      for (const [token, session] of state.sessions.entries()) if (session.userId === userId) state.sessions.delete(token);
      return { ok: true };
    }
  };

  const users = {
    inventory: ({ userId }) => {
      assertString(userId, 'userId');
      return [...(state.inventory.get(userId) ?? [])];
    }
  };

  const catalog = {
    listGames: () => games,
    getGame: (id) => games.find((g) => g.id === id) ?? null
  };

  const matches = {
    create: ({ gameId, players, botLevel = null, variantId = null, campaignId = null, level = 1, mode = 'classic' }) => {
      assertString(gameId, 'gameId');
      assertArray(players, 'players', { min: 2 });
      assertNumber(level, 'level', { min: 1, max: 10_000 });
      assertString(mode, 'mode');
      if (!['classic', 'legacy', 'coop'].includes(mode)) throw new HttpError(400, 'MODE_UNSUPPORTED');
      if (campaignId !== null) {
        assertString(campaignId, 'campaignId');
        if (!state.campaigns.some((campaign) => campaign.id === campaignId)) throw new HttpError(404, 'CAMPAIGN_NOT_FOUND');
      }
      if (!SUPPORTED_GAMES.includes(gameId)) throw new HttpError(400, 'UNSUPPORTED_GAME');
      const normalizedPlayers = [...players];
      if (mode === 'coop' && !normalizedPlayers.includes('enemy_ai')) normalizedPlayers.push('enemy_ai');
      for (const userId of normalizedPlayers) {
        if (!isBotUserId(userId)) assertKnownUser(userId, 'players');
        if (!isBotUserId(userId)) assertUserIsNotBanned(userId);
      }
      const variant = variantId ? state.gameVariants.find((item) => item.id === variantId && item.status === 'published') : null;
      if (variantId && !variant) throw new HttpError(404, 'VARIANT_NOT_FOUND');
      const seed = Math.floor(Math.random() * 1_000_000_000);
      const match = {
        id: newId('match'),
        gameId,
        campaignId,
        level,
        mode,
        variantId: variant?.id ?? null,
        variantConfig: variant
          ? {
              boardSize: variant.boardSize,
              winCondition: variant.winCondition,
              scoringMultipliers: variant.scoringMultipliers,
              turnTimer: variant.turnTimer ?? null
            }
          : null,
        players: normalizedPlayers,
        currentPlayer: normalizedPlayers[0],
        moveNumber: 0,
        maxMoves: variant?.boardSize ? variant.boardSize * variant.boardSize : gameId === 'tile_placement_demo' ? 16 : 25,
        scores: Object.fromEntries(normalizedPlayers.map((p) => [p, 0])),
        log: [],
        status: 'active',
        winner: null,
        snapshots: [],
        acceptedMoveIds: new Set(),
        gameState: applyVariantToInitialState({ gameId, players: normalizedPlayers, seed, variant }),
        bot:
          mode === 'coop'
            ? { enabled: false, enemyAi: true, playerId: 'enemy_ai', level: 'normal' }
            : botLevel
              ? { enabled: true, playerId: normalizedPlayers[1], level: botLevel }
              : { enabled: false },
        legacyState: mode === 'legacy' ? { currentLevel: level, nextLevelAvailable: false, history: [] } : null
      };
      state.matches.push(match);
      gateway?.configurePrivateRoom?.(match.id, players);
      state.analytics.push({
        id: newId('event'),
        eventName: 'match_create',
        userId: normalizedPlayers[0] ?? null,
        sessionId: null,
        payload: { matchId: match.id, gameId, variantId: match.variantId },
        source: 'backend',
        ts: nowIso()
      });
      persistMatches();
      gateway?.emitMatchState(match.id, toSerializableMatch(match));
      return toSerializableMatch(match);
    },
    list: () => state.matches.map(toSerializableMatch),
    getById: (id) => {
      const match = state.matches.find((m) => m.id === id);
      return match ? toSerializableMatch(match) : null;
    },
    move: ({ matchId, playerId, action, moveId, payload = {}, ip = 'local' }) => {
      assertString(matchId, 'matchId');
      assertString(playerId, 'playerId');
      assertString(action, 'action');
      assertString(moveId, 'moveId');
      if (!isBotUserId(playerId)) assertKnownUser(playerId, 'playerId');
      assertUserIsNotBanned(playerId);
      moveLimiter.hit(`move:${playerId}`);
      const match = state.matches.find((m) => m.id === matchId);
      if (!match) throw new HttpError(404, 'MATCH_NOT_FOUND');
      if (!match.players.includes(playerId)) throw new HttpError(403, 'PLAYER_NOT_IN_MATCH');
      if (match.acceptedMoveIds.has(moveId)) throw new HttpError(409, 'MOVE_ID_ALREADY_PROCESSED');
      if (match.currentPlayer !== playerId) {
        addSecurityLog('MOVE_NOT_YOUR_TURN', { matchId, playerId, ip });
        throw new HttpError(403, 'NOT_YOUR_TURN');
      }

      const startedAt = Date.now();
      const result = applyMove(match, { playerId, action, moveId, payload, ts: nowIso() });
      if (!result.accepted) {
        if (result.reason === 'NOT_YOUR_TURN') throw new HttpError(403, 'NOT_YOUR_TURN');
        throw new HttpError(400, result.reason ?? 'MOVE_REJECTED');
      }

      Object.assign(match, result.state);
      match.acceptedMoveIds.add(moveId);
      if (match.moveNumber % securityConfig.MATCH_STATE_SNAPSHOT_EVERY_N_MOVES === 0) {
        match.snapshots.push({ moveNumber: match.moveNumber, state: { ...toSerializableMatch(match), snapshots: [] } });
      }

      if (match.bot?.enabled && match.status === 'active' && match.currentPlayer === match.bot.playerId) {
        const botMove = chooseBotMove(match, match.bot.playerId, match.bot.level);
        if (botMove) {
          const botResult = applyMove(match, {
            playerId: match.bot.playerId,
            action: botMove.action,
            payload: botMove.payload,
            moveId: `bot_${match.moveNumber + 1}`,
            ts: nowIso()
          });
          if (botResult.accepted) {
            Object.assign(match, botResult.state);
            match.acceptedMoveIds.add(`bot_${match.moveNumber}`);
          }
        }
      }

      if (match.mode === 'coop' && match.status === 'active' && match.currentPlayer === 'enemy_ai') {
        const enemyResult = applyEnemyMove(match, 'enemy_ai');
        if (enemyResult.accepted) Object.assign(match, enemyResult.state);
      }

      persistMatches();
      state.analytics.push({
        id: newId('event'),
        eventName: 'match_move',
        userId: playerId,
        sessionId: null,
        payload: { matchId, moveNumber: match.moveNumber, action },
        source: 'backend',
        ts: nowIso()
      });
      state.analytics.push({
        id: newId('event'),
        eventName: 'latency_move',
        userId: playerId,
        sessionId: null,
        payload: { matchId, latencyMs: Date.now() - startedAt },
        source: 'backend',
        ts: nowIso()
      });
      if (match.status === 'finished') {
        if (match.mode === 'legacy' && match.winner === match.players[0]) {
          match.legacyState = {
            currentLevel: match.level,
            nextLevelAvailable: true,
            history: [...(match.legacyState?.history ?? []), { level: match.level, winner: match.winner, ts: nowIso() }]
          };
          state.legacyStates.set(match.id, { matchId: match.id, turnData: match.log.slice(-5), level: match.level, ts: nowIso() });
        }
        const winnerScore = match.winner ? Number(match.scores?.[match.winner] ?? 0) : 0;
        if (match.winner) state.leaderboardEntries.push({ id: newId('leaderboard'), userId: match.winner, score: winnerScore, ts: nowIso() });
        state.analytics.push({
          id: newId('event'),
          eventName: 'match_finish',
          userId: playerId,
          sessionId: null,
          payload: { matchId, winner: match.winner },
          source: 'backend',
          ts: nowIso()
        });
        if (match.campaignId) {
          state.analytics.push({
            id: newId('event'),
            eventName: 'level_complete',
            userId: playerId,
            sessionId: null,
            payload: { matchId, campaignId: match.campaignId, level: match.level, winner: match.winner },
            source: 'backend',
            ts: nowIso()
          });
          const nextLevelExists = state.levels.some((item) => item.campaignId === match.campaignId && item.levelNumber === match.level + 1);
          if (!nextLevelExists) {
            state.analytics.push({
              id: newId('event'),
              eventName: 'campaign_finished',
              userId: playerId,
              sessionId: null,
              payload: { campaignId: match.campaignId, matchId },
              source: 'backend',
              ts: nowIso()
            });
          }
        }
      }
      gateway?.emitMatchState(match.id, toSerializableMatch(match));
      gateway?.emitRoomEvent(match.id, 'match.move.applied', { matchId, moveNumber: match.moveNumber });
      return toSerializableMatch(match);
    },
    restore: () => {
      loadMatches();
      return state.matches.map(toSerializableMatch);
    },
    legalMoves: ({ matchId, playerId }) => {
      const match = state.matches.find((m) => m.id === matchId);
      if (!match) throw new HttpError(404, 'MATCH_NOT_FOUND');
      return legalMoves(match, playerId);
    },
    nextLevel: ({ matchId }) => {
      assertString(matchId, 'matchId');
      const match = state.matches.find((m) => m.id === matchId);
      if (!match) throw new HttpError(404, 'MATCH_NOT_FOUND');
      if (match.mode !== 'legacy') throw new HttpError(409, 'LEGACY_MODE_REQUIRED');
      if (!match.legacyState?.nextLevelAvailable) throw new HttpError(409, 'NEXT_LEVEL_NOT_AVAILABLE');
      return matches.create({
        gameId: match.gameId,
        players: match.players.filter((id) => id !== 'enemy_ai'),
        campaignId: match.campaignId,
        level: Number(match.level) + 1,
        mode: 'legacy'
      });
    }
  };

  const campaigns = {
    create: ({ name, description = '', levels = [] }) => {
      assertString(name, 'name', { min: 2 });
      if (!Array.isArray(levels)) throw new HttpError(400, 'VALIDATION_ERROR', { field: 'levels' });
      const campaign = { id: newId('campaign'), name, description, createdAt: nowIso(), updatedAt: nowIso() };
      state.campaigns.push(campaign);
      state.levels.push(
        ...levels.map((levelItem, idx) => ({
          id: newId('level'),
          campaignId: campaign.id,
          levelNumber: idx + 1,
          configJSON: JSON.stringify(levelItem ?? {})
        }))
      );
      return { ...campaign, levels: state.levels.filter((item) => item.campaignId === campaign.id) };
    },
    list: () =>
      state.campaigns.map((campaign) => ({
        ...campaign,
        levels: state.levels
          .filter((level) => level.campaignId === campaign.id)
          .sort((a, b) => a.levelNumber - b.levelNumber)
      })),
    getById: ({ campaignId }) => {
      assertString(campaignId, 'campaignId');
      const campaign = state.campaigns.find((item) => item.id === campaignId);
      if (!campaign) throw new HttpError(404, 'CAMPAIGN_NOT_FOUND');
      return {
        ...campaign,
        levels: state.levels.filter((item) => item.campaignId === campaignId).sort((a, b) => a.levelNumber - b.levelNumber)
      };
    },
    update: ({ campaignId, patch = {} }) => {
      const campaign = campaigns.getById({ campaignId });
      if (patch.name !== undefined) assertString(patch.name, 'name', { min: 2 });
      if (patch.description !== undefined && typeof patch.description !== 'string') {
        throw new HttpError(400, 'VALIDATION_ERROR', { field: 'description' });
      }
      const row = state.campaigns.find((item) => item.id === campaignId);
      Object.assign(row, { ...patch, updatedAt: nowIso() });
      return campaigns.getById({ campaignId });
    },
    remove: ({ campaignId }) => {
      assertString(campaignId, 'campaignId');
      state.campaigns = state.campaigns.filter((item) => item.id !== campaignId);
      state.levels = state.levels.filter((item) => item.campaignId !== campaignId);
      return { ok: true };
    },
    start: ({ campaignId, players, botLevel = null }) => {
      const campaign = campaigns.getById({ campaignId });
      const firstLevel = campaign.levels[0] ?? { levelNumber: 1, configJSON: '{}' };
      const levelConfig = JSON.parse(firstLevel.configJSON);
      const initialMatch = matches.create({
        gameId: levelConfig.gameId ?? 'tile_placement_demo',
        players,
        botLevel,
        campaignId,
        level: firstLevel.levelNumber,
        mode: 'classic'
      });
      return { campaign, match: initialMatch };
    }
  };

  const leaderboards = {
    get: ({ period = 'all-time' } = {}) => {
      if (!['all-time', 'weekly'].includes(period)) throw new HttpError(400, 'LEADERBOARD_PERIOD_UNSUPPORTED');
      const data = recalculateLeaderboards();
      return period === 'weekly' ? data.weekly : data.allTime;
    }
  };

  const campaigns = {
    create: ({ name, description = '', levels = [] }) => {
      assertString(name, 'name', { min: 2 });
      if (!Array.isArray(levels)) throw new HttpError(400, 'VALIDATION_ERROR', { field: 'levels' });
      const campaign = { id: newId('campaign'), name, description, createdAt: nowIso(), updatedAt: nowIso() };
      state.campaigns.push(campaign);
      state.levels.push(
        ...levels.map((levelItem, idx) => ({
          id: newId('level'),
          campaignId: campaign.id,
          levelNumber: idx + 1,
          configJSON: JSON.stringify(levelItem ?? {})
        }))
      );
      return { ...campaign, levels: state.levels.filter((item) => item.campaignId === campaign.id) };
    },
    list: () =>
      state.campaigns.map((campaign) => ({
        ...campaign,
        levels: state.levels
          .filter((level) => level.campaignId === campaign.id)
          .sort((a, b) => a.levelNumber - b.levelNumber)
      })),
    getById: ({ campaignId }) => {
      assertString(campaignId, 'campaignId');
      const campaign = state.campaigns.find((item) => item.id === campaignId);
      if (!campaign) throw new HttpError(404, 'CAMPAIGN_NOT_FOUND');
      return {
        ...campaign,
        levels: state.levels.filter((item) => item.campaignId === campaignId).sort((a, b) => a.levelNumber - b.levelNumber)
      };
    },
    update: ({ campaignId, patch = {} }) => {
      const campaign = campaigns.getById({ campaignId });
      if (patch.name !== undefined) assertString(patch.name, 'name', { min: 2 });
      if (patch.description !== undefined && typeof patch.description !== 'string') {
        throw new HttpError(400, 'VALIDATION_ERROR', { field: 'description' });
      }
      const row = state.campaigns.find((item) => item.id === campaignId);
      Object.assign(row, { ...patch, updatedAt: nowIso() });
      return campaigns.getById({ campaignId });
    },
    remove: ({ campaignId }) => {
      assertString(campaignId, 'campaignId');
      state.campaigns = state.campaigns.filter((item) => item.id !== campaignId);
      state.levels = state.levels.filter((item) => item.campaignId !== campaignId);
      return { ok: true };
    },
    start: ({ campaignId, players, botLevel = null }) => {
      const campaign = campaigns.getById({ campaignId });
      const firstLevel = campaign.levels[0] ?? { levelNumber: 1, configJSON: '{}' };
      const levelConfig = JSON.parse(firstLevel.configJSON);
      const initialMatch = matches.create({
        gameId: levelConfig.gameId ?? 'tile_placement_demo',
        players,
        botLevel,
        campaignId,
        level: firstLevel.levelNumber,
        mode: 'classic'
      });
      return { campaign, match: initialMatch };
    }
  };

  const leaderboards = {
    get: ({ period = 'all-time' } = {}) => {
      if (!['all-time', 'weekly'].includes(period)) throw new HttpError(400, 'LEADERBOARD_PERIOD_UNSUPPORTED');
      const data = recalculateLeaderboards();
      return period === 'weekly' ? data.weekly : data.allTime;
    }
  };

  const store = {
    skus: () => ({
      ...(() => {
        state.analytics.push({
          id: newId('event'),
          eventName: 'store_view',
          userId: null,
          sessionId: null,
          payload: { regionMode: securityConfig.REGION_MODE },
          source: 'backend',
          ts: nowIso()
        });
        return {};
      })(),
      regionMode: securityConfig.REGION_MODE,
      warning: securityConfig.REGION_MODE === 'ru_by' ? 'Платежный канал зависит от дистрибуции' : null,
      items: state.skuCatalog
    }),
    purchaseSandbox: ({ userId, sku }) => {
      assertString(userId, 'userId');
      assertString(sku, 'sku');
      assertKnownUser(userId);
      assertUserIsNotBanned(userId);
      state.analytics.push({
        id: newId('event'),
        eventName: 'purchase_attempt',
        userId,
        sessionId: null,
        payload: { sku },
        source: 'backend',
        ts: nowIso()
      });
      const skuItem = state.skuCatalog.find((i) => i.sku === sku);
      if (!skuItem) throw new HttpError(404, 'SKU_NOT_FOUND');
      const inventory = state.inventory.get(userId) ?? [];
      const record = {
        id: newId('purchase'),
        userId,
        sku,
        type: skuItem.type,
        purchasedAt: nowIso(),
        mode: 'sandbox',
        applied: false
      };
      state.purchases.push(record);
      inventory.push(record);
      state.inventory.set(userId, inventory);
      state.analytics.push({
        id: newId('event'),
        eventName: 'purchase_success',
        userId,
        sessionId: null,
        payload: { sku },
        source: 'backend',
        ts: nowIso()
      });
      return { ok: true, item: record };
    },
    applySkin: ({ userId, sku }) => {
      assertString(userId, 'userId');
      assertString(sku, 'sku');
      assertKnownUser(userId);
      assertUserIsNotBanned(userId);
      const inventory = state.inventory.get(userId) ?? [];
      const item = inventory.find((i) => i.sku === sku && i.type === 'COSMETIC');
      if (!item) throw new HttpError(404, 'SKIN_NOT_OWNED');
      for (const i of inventory) if (i.type === 'COSMETIC') i.applied = false;
      item.applied = true;
      return { ok: true, appliedSku: sku };
    }
  };

  const variants = {
    listByGame: ({ gameId, userId }) => {
      assertString(gameId, 'gameId');
      return state.gameVariants.filter(
        (item) => item.gameId === gameId && (item.status === 'published' || (userId && item.authorUserId === userId))
      );
    },
    listMine: ({ userId }) => {
      assertString(userId, 'userId');
      return state.gameVariants.filter((item) => item.authorUserId === userId);
    },
    createDraft: ({ userId, gameId, boardSize, winCondition, scoringMultipliers, turnTimer = null }) => {
      assertString(userId, 'userId');
      validateVariantPayload({ gameId, boardSize, winCondition, scoringMultipliers, turnTimer });
      const variant = {
        id: newId('variant'),
        authorUserId: userId,
        gameId,
        boardSize,
        winCondition,
        scoringMultipliers,
        turnTimer,
        status: 'draft',
        validationErrors: [],
        privateLinkToken: null,
        createdAt: nowIso(),
        updatedAt: nowIso(),
        publishedAt: null
      };
      state.gameVariants.push(variant);
      return variant;
    },
    update: ({ variantId, userId, patch }) => {
      assertString(variantId, 'variantId');
      assertString(userId, 'userId');
      const variant = state.gameVariants.find((item) => item.id === variantId);
      if (!variant) throw new HttpError(404, 'VARIANT_NOT_FOUND');
      if (variant.authorUserId !== userId) throw new HttpError(403, 'FORBIDDEN');
      if (variant.status === 'published') throw new HttpError(409, 'VARIANT_ALREADY_PUBLISHED');
      const merged = {
        ...variant,
        ...patch
      };
      validateVariantPayload({
        gameId: merged.gameId,
        boardSize: merged.boardSize,
        winCondition: merged.winCondition,
        scoringMultipliers: merged.scoringMultipliers,
        turnTimer: merged.turnTimer
      });
      Object.assign(variant, merged, { updatedAt: nowIso() });
      return variant;
    },
    validate: ({ variantId, userId }) => {
      assertString(variantId, 'variantId');
      assertString(userId, 'userId');
      const variant = state.gameVariants.find((item) => item.id === variantId);
      if (!variant) throw new HttpError(404, 'VARIANT_NOT_FOUND');
      if (variant.authorUserId !== userId) throw new HttpError(403, 'FORBIDDEN');
      const errors = [];
      if (variant.winCondition.toLowerCase().includes('invalid')) errors.push('WIN_CONDITION_UNSUPPORTED');
      if (variant.boardSize < 3 || variant.boardSize > 8) errors.push('BOARD_SIZE_OUT_OF_RANGE');
      if (!Object.keys(variant.scoringMultipliers).length) errors.push('SCORING_MULTIPLIERS_EMPTY');
      variant.validationErrors = errors;
      variant.updatedAt = nowIso();
      return { ok: errors.length === 0, errors };
    },
    publish: ({ variantId, userId }) => {
      const variant = variants.update({ variantId, userId, patch: {} });
      const validation = variants.validate({ variantId, userId });
      if (!validation.ok) throw new HttpError(409, 'VARIANT_VALIDATION_FAILED', { errors: validation.errors });
      variant.status = 'published';
      variant.publishedAt = nowIso();
      variant.privateLinkToken = `variant-${variant.id}-${Math.random().toString(36).slice(2, 8)}`;
      state.analytics.push({
        id: newId('event'),
        eventName: 'variant_publish',
        userId,
        sessionId: null,
        payload: { variantId },
        source: 'backend',
        ts: nowIso()
      });
      return { ok: true, privateLink: `/join-variant/${variant.privateLinkToken}`, variant };
    },
    resolvePrivateLink: ({ token }) => {
      assertString(token, 'token');
      const variant = state.gameVariants.find((item) => item.privateLinkToken === token && item.status === 'published');
      if (!variant) throw new HttpError(404, 'VARIANT_LINK_NOT_FOUND');
      return variant;
    }
  };

  const moderation = {
    report: ({ reporterUserId, targetType, targetId, reason, source = 'game_room', policyType = DEFAULT_POLICY[0] }) => {
      assertString(reporterUserId, 'reporterUserId');
      assertString(targetType, 'targetType');
      assertString(targetId, 'targetId');
      assertString(reason, 'reason', { min: 3 });
      if (!['chat', 'profile', 'variant'].includes(targetType)) throw new HttpError(400, 'REPORT_TARGET_UNSUPPORTED', { targetType });
      if (targetType === 'variant' && !editorEnabled) throw new HttpError(409, 'VARIANT_REPORTS_DISABLED');
      if (!DEFAULT_POLICY.includes(policyType)) throw new HttpError(400, 'REPORT_POLICY_UNSUPPORTED', { policyType, allowed: DEFAULT_POLICY });
      const report = { id: newId('report'), reporterUserId, targetType, targetId, reason, source, policyType, createdAt: nowIso() };
      state.reports.push(report);
      const modCase = {
        id: newId('case'),
        status: 'open',
        reportId: report.id,
        reporterUserId,
        targetType,
        targetId,
        reason,
        policyType,
        source,
        createdAt: nowIso(),
        updatedAt: nowIso(),
        resolution: null
      };
      state.moderationCases.push(modCase);
      state.analytics.push({
        id: newId('event'),
        eventName: 'report_sent',
        userId: reporterUserId,
        sessionId: null,
        payload: { targetType, targetId },
        source: 'backend',
        ts: nowIso()
      });
      return { report, case: modCase };
    },
    listReports: () => state.reports,
    listCases: ({ status = null } = {}) => {
      if (!status) return state.moderationCases;
      return state.moderationCases.filter((item) => item.status === status);
    },
    getCaseById: ({ caseId }) => {
      assertString(caseId, 'caseId');
      const item = state.moderationCases.find((c) => c.id === caseId);
      if (!item) throw new HttpError(404, 'MODERATION_CASE_NOT_FOUND');
      return item;
    },
    updateCaseStatus: ({ caseId, status, moderatorUserId = 'admin' }) => {
      assertString(caseId, 'caseId');
      assertString(status, 'status');
      if (!['open', 'in_review', 'closed'].includes(status)) throw new HttpError(400, 'MODERATION_STATUS_UNSUPPORTED', { status });
      const item = moderation.getCaseById({ caseId });
      item.status = status;
      item.updatedAt = nowIso();
      addModerationAudit({ moderatorUserId, action: 'case_status_update', caseId, payload: { status } });
      return item;
    },
    ban: ({ userId, reason, duration = '24h', moderatorUserId = 'admin', caseId = null }) => {
      assertString(userId, 'userId');
      assertString(reason, 'reason');
      assertString(duration, 'duration');
      assertKnownUser(userId);
      for (const row of state.sanctions) {
        if (row.userId === userId && row.type === 'ban' && row.active) {
          row.active = false;
          row.updatedAt = nowIso();
        }
      }
      const sanction = {
        id: newId('sanction'),
        type: 'ban',
        userId,
        reason,
        duration,
        expiresAt: parseDurationToExpiresAt(duration),
        active: true,
        createdAt: nowIso(),
        updatedAt: nowIso(),
        moderatorUserId
      };
      state.sanctions.push(sanction);
      addModerationAudit({ moderatorUserId, action: 'ban', caseId, userId, payload: { reason, duration, sanctionId: sanction.id } });
      if (caseId) {
        const item = moderation.getCaseById({ caseId });
        item.status = 'closed';
        item.updatedAt = nowIso();
        item.resolution = { action: 'ban', sanctionId: sanction.id, moderatorUserId, reason, duration, at: nowIso() };
      }
      return { ...sanction, action: 'ban' };
    },
    mute: ({ userId, reason, duration = '1h', moderatorUserId = 'admin', caseId = null }) => {
      assertString(userId, 'userId');
      assertString(reason, 'reason');
      assertString(duration, 'duration');
      assertKnownUser(userId);
      for (const row of state.sanctions) {
        if (row.userId === userId && row.type === 'mute' && row.active) {
          row.active = false;
          row.updatedAt = nowIso();
        }
      }
      const sanction = {
        id: newId('sanction'),
        type: 'mute',
        userId,
        reason,
        duration,
        expiresAt: parseDurationToExpiresAt(duration),
        active: true,
        createdAt: nowIso(),
        updatedAt: nowIso(),
        moderatorUserId
      };
      state.sanctions.push(sanction);
      addModerationAudit({ moderatorUserId, action: 'mute', caseId, userId, payload: { reason, duration, sanctionId: sanction.id } });
      if (caseId) {
        const item = moderation.getCaseById({ caseId });
        item.status = 'closed';
        item.updatedAt = nowIso();
        item.resolution = { action: 'mute', sanctionId: sanction.id, moderatorUserId, reason, duration, at: nowIso() };
      }
      return { ...sanction, action: 'mute' };
    },
    unban: ({ userId, reason = 'manual_review', moderatorUserId = 'admin', caseId = null }) => {
      assertString(userId, 'userId');
      assertKnownUser(userId);
      const activeBans = state.sanctions.filter(
        (row) => row.userId === userId && row.type === 'ban' && row.active && (!row.expiresAt || Date.parse(row.expiresAt) > Date.now())
      );
      if (!activeBans.length) throw new HttpError(404, 'ACTIVE_BAN_NOT_FOUND', { userId });
      for (const activeBan of activeBans) {
        activeBan.active = false;
        activeBan.updatedAt = nowIso();
      }
      addModerationAudit({
        moderatorUserId,
        action: 'unban',
        caseId,
        userId,
        payload: { reason, sanctionIds: activeBans.map((item) => item.id) }
      });
      if (caseId) {
        const item = moderation.getCaseById({ caseId });
        item.status = 'closed';
        item.updatedAt = nowIso();
        item.resolution = { action: 'unban', sanctionIds: activeBans.map((entry) => entry.id), moderatorUserId, reason, at: nowIso() };
      }
      return { ok: true, userId, action: 'unban', reason };
    },
    auditLog: () => state.moderationAuditLogs,
    policies: () => ({ durations: BAN_DURATIONS, policyTypes: DEFAULT_POLICY })
  };

  const analytics = {
    track: ({ eventName, userId = null, sessionId = null, payload = {}, source = 'backend' }) => {
      assertString(eventName, 'eventName');
      const allowed = new Set([
        'onboarding_complete',
        'login_success',
        'match_create',
        'match_move',
        'match_finish',
        'store_view',
        'purchase_attempt',
        'purchase_success',
        'variant_publish',
        'report_sent',
        'latency_move',
        'level_complete',
        'campaign_finished',
        'reconnect_count',
        'ws_disconnects',
        'video_connect_failures'
      ]);
      if (!allowed.has(eventName)) throw new HttpError(400, 'ANALYTICS_EVENT_UNSUPPORTED', { eventName });
      const row = { id: newId('event'), eventName, userId, sessionId, payload, source, ts: nowIso() };
      state.analytics.push(row);
      state.eventQueue.push({
        id: `queue_${row.id}`,
        topic: 'analytics.events',
        payload: { ...row, userId: row.userId ? `anon_${String(row.userId).slice(-6)}` : null }
      });
      return { ok: true, event: row };
    },
    list: ({ limit = 200, eventName = null }) => {
      const rows = eventName ? state.analytics.filter((e) => e.eventName === eventName) : state.analytics;
      return rows.slice(-Math.max(1, Math.min(limit, 1000))).reverse();
    },
    dashboard: () => {
      const now = Date.now();
      const dayMs = 86_400_000;
      const from = now - 7 * dayMs;
      const last7dEvents = state.analytics.filter((e) => Date.parse(e.ts) >= from);
      const matches7d = last7dEvents.filter((e) => e.eventName === 'match_create').length;
      const dauMap = new Map();
      for (const event of state.analytics) {
        if (!event.userId) continue;
        const day = event.ts.slice(0, 10);
        if (!dauMap.has(day)) dauMap.set(day, new Set());
        dauMap.get(day).add(event.userId);
      }
      const dauProxy = [...dauMap.entries()]
        .sort((a, b) => a[0].localeCompare(b[0]))
        .slice(-7)
        .map(([day, users]) => ({ day, uniqueUsers: users.size }));
      return {
        matches7d,
        dauProxy,
        technical: { ...state.technicalMetrics }
      };
    },
    incMetric: (name, value = 1) => {
      if (!(name in state.technicalMetrics)) throw new HttpError(400, 'UNKNOWN_TECHNICAL_METRIC', { name });
      state.technicalMetrics[name] += Number(value) || 0;
      return { ok: true, value: state.technicalMetrics[name] };
    },
    publish: ({ topic = 'analytics.events', payload = {} }) => {
      assertString(topic, 'topic');
      const item = { id: newId('queue'), topic, payload, ts: nowIso() };
      state.eventQueue.push(item);
      return { ok: true, queued: item };
    },
    queryQueue: ({ topic = null, limit = 100 }) => {
      const rows = topic ? state.eventQueue.filter((item) => item.topic === topic) : state.eventQueue;
      return rows.slice(-Math.max(1, Math.min(limit, 1000))).reverse();
    },
    prometheus: () => {
      const matches = state.analytics.filter((row) => row.eventName === 'match_create').length;
      const finished = state.analytics.filter((row) => row.eventName === 'match_finish').length;
      return `# HELP tabletop_matches_created total created matches\n# TYPE tabletop_matches_created counter\ntabletop_matches_created ${matches}\n# HELP tabletop_matches_finished total finished matches\n# TYPE tabletop_matches_finished counter\ntabletop_matches_finished ${finished}\n`;
    }
  };

  const webrtc = {
    createToken: ({ userId, roomId, ttlSec = 3600 }) => {
      assertString(userId, 'userId');
      assertString(roomId, 'roomId');
      return {
        token: `webrtc.${userId}.${roomId}.${Date.now()}`,
        expiresAt: new Date(Date.now() + Number(ttlSec) * 1000).toISOString(),
        roomId
      };
    },
    groupConfig: ({ roomId }) => ({
      roomId,
      maxParticipants: 4,
      turnFallbackAfterIceFailures: 3
    }),
    muteAll: ({ roomId, moderatorUserId = 'host' }) => ({
      ok: true,
      roomId,
      moderatorUserId,
      mutedAt: nowIso()
    }),
    connectivityTest: () => ({
      ok: true,
      participantsSupported: 4,
      simulatedLatencyMs: 120,
      turnFallbackAfterIceFailures: 3
    })
  };

  store.iapSuccess = ({ userId, sku, platform = 'unknown', purchaseToken = null }) => {
    assertString(userId, 'userId');
    assertString(sku, 'sku');
    assertKnownUser(userId);
    const inventory = state.inventory.get(userId) ?? [];
    const record = {
      id: newId('purchase'),
      userId,
      sku,
      type: 'SUBSCRIPTION',
      purchasedAt: nowIso(),
      mode: 'iap',
      platform,
      purchaseToken,
      applied: false
    };
    state.purchases.push(record);
    inventory.push(record);
    state.inventory.set(userId, inventory);
    return { ok: true, item: record };
  };

  return {
    state,
    auth,
    users,
    catalog,
    matches,
    campaigns,
    leaderboards,
    webrtc,
    store,
    variants,
    moderation,
    analytics,
    securityConfig,
    HttpError
  };
};
