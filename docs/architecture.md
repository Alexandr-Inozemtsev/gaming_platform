# Architecture (MVP)

## Overview
Monorepo contains a Flutter client and TypeScript backend services.

- **Mobile** (`apps/mobile`): user-facing app (RU/EN, region mode global/ru_by).
- **API** (`services/api`): auth/profile/game metadata endpoints.
- **Realtime** (`services/realtime`): websocket gateway for table sessions.
- **Rules Engine** (`services/rules-engine`): deterministic game logic for MVP games.
- **Admin** (`services/admin`): operational endpoints and feature toggles.
- **Infra** (`infra`): local postgres + redis for development.

## MVP game set
- `tile_placement_demo`
- `roll_and_write_demo`

## Non-goals for baseline
- Production Kubernetes manifests
- Full auth implementation
- Full UI feature set
