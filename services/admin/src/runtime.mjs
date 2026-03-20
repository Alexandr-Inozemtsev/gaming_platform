import http from 'node:http';
import { createAdminPanel } from './panel.mjs';

const port = Number(process.env.ADMIN_PORT ?? process.env.PORT ?? 3002);
const host = process.env.HOST ?? '0.0.0.0';

const reports = [];
const bans = [];
const mutes = [];
const events = [];

const panel = createAdminPanel({
  adminPassword: process.env.ADMIN_PASSWORD ?? 'local_admin_password',
  moderationApi: {
    listReports: () => reports,
    ban: ({ userId, reason }) => bans.push({ userId, reason, ts: new Date().toISOString() }),
    mute: ({ userId, reason }) => mutes.push({ userId, reason, ts: new Date().toISOString() })
  },
  analyticsApi: {
    list: ({ limit = 100 } = {}) => events.slice(-limit),
    dashboard: () => ({ matches7d: 0, dauProxy: [] })
  }
});

const send = (res, status, payload) => {
  res.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(payload));
};

const parseBody = async (req) => {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  const raw = Buffer.concat(chunks).toString('utf8');
  return raw ? JSON.parse(raw) : {};
};

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url ?? '/', 'http://localhost');

  if (req.method === 'GET' && url.pathname === '/health') return send(res, 200, { ok: true, service: 'admin' });
  if (req.method === 'GET' && url.pathname === '/reports') return send(res, 200, panel.reportsTable());
  if (req.method === 'POST' && url.pathname === '/login') {
    try {
      return send(res, 200, panel.login(await parseBody(req)));
    } catch {
      return send(res, 401, { error: 'INVALID_ADMIN_CREDENTIALS' });
    }
  }

  return send(res, 404, { error: 'NOT_FOUND' });
});

server.listen(port, host, () => {
  // eslint-disable-next-line no-console
  console.log(`[admin] listening on http://${host}:${port}`);
});
