# AGENTS.md

## Setup
1. Use Node.js 20+ and npm 10+.
2. Install dependencies from repo root: `npm install`.
3. Optional mobile setup: install Flutter SDK and run `flutter doctor`.
4. Start local infra only: `docker compose up -d` in `infra/`.

## Code style
- TypeScript: ESLint + Prettier from root config.
- Keep services as small, independently runnable packages.
- Prefer explicit exported types for public APIs.
- Do not wrap imports in try/catch.

## Commit rules
- Use Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`...).
- Keep commit scope focused (one feature/area per commit when possible).
- Update docs when behavior or setup changes.

## Minimum testing
- For TS services, add at least one unit test per package.
- Before commit, run:
  - `npm run lint`
  - `npm run format:check`
  - `npm test`
