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
    MATCH_STORE_FILE: config.MATCH_STORE_FILE ?? path.join(process.cwd(), '.data', 'matches.json')
  };

  const state = {
    users: [],
    sessions: new Map(),
    matches: [],
    inventory: new Map(),
    reports: [],
    sanctions: { bans: new Set(), mutes: new Set() },
    analytics: [],
    securityLogs: []
  };

  const persistMatches = () => {
    const target = securityConfig.MATCH_STORE_FILE;
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.writeFileSync(target, JSON.stringify(state.matches.map(toSerializableMatch), null, 2));
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

  const addSecurityLog = (kind, payload) => state.securityLogs.push({ id: newId('seclog'), kind, payload, ts: nowIso() });

  const auth = {
    register: ({ email, password, lang = securityConfig.DEFAULT_LANG }) => {
      assertString(email, 'email', { min: 5 });
      assertString(password, 'password', { min: 6 });
      if (state.users.some((u) => u.email === email)) throw new HttpError(409, 'USER_EXISTS');
      const user = { id: newId('user'), email, passwordHash: hashPassword(password), lang, createdAt: nowIso() };
      state.users.push(user);
      state.inventory.set(user.id, []);
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
      if (state.sanctions.bans.has(user.id)) throw new HttpError(403, 'USER_BANNED');
      const tokens = createTokens(user.id);
      state.sessions.set(tokens.refreshToken, { userId: user.id, expiresAt: Date.now() + securityConfig.REFRESH_TTL_DAYS * 86400000 });
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
      return state.inventory.get(userId) ?? [];
    }
  };

  const catalog = {
    listGames: () => games,
    getGame: (id) => games.find((g) => g.id === id) ?? null
  };

  const matches = {
    create: ({ gameId, players, botLevel = null }) => {
      assertString(gameId, 'gameId');
      assertArray(players, 'players', { min: 2 });
      if (!SUPPORTED_GAMES.includes(gameId)) throw new HttpError(400, 'UNSUPPORTED_GAME');
      const seed = Math.floor(Math.random() * 1_000_000_000);
      const match = {
        id: newId('match'),
        gameId,
        players,
        currentPlayer: players[0],
        moveNumber: 0,
        maxMoves: gameId === 'tile_placement_demo' ? 16 : 25,
        scores: Object.fromEntries(players.map((p) => [p, 0])),
        log: [],
        status: 'active',
        winner: null,
        snapshots: [],
        acceptedMoveIds: new Set(),
        gameState: createInitialGameState(gameId, players, seed),
        bot: botLevel ? { enabled: true, playerId: players[1], level: botLevel } : { enabled: false }
      };
      state.matches.push(match);
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
      moveLimiter.hit(`move:${playerId}`);
      const match = state.matches.find((m) => m.id === matchId);
      if (!match) throw new HttpError(404, 'MATCH_NOT_FOUND');
      if (match.acceptedMoveIds.has(moveId)) throw new HttpError(409, 'MOVE_ID_ALREADY_PROCESSED');
      if (match.currentPlayer !== playerId) {
        addSecurityLog('MOVE_NOT_YOUR_TURN', { matchId, playerId, ip });
        throw new HttpError(403, 'NOT_YOUR_TURN');
      }

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

      persistMatches();
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
    }
  };

  const store = {
    purchaseSandbox: ({ userId, sku }) => {
      assertString(userId, 'userId');
      assertString(sku, 'sku');
      const inventory = state.inventory.get(userId) ?? [];
      inventory.push({ sku, purchasedAt: nowIso(), mode: 'sandbox' });
      state.inventory.set(userId, inventory);
      return { ok: true, item: inventory[inventory.length - 1] };
    }
  };

  const moderation = {
    report: ({ reporterUserId, targetType, targetId, reason }) => {
      assertString(reporterUserId, 'reporterUserId');
      assertString(targetType, 'targetType');
      assertString(targetId, 'targetId');
      assertString(reason, 'reason', { min: 3 });
      const report = { id: newId('report'), reporterUserId, targetType, targetId, reason, createdAt: nowIso() };
      state.reports.push(report);
      return report;
    },
    listReports: () => state.reports,
    ban: ({ userId, reason }) => {
      assertString(userId, 'userId');
      assertString(reason, 'reason');
      state.sanctions.bans.add(userId);
      return { userId, reason, action: 'ban', createdAt: nowIso() };
    },
    mute: ({ userId, reason }) => {
      assertString(userId, 'userId');
      assertString(reason, 'reason');
      state.sanctions.mutes.add(userId);
      return { userId, reason, action: 'mute', createdAt: nowIso() };
    }
  };

  const analytics = {
    track: (event) => {
      state.analytics.push({ id: newId('event'), ...event, ts: nowIso() });
      return { ok: true };
    }
  };

  return { state, auth, users, catalog, matches, store, moderation, analytics, securityConfig, HttpError };
};
