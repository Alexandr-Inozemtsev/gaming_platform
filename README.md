# TabletopPlatform Monorepo

MVP monorepo for a digital tabletop platform.

## Scope
- **App name:** `TabletopPlatform`
- **Region mode:** `global` (switchable to `ru_by`)
- **Languages:** `ru`, `en`
- **MVP games:** `tile_placement_demo`, `roll_and_write_demo`

## Repository layout
- `apps/mobile` — Flutter client skeleton
- `services/api` — NestJS-ready API stub (TypeScript package)
- `services/realtime` — realtime gateway stub (TypeScript package)
- `services/rules-engine` — shared rules engine TypeScript library
- `services/admin` — minimal admin backend stub (TypeScript package)
- `infra` — local infrastructure (`docker compose`, env templates)
- `docs` — architecture docs, ADRs, release checklist

## Prerequisites
- Node.js 20+
- npm 10+
- Docker + Docker Compose
- Flutter SDK (for mobile development)

## Quick start
```bash
npm install
npm run lint
npm run format:check
npm test
```

### Infra only (databases/cache)
```bash
cd infra
docker compose up -d
```

This starts:
- PostgreSQL (`localhost:5432`)
- Redis (`localhost:6379`)

### Flutter setup
```bash
cd apps/mobile
flutter doctor
flutter pub get
flutter run
```

If `Inter` font is unavailable locally, fallback to system font.

## Monorepo tooling
- TypeScript quality gate: **ESLint + Prettier** (root config)
- Workspace management: **npm workspaces**
- `melos`: **not specified** for this MVP baseline

## Scripts
From repository root:
- `npm run lint` — lint all services
- `npm run format` — format all tracked files
- `npm run format:check` — check formatting
- `npm test` — run unit tests for all service stubs
