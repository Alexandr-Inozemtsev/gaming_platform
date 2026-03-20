import { createHttpServer } from './server.mjs';

const port = Number(process.env.API_PORT ?? process.env.PORT ?? 3000);
const host = process.env.HOST ?? '0.0.0.0';

const server = createHttpServer();
server.listen(port, host, () => {
  // eslint-disable-next-line no-console
  console.log(`[api] listening on http://${host}:${port}`);
});
