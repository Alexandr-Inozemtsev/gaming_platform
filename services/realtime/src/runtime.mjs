import http from 'node:http';
import { createRealtimeGateway } from './gateway.mjs';
import { createSfuCoordinator } from './sfu.mjs';

const port = Number(process.env.REALTIME_PORT ?? process.env.PORT ?? 3001);
const host = process.env.HOST ?? '0.0.0.0';

const gateway = createRealtimeGateway();
const sfu = createSfuCoordinator();

const send = (res, status, payload) => {
  res.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(payload));
};

const server = http.createServer((req, res) => {
  const url = new URL(req.url ?? '/', 'http://localhost');

  if (req.method === 'GET' && url.pathname === '/health') return send(res, 200, { ok: true, service: 'realtime' });
  if (req.method === 'GET' && url.pathname === '/snapshot') return send(res, 200, gateway.snapshot());
  if (req.method === 'GET' && url.pathname === '/sfu/snapshot') return send(res, 200, { rooms: sfu.snapshot() });

  return send(res, 404, { error: 'NOT_FOUND' });
});

server.listen(port, host, () => {
  // eslint-disable-next-line no-console
  console.log(`[realtime] listening on http://${host}:${port}`);
});
