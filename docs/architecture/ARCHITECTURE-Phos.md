# Phos Technical Architecture

This document describes the technical architecture of the Phos monorepo.

## Overview

Phos is a mobile photo-booth product built as a pnpm + Turbo monorepo. It consists of an Expo-managed React Native mobile application and a NestJS API, sharing logic and contracts through internal packages.

## Workspace Structure

```text
.
├── apps/
│   ├── api/                # NestJS 11 backend
│   └── mobile/             # Expo React Native frontend
├── packages/
│   ├── backend-contracts/  # Typia-powered backend validators
│   ├── db/                 # Prisma schema and generated client
│   └── shared/             # Neutral DTOs and constants
├── docs/
│   ├── architecture/       # Technical architecture docs (this folder)
│   ├── discovery/          # Product discovery and research
│   └── product/            # Product requirements and specifications
└── docker-compose.yml      # Local backend stack (Postgres + API)
```

## Tech Stack

### Frontend (`apps/mobile`)

- **Framework**: Expo SDK 56 canary (React Native 0.84.1 / React 19.2.3)
- **Language**: TypeScript
- **Architecture**: FSD-inspired (Feature-Sliced Design)
  - `src/app`: Global providers, styles, and entry point.
  - `src/pages`: Screen components and page-level logic.
  - `src/widgets`: Self-contained UI blocks (e.g., `ExperienceOverview`).
  - `src/shared`: Reusable UI components, config, and contracts.
- **Validation**: [Valibot](https://valibot.io/) for runtime schema validation.

### Backend (`apps/api`)

- **Framework**: NestJS 11
- **Language**: TypeScript
- **Architecture**: Multi-module MVC-ish
  - `src/modules`: Domain-specific modules (Frames, Sessions, Health) plus infrastructure wiring through `PrismaModule`.
  - `src/common`: Shared utilities and HTTP helpers.
- **Validation**: [Typia](https://typia.io/) for high-performance AOT validation.
- **Database**: PostgreSQL via Prisma 7.

### Shared Packages (`packages/*`)

- `@phos/shared`: Contains plain TypeScript interfaces (DTOs) and constants used by both mobile and API.
- `@phos/backend-contracts`: Wraps `@phos/shared` with Typia decorators/functions for backend-specific validation.
- `@phos/db`: Centralized Prisma schema, `prisma.config.ts`, and generated client.

### Backend Module Map

- `HealthModule`: Lightweight service health endpoint.
- `FramesModule`: Frame catalog delivery for mobile and API consumers.
- `SessionsModule`: Session lifecycle and contract-validated session flows.
- `PrismaModule`: Global Nest module that exposes the Prisma client from `@phos/db` to backend services.

## Validation Strategy

Phos uses a "Validation Split" to optimize for both developer experience and performance:

1. **Mobile**: Uses Valibot for lightweight, tree-shakable client-side validation.
2. **Backend**: Uses Typia for ultra-fast, type-safe validation that leverages TypeScript's type system at compile-time.
3. **Contracts**: Shared DTOs in `packages/shared` define the source of truth for data shapes.

## Local Development

### Prerequisites

- Node.js (`22.13+` or `24.x LTS` recommended)
- pnpm (`10.32.1+` via Corepack recommended)
- Docker Desktop (for local database and API)

### Key Commands

- `corepack enable`: Ensure the repo uses the pinned pnpm version from `packageManager`.
- `pnpm install`: Install all dependencies.
- `pnpm dev`: Start both mobile and API in development mode.
- `pnpm dev:mobile`: Start only the mobile app.
- `pnpm dev:api`: Start only the API.
- `pnpm docker:up`: Spin up the local Postgres and API containers.
- `pnpm docker:down`: Stop the local Postgres and API containers.
- `pnpm db:generate`: Generate the Prisma client.
- `pnpm typecheck`: Run TypeScript compiler checks across the workspace.
- `pnpm lint`: Run ESLint.
- `pnpm test`: Run all tests via Turbo.
- `pnpm --dir apps/mobile run doctor`: Validate Expo SDK package alignment.

If `corepack` is unavailable on your machine, use `npx pnpm@10.32.1 <command>` as a fallback for version-sensitive commands.

### Recommended Local Flow

1. Run `corepack enable` and then `pnpm install` once at the repo root.
2. Run `pnpm docker:up` when you need the backend stack with PostgreSQL.
3. Run `pnpm dev:mobile` when iterating on the Expo app locally.
4. Use `pnpm dev:api` only when you intentionally want the Nest app outside Docker.

### Dependency Notes

- Expo-managed packages should stay on the versions required by the installed Expo SDK. Use `pnpm --dir apps/mobile exec expo install --fix` when upgrading mobile dependencies.
- The mobile workspace is currently on the Expo SDK 56 canary line to validate the next major before the stable release. Once Expo 56 stable ships, replace the canary pins with the corresponding stable `56.x` versions.
- The root `splash` field was removed from `apps/mobile/app.json` because Expo 56 canary schema validation rejected it. Re-check the stable schema before restoring any splash configuration.
- Prisma 7 reads connection configuration from `packages/db/prisma.config.ts`; `packages/db/prisma/schema.prisma` keeps the datasource provider only.

## Documentation Map

- **Product Requirements**: See `docs/product/PRD-Phos.md`.
- **User Stories**: See `docs/product/USER-STORIES-Phos.md`.
- **API Specification**: See `docs/product/API-SPEC-Phos.md`.
- **Discovery Plan**: See `docs/discovery/phos-discovery-plan.md`.
- **Metrics Dashboard**: See `docs/discovery/phos-metrics-dashboard.md`.
