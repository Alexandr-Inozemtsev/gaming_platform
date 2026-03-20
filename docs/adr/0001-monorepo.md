# ADR-0001: Use monorepo for MVP platform

## Status
Accepted

## Context
MVP contains multiple services and one client app with shared domain concepts.

## Decision
Use a single repository with npm workspaces for TypeScript services and a Flutter app folder.

## Consequences
- Easier coordinated changes across API/realtime/rules.
- Shared quality gate (lint/format/test) from repo root.
- Need clear boundaries between services.
