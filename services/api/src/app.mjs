/**
 * Назначение файла: реализовать in-memory backend-ядро API для MVP без внешней БД.
 * Роль в проекте: предоставлять бизнес-операции модулей Auth/Users/Catalog/Matches/Store/Moderation/Analytics.
 * Основные функции: регистрация/логин, каталог игр, матчи и ходы, инвентарь, жалобы, админ-санкции.
 * Связи с другими файлами: использует rules-engine (services/rules-engine/src/index.mjs) и realtime gateway.
 * Важно при изменении: сохранять простые контракты методов, так как на них опираются интеграционные тесты.
 */

import { applyMove, SUPPORTED_GAMES } from '../../rules-engine/src/index.mjs';

const nowIso = () => new Date().toISOString();

const newId = (prefix) => `${prefix}_${Math.random().toString(36).slice(2, 10)}`;

const createTokens = (userId) => ({
  accessToken: `access.${userId}.${Date.now()}`,
  refreshToken: `refresh.${userId}.${Date.now()}`
});

export const createApiApp = ({ gateway, config = {} } = {}) => {
  const state = {
    users: [],
    sessions: new Map(),
    matches: [],
    inventory: new Map(),
    reports: [],
    sanctions: { bans: new Set(), mutes: new Set() },
    analytics: []
  };

  const games = [
    { id: 'tile_placement_demo', title: 'Tile Placement Demo', langs: ['ru', 'en'] },
    { id: 'roll_and_write_demo', title: 'Roll & Write Demo', langs: ['ru', 'en'] }
  ];

  const auth = {
    register: ({ email, password, lang = config.DEFAULT_LANG ?? 'ru' }) => {
      if (state.users.some((u) => u.email === email)) {
        throw new Error('USER_EXISTS');
      }
      const user = { id: newId('user'), email, password, lang, createdAt: nowIso() };
      state.users.push(user);
      state.inventory.set(user.id, []);
      return { id: user.id, email: user.email, lang: user.lang };
    },
    login: ({ email, password }) => {
      const user = state.users.find((u) => u.email === email && u.password === password);
      if (!user) throw new Error('INVALID_CREDENTIALS');
      const tokens = createTokens(user.id);
      state.sessions.set(tokens.refreshToken, { userId: user.id, createdAt: nowIso() });
      return { user: { id: user.id, email: user.email }, ...tokens };
    },
    refresh: ({ refreshToken }) => {
      const session = state.sessions.get(refreshToken);
      if (!session) throw new Error('SESSION_NOT_FOUND');
      const tokens = createTokens(session.userId);
      state.sessions.set(tokens.refreshToken, { userId: session.userId, createdAt: nowIso() });
      state.sessions.delete(refreshToken);
      return tokens;
    },
    logoutAll: ({ userId }) => {
      for (const [token, session] of state.sessions.entries()) {
        if (session.userId === userId) state.sessions.delete(token);
      }
      return { ok: true };
    }
  };

  const users = {
    inventory: ({ userId }) => state.inventory.get(userId) ?? []
  };

  const catalog = {
    listGames: () => games,
    getGame: (id) => games.find((g) => g.id === id) ?? null
  };

  const matches = {
    create: ({ gameId, players }) => {
      if (!SUPPORTED_GAMES.includes(gameId)) throw new Error('UNSUPPORTED_GAME');
      if (!Array.isArray(players) || players.length < 2) throw new Error('NEED_TWO_PLAYERS');
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
        snapshots: []
      };
      state.matches.push(match);
      gateway?.emitMatchState(match.id, match);
      return match;
    },
    list: () => state.matches,
    getById: (id) => state.matches.find((m) => m.id === id) ?? null,
    move: ({ matchId, playerId, action, points = 1 }) => {
      const match = matches.getById(matchId);
      if (!match) throw new Error('MATCH_NOT_FOUND');
      const result = applyMove(match, { playerId, action, points, ts: nowIso() });
      if (!result.accepted) throw new Error(result.reason);
      const next = result.state;
      Object.assign(match, next);

      // Для MVP сохраняем снимок после каждого хода (N=1), чтобы упростить отладку.
      match.snapshots.push({ moveNumber: match.moveNumber, state: structuredClone(match) });

      gateway?.emitMatchState(match.id, match);
      gateway?.emitRoomEvent(match.id, 'match.move.applied', { matchId, moveNumber: match.moveNumber });
      return match;
    }
  };

  const store = {
    purchaseSandbox: ({ userId, sku }) => {
      const inventory = state.inventory.get(userId) ?? [];
      inventory.push({ sku, purchasedAt: nowIso(), mode: 'sandbox' });
      state.inventory.set(userId, inventory);
      return { ok: true, item: inventory[inventory.length - 1] };
    }
  };

  const moderation = {
    report: ({ reporterUserId, targetType, targetId, reason }) => {
      const report = { id: newId('report'), reporterUserId, targetType, targetId, reason, createdAt: nowIso() };
      state.reports.push(report);
      return report;
    },
    listReports: () => state.reports,
    ban: ({ userId, reason }) => {
      state.sanctions.bans.add(userId);
      return { userId, reason, action: 'ban', createdAt: nowIso() };
    },
    mute: ({ userId, reason }) => {
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

  return { state, auth, users, catalog, matches, store, moderation, analytics };
};
