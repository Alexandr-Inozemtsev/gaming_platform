/**
 * Назначение файла: предоставить HTTP-обработчик с обязательными endpoint'ами MVP API и security-политиками.
 * Роль в проекте: связывать REST-маршруты с in-memory приложением createApiApp() и отдавать корректные HTTP коды ошибок.
 * Основные функции: парсинг JSON, маршрутизация endpoint'ов, проверка REQUIRE_TLS_IN_PROD, единый error handling.
 * Связи с другими файлами: использует app.mjs, в том числе класс HttpError и настройки безопасности.
 * Важно при изменении: не нарушать контракты endpoint'ов и соответствие кодов ошибок acceptance-критериям.
 */

import http from 'node:http';
import { createApiApp } from './app.mjs';

const parseBody = async (req) => {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  const raw = Buffer.concat(chunks).toString('utf8');
  return raw ? JSON.parse(raw) : {};
};

const send = (res, status, data) => {
  res.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(data));
};

export const createHttpHandler = (deps = {}) => {
  const app = createApiApp(deps);
  const logLevel = process.env.LOG_LEVEL ?? 'info';

  return async (req, res) => {
    const startedAt = Date.now();
    try {
      const url = new URL(req.url, 'http://localhost');
      const method = req.method;

      const isProd = process.env.NODE_ENV === 'production';
      const proto = req.headers['x-forwarded-proto'] ?? 'http';
      if (isProd && app.securityConfig.REQUIRE_TLS_IN_PROD && proto !== 'https') {
        return send(res, 426, { error: 'TLS_REQUIRED' });
      }

      if (method === 'POST' && url.pathname === '/auth/register') return send(res, 201, app.auth.register(await parseBody(req)));
      if (method === 'POST' && url.pathname === '/auth/login') {
        return send(res, 200, app.auth.login({ ...(await parseBody(req)), ip: req.socket.remoteAddress ?? 'local' }));
      }
      if (method === 'POST' && url.pathname === '/auth/refresh') return send(res, 200, app.auth.refresh(await parseBody(req)));
      if (method === 'POST' && url.pathname === '/auth/logoutAll') return send(res, 200, app.auth.logoutAll(await parseBody(req)));

      if (method === 'GET' && url.pathname === '/games') return send(res, 200, app.catalog.listGames());
      if (method === 'GET' && url.pathname.startsWith('/games/')) return send(res, 200, app.catalog.getGame(url.pathname.split('/')[2]));
      if (method === 'GET' && /^\/games\/[^/]+\/variants$/.test(url.pathname)) {
        const gameId = url.pathname.split('/')[2];
        return send(res, 200, app.variants.listByGame({ gameId, userId: url.searchParams.get('userId') }));
      }

      if (method === 'POST' && url.pathname === '/matches') return send(res, 201, app.matches.create(await parseBody(req)));
      if (method === 'GET' && url.pathname === '/matches') return send(res, 200, app.matches.list());
      if (method === 'GET' && /^\/matches\/[^/]+$/.test(url.pathname)) return send(res, 200, app.matches.getById(url.pathname.split('/')[2]));
      if (method === 'POST' && /^\/matches\/[^/]+\/move$/.test(url.pathname)) {
        const matchId = url.pathname.split('/')[2];
        return send(
          res,
          200,
          app.matches.move({ matchId, ...(await parseBody(req)), ip: req.socket.remoteAddress ?? 'local' })
        );
      }

      if (method === 'GET' && url.pathname === '/store/skus') return send(res, 200, app.store.skus());
      if (method === 'POST' && url.pathname === '/store/purchase-sandbox') return send(res, 200, app.store.purchaseSandbox(await parseBody(req)));
      if (method === 'POST' && url.pathname === '/store/apply-skin') return send(res, 200, app.store.applySkin(await parseBody(req)));
      if (method === 'GET' && url.pathname === '/inventory') return send(res, 200, app.users.inventory({ userId: url.searchParams.get('userId') }));
      if (method === 'GET' && url.pathname === '/variants') return send(res, 200, app.variants.listMine({ userId: url.searchParams.get('userId') }));
      if (method === 'POST' && url.pathname === '/variants') return send(res, 201, app.variants.createDraft(await parseBody(req)));
      if (method === 'PUT' && /^\/variants\/[^/]+$/.test(url.pathname)) {
        const variantId = url.pathname.split('/')[2];
        const body = await parseBody(req);
        return send(res, 200, app.variants.update({ variantId, userId: body.userId, patch: body.patch ?? {} }));
      }
      if (method === 'POST' && /^\/variants\/[^/]+\/validate$/.test(url.pathname)) {
        const variantId = url.pathname.split('/')[2];
        return send(res, 200, app.variants.validate({ variantId, ...(await parseBody(req)) }));
      }
      if (method === 'POST' && /^\/variants\/[^/]+\/publish$/.test(url.pathname)) {
        const variantId = url.pathname.split('/')[2];
        return send(res, 200, app.variants.publish({ variantId, ...(await parseBody(req)) }));
      }
      if (method === 'GET' && /^\/join-variant\/[^/]+$/.test(url.pathname)) {
        const token = url.pathname.split('/')[2];
        return send(res, 200, app.variants.resolvePrivateLink({ token }));
      }

      if (method === 'POST' && url.pathname === '/reports') return send(res, 201, app.moderation.report(await parseBody(req)));
      if (method === 'GET' && url.pathname === '/admin/reports') return send(res, 200, app.moderation.listReports());
      if (method === 'GET' && url.pathname === '/admin/cases') {
        return send(res, 200, app.moderation.listCases({ status: url.searchParams.get('status') }));
      }
      if (method === 'GET' && /^\/admin\/cases\/[^/]+$/.test(url.pathname)) {
        const caseId = url.pathname.split('/')[3];
        return send(res, 200, app.moderation.getCaseById({ caseId }));
      }
      if (method === 'POST' && /^\/admin\/cases\/[^/]+\/status$/.test(url.pathname)) {
        const caseId = url.pathname.split('/')[3];
        return send(res, 200, app.moderation.updateCaseStatus({ caseId, ...(await parseBody(req)) }));
      }
      if (method === 'POST' && url.pathname === '/admin/ban') return send(res, 200, app.moderation.ban(await parseBody(req)));
      if (method === 'POST' && url.pathname === '/admin/mute') return send(res, 200, app.moderation.mute(await parseBody(req)));
      if (method === 'POST' && url.pathname === '/admin/unban') return send(res, 200, app.moderation.unban(await parseBody(req)));
      if (method === 'GET' && url.pathname === '/admin/moderation/audit') return send(res, 200, app.moderation.auditLog());
      if (method === 'GET' && url.pathname === '/admin/moderation/policies') return send(res, 200, app.moderation.policies());
      if (method === 'POST' && url.pathname === '/analytics/events') return send(res, 201, app.analytics.track(await parseBody(req)));
      if (method === 'GET' && url.pathname === '/analytics/events') {
        return send(
          res,
          200,
          app.analytics.list({ limit: Number(url.searchParams.get('limit') ?? 200), eventName: url.searchParams.get('eventName') })
        );
      }
      if (method === 'GET' && url.pathname === '/admin/analytics/dashboard') return send(res, 200, app.analytics.dashboard());
      if (method === 'POST' && url.pathname === '/analytics/metrics') return send(res, 200, app.analytics.incMetric((await parseBody(req)).name));

      return send(res, 404, { error: 'NOT_FOUND' });
    } catch (error) {
      if (typeof error?.status === 'number') {
        return send(res, error.status, { error: error.code ?? 'HTTP_ERROR', details: error.details ?? null });
      }
      return send(res, 400, { error: error.message ?? 'BAD_REQUEST' });
    } finally {
      const durationMs = Date.now() - startedAt;
      app.state.requestLogs.push({
        id: `req_${Date.now()}`,
        method: req.method,
        path: req.url,
        durationMs,
        ts: new Date().toISOString()
      });
      if (logLevel === 'debug') {
        // eslint-disable-next-line no-console
        console.debug(`[api] ${req.method} ${req.url} ${durationMs}ms`);
      }
    }
  };
};

export const createHttpServer = (deps = {}) => http.createServer(createHttpHandler(deps));
