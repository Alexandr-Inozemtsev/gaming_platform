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

  return async (req, res) => {
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

      if (method === 'POST' && url.pathname === '/store/purchase-sandbox') return send(res, 200, app.store.purchaseSandbox(await parseBody(req)));
      if (method === 'GET' && url.pathname === '/inventory') return send(res, 200, app.users.inventory({ userId: url.searchParams.get('userId') }));

      if (method === 'POST' && url.pathname === '/reports') return send(res, 201, app.moderation.report(await parseBody(req)));
      if (method === 'POST' && url.pathname === '/admin/ban') return send(res, 200, app.moderation.ban(await parseBody(req)));
      if (method === 'POST' && url.pathname === '/admin/mute') return send(res, 200, app.moderation.mute(await parseBody(req)));

      return send(res, 404, { error: 'NOT_FOUND' });
    } catch (error) {
      if (typeof error?.status === 'number') {
        return send(res, error.status, { error: error.code ?? 'HTTP_ERROR', details: error.details ?? null });
      }
      return send(res, 400, { error: error.message ?? 'BAD_REQUEST' });
    }
  };
};

export const createHttpServer = (deps = {}) => http.createServer(createHttpHandler(deps));
