import http from 'node:http';
import { SUPPORTED_GAMES } from './index.mjs';

const port = Number(process.env.RULES_ENGINE_PORT ?? process.env.PORT ?? 3003);
const host = process.env.HOST ?? '0.0.0.0';

const send = (res, status, payload) => {
  res.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(payload));
};

const server = http.createServer((req, res) => {
  const url = new URL(req.url ?? '/', 'http://localhost');

  if (req.method === 'GET' && url.pathname === '/health') return send(res, 200, { ok: true, service: 'rules-engine' });
  if (req.method === 'GET' && url.pathname === '/games') return send(res, 200, { games: SUPPORTED_GAMES });

  return send(res, 404, { error: 'NOT_FOUND' });
});

server.listen(port, host, () => {
  // eslint-disable-next-line no-console
  console.log(`[rules-engine] listening on http://${host}:${port}`);
});
