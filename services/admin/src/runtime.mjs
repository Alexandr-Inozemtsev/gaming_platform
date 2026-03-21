import http from 'node:http';
import { createAdminPanel } from './panel.mjs';

const port = Number(process.env.ADMIN_PORT ?? process.env.PORT ?? 3002);
const host = process.env.HOST ?? '0.0.0.0';

const reports = [];
const cases = [];
const bans = [];
const mutes = [];
const audit = [];
const events = [];
const campaigns = [];

const panel = createAdminPanel({
  adminPassword: process.env.ADMIN_PASSWORD ?? 'local_admin_password',
  moderationApi: {
    listReports: () => reports,
    listCases: () => cases,
    getCaseById: ({ caseId }) => cases.find((item) => item.id === caseId) ?? null,
    updateCaseStatus: ({ caseId, status }) => {
      const item = cases.find((entry) => entry.id === caseId);
      if (!item) return null;
      item.status = status;
      item.updatedAt = new Date().toISOString();
      return item;
    },
    ban: ({ userId, reason, duration = '24h' }) => bans.push({ userId, reason, duration, ts: new Date().toISOString() }),
    mute: ({ userId, reason, duration = '1h' }) => mutes.push({ userId, reason, duration, ts: new Date().toISOString() }),
    unban: ({ userId, reason = 'manual_review' }) => ({ ok: true, userId, reason }),
    auditLog: () => audit
  },
  analyticsApi: {
    list: ({ limit = 100 } = {}) => events.slice(-limit),
    dashboard: () => ({ matches7d: 0, dauProxy: [] })
  },
  campaignsApi: {
    list: () => campaigns,
    create: ({ name, description = '', levels = [] }) => {
      const row = { id: `campaign_${Date.now()}`, name, description, levels, ts: new Date().toISOString() };
      campaigns.push(row);
      return row;
    }
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
  if (req.method === 'GET' && url.pathname === '/cases') return send(res, 200, panel.moderationQueue());
  if (req.method === 'GET' && url.pathname === '/audit') return send(res, 200, panel.auditLog());
  if (req.method === 'GET' && url.pathname === '/campaigns') return send(res, 200, panel.campaignsTable());
  if (req.method === 'POST' && url.pathname === '/campaigns') return send(res, 201, panel.createCampaign(await parseBody(req)));
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
