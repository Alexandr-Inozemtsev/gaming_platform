/**
 * Назначение файла: реализовать in-memory backend-ядро API для MVP с усилениями безопасности.
 * Роль в проекте: предоставлять безопасные бизнес-операции модулей Auth/Users/Catalog/Matches/Store/Moderation/Analytics.
 * Основные функции: access/refresh/logoutAll, хэширование паролей, DTO-валидация, idempotency ходов, rate limiting и security-логи.
 * Связи с другими файлами: использует rules-engine (services/rules-engine/src/index.mjs), realtime gateway и HTTP слой server.mjs.
 * Важно при изменении: сохранять сервер-авторитет (клиенту не доверять очки/rng/очерёдность), не хранить секреты в коде.
 */

import crypto from 'node:crypto';
import { applyMove, SUPPORTED_GAMES, rng } from '../../rules-engine/src/index.mjs';

/**
 * Класс ошибки с HTTP-статусом нужен для точного маппинга бизнес-ошибок в корректные коды ответа.
 */
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

/**
 * Хэшируем через scrypt из стандартной библиотеки: решение выбрано из-за отсутствия гарантии наличия argon2/bcrypt в окружении.
 * В документации явно помечаем ограничение и шаг миграции.
 */
const hashPassword = (password) => {
  const salt = crypto.randomBytes(16).toString('hex');
  const derived = crypto.scryptSync(password, salt, 64).toString('hex');
  return `scrypt$${salt}$${derived}`;
};

/**
 * Верификация пароля повторяет алгоритм и сравнивает хэши через timingSafeEqual, чтобы снизить риск тайминговых атак.
 */
const verifyPassword = (password, storedHash) => {
  const [alg, salt, stored] = String(storedHash).split('$');
  if (alg !== 'scrypt' || !salt || !stored) return false;
  const derived = crypto.scryptSync(password, salt, 64).toString('hex');
  return crypto.timingSafeEqual(Buffer.from(derived), Buffer.from(stored));
};

/**
 * Централизованный лимитер реализован in-memory как MVP-компромисс: простой и предсказуемый, но не распределённый.
 */
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
      if (item.count > limit) {
        throw new HttpError(429, 'RATE_LIMIT_EXCEEDED', { key, resetAt: item.resetAt });
      }
    }
  };
};

/**
 * Строгая валидация DTO намеренно явная и ручная: это прозрачно для MVP и облегчает чтение тестов.
 */
const assertString = (value, field, { min = 1 } = {}) => {
  if (typeof value !== 'string' || value.trim().length < min) {
    throw new HttpError(400, 'VALIDATION_ERROR', { field });
  }
};

const assertArray = (value, field, { min = 1 } = {}) => {
  if (!Array.isArray(value) || value.length < min) {
    throw new HttpError(400, 'VALIDATION_ERROR', { field });
  }
};

const createTokens = (userId) => ({
  accessToken: `access.${userId}.${Date.now()}`,
  refreshToken: `refresh.${userId}.${Date.now()}`
});

export const createApiApp = ({ gateway, config = {} } = {}) => {
  const securityConfig = {
    RATE_LIMIT_LOGIN: Number(config.RATE_LIMIT_LOGIN ?? 10),
    RATE_LIMIT_MOVE: Number(config.RATE_LIMIT_MOVE ?? 60),
    SESSION_TTL_MIN: Number(config.SESSION_TTL_MIN ?? 30),
    REFRESH_TTL_DAYS: Number(config.REFRESH_TTL_DAYS ?? 30),
    DEFAULT_LANG: config.DEFAULT_LANG ?? 'ru',
    MATCH_STATE_SNAPSHOT_EVERY_N_MOVES: Number(config.MATCH_STATE_SNAPSHOT_EVERY_N_MOVES ?? 1),
    REQUIRE_TLS_IN_PROD: String(config.REQUIRE_TLS_IN_PROD ?? 'true') === 'true'
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

  const loginLimiter = createRateLimiter({ limit: securityConfig.RATE_LIMIT_LOGIN, windowMs: 60_000 });
  const moveLimiter = createRateLimiter({ limit: securityConfig.RATE_LIMIT_MOVE, windowMs: 60_000 });

  const games = [
    { id: 'tile_placement_demo', title: 'Tile Placement Demo', langs: ['ru', 'en'] },
    { id: 'roll_and_write_demo', title: 'Roll & Write Demo', langs: ['ru', 'en'] }
  ];

  const addSecurityLog = (kind, payload) => {
    state.securityLogs.push({ id: newId('seclog'), kind, payload, ts: nowIso() });
  };

  const auth = {
    register: ({ email, password, lang = securityConfig.DEFAULT_LANG }) => {
      assertString(email, 'email', { min: 5 });
      assertString(password, 'password', { min: 6 });
      if (state.users.some((u) => u.email === email)) {
        throw new HttpError(409, 'USER_EXISTS');
      }
      const user = { id: newId('user'), email, passwordHash: hashPassword(password), lang, createdAt: nowIso() };
      state.users.push(user);
      state.inventory.set(user.id, []);
      return { id: user.id, email: user.email, lang: user.lang };
    },
    login: ({ email, password, ip = 'local' }) => {
      assertString(email, 'email', { min: 5 });
      assertString(password, 'password', { min: 1 });
      loginLimiter.hit(`login:${ip}`);

      const user = state.users.find((u) => u.email === email);
      if (!user || !verifyPassword(password, user.passwordHash)) {
        addSecurityLog('SUSPICIOUS_LOGIN', { email, ip });
        throw new HttpError(401, 'INVALID_CREDENTIALS');
      }

      if (state.sanctions.bans.has(user.id)) {
        throw new HttpError(403, 'USER_BANNED');
      }

      const tokens = createTokens(user.id);
      state.sessions.set(tokens.refreshToken, {
        userId: user.id,
        createdAt: nowIso(),
        expiresAt: Date.now() + securityConfig.REFRESH_TTL_DAYS * 24 * 60 * 60 * 1000
      });
      return { user: { id: user.id, email: user.email }, ...tokens };
    },
    refresh: ({ refreshToken }) => {
      assertString(refreshToken, 'refreshToken', { min: 10 });
      const session = state.sessions.get(refreshToken);
      if (!session) throw new HttpError(401, 'SESSION_NOT_FOUND');
      if (Date.now() > session.expiresAt) {
        state.sessions.delete(refreshToken);
        throw new HttpError(401, 'SESSION_EXPIRED');
      }
      const tokens = createTokens(session.userId);
      state.sessions.set(tokens.refreshToken, {
        userId: session.userId,
        createdAt: nowIso(),
        expiresAt: Date.now() + securityConfig.REFRESH_TTL_DAYS * 24 * 60 * 60 * 1000
      });
      state.sessions.delete(refreshToken);
      return tokens;
    },
    logoutAll: ({ userId }) => {
      assertString(userId, 'userId');
      for (const [token, session] of state.sessions.entries()) {
        if (session.userId === userId) state.sessions.delete(token);
      }
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
    create: ({ gameId, players }) => {
      assertString(gameId, 'gameId');
      assertArray(players, 'players', { min: 2 });
      players.forEach((p, idx) => assertString(p, `players[${idx}]`));
      if (!SUPPORTED_GAMES.includes(gameId)) throw new HttpError(400, 'UNSUPPORTED_GAME');

      const serverSeed = Math.floor(Math.random() * 1_000_000_000);
      const match = {
        id: newId('match'),
        gameId,
        players,
        currentPlayer: players[0],
        moveNumber: 0,
        maxMoves: 3,
        scores: Object.fromEntries(players.map((p) => [p, 0])),
        log: [],
        status: 'active',
        winner: null,
        snapshots: [],
        acceptedMoveIds: new Set(),
        serverSeed,
        rngState: rng(serverSeed)
      };
      state.matches.push(match);
      gateway?.emitMatchState(match.id, match);
      return { ...match, rngState: undefined };
    },
    list: () => state.matches.map((m) => ({ ...m, rngState: undefined })),
    getById: (id) => {
      const found = state.matches.find((m) => m.id === id) ?? null;
      return found ? { ...found, rngState: undefined } : null;
    },
    move: ({ matchId, playerId, action, moveId, ip = 'local' }) => {
      assertString(matchId, 'matchId');
      assertString(playerId, 'playerId');
      assertString(action, 'action');
      assertString(moveId, 'moveId');

      moveLimiter.hit(`move:${playerId}`);

      const match = state.matches.find((m) => m.id === matchId);
      if (!match) throw new HttpError(404, 'MATCH_NOT_FOUND');

      if (match.acceptedMoveIds.has(moveId)) {
        throw new HttpError(409, 'MOVE_ID_ALREADY_PROCESSED');
      }

      if (match.currentPlayer !== playerId) {
        addSecurityLog('MOVE_NOT_YOUR_TURN', { matchId, playerId, ip });
        throw new HttpError(403, 'NOT_YOUR_TURN');
      }

      // Античит: очки вычисляет только сервер через собственный RNG и не принимает points от клиента.
      const randomFactor = match.rngState();
      const points = action === 'pass' ? 0 : 1 + Math.floor(randomFactor * 3);

      const result = applyMove(match, { playerId, action, points, moveId, ts: nowIso() });
      if (!result.accepted) {
        if (result.reason === 'NOT_YOUR_TURN') throw new HttpError(403, 'NOT_YOUR_TURN');
        throw new HttpError(400, result.reason ?? 'MOVE_REJECTED');
      }

      const next = result.state;
      Object.assign(match, next);
      match.acceptedMoveIds.add(moveId);

      if (match.moveNumber % securityConfig.MATCH_STATE_SNAPSHOT_EVERY_N_MOVES === 0) {
        match.snapshots.push({ moveNumber: match.moveNumber, state: structuredClone({ ...match, rngState: undefined }) });
      }

      gateway?.emitMatchState(match.id, { ...match, rngState: undefined });
      gateway?.emitRoomEvent(match.id, 'match.move.applied', { matchId, moveNumber: match.moveNumber });
      return { ...match, rngState: undefined };
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
