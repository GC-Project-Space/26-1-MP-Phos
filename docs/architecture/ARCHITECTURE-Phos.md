# Phos 기술 아키텍처

이 문서는 Phos 모노레포의 기술 아키텍처를 설명합니다.

## 개요

Phos는 `pnpm` + `Turbo` 모노레포로 구성한 모바일 포토부스 제품입니다. Expo 기반 React Native 모바일 애플리케이션과 NestJS API로 이루어져 있으며, 내부 패키지를 통해 로직과 계약을 공유합니다.

## 워크스페이스 구조

```text
.
├── apps/
│   ├── api/                # NestJS 11 백엔드
│   └── mobile/             # Expo React Native 프론트엔드
├── packages/
│   ├── backend-contracts/  # Typia 기반 백엔드 검증기
│   ├── db/                 # Prisma 스키마와 생성된 클라이언트
│   └── shared/             # 중립 DTO와 상수
├── docs/
│   ├── architecture/       # 기술 아키텍처 문서 (이 폴더)
│   ├── discovery/          # 제품 디스커버리와 리서치
│   └── product/            # 제품 요구사항과 명세
└── docker-compose.yml      # 로컬 백엔드 스택 (Postgres + API)
```

## 기술 스택

### 프론트엔드 (`apps/mobile`)

- **프레임워크**: Expo SDK 56 canary (React Native 0.84.1 / React 19.2.3)
- **언어**: TypeScript
- **아키텍처**: FSD-inspired (Feature-Sliced Design)
  - `src/app`: 전역 provider, 스타일, 진입점
  - `src/pages`: 화면 컴포넌트와 페이지 수준 로직
  - `src/widgets`: 독립적인 UI 블록 (예: `ExperienceOverview`)
  - `src/shared`: 재사용 UI 컴포넌트, 설정, 계약
- **검증**: 런타임 스키마 검증에 [Valibot](https://valibot.io/) 사용

### 백엔드 (`apps/api`)

- **프레임워크**: NestJS 11
- **언어**: TypeScript
- **아키텍처**: 멀티모듈 MVC 성격 구조
  - `src/modules`: 도메인별 모듈(Frames, Sessions, Health)과 `PrismaModule`을 통한 인프라 연결
  - `src/common`: 공통 유틸리티와 HTTP 헬퍼
- **검증**: 고성능 AOT 검증에 [Typia](https://typia.io/) 사용
- **데이터베이스**: Prisma 7 기반 PostgreSQL

### 공유 패키지 (`packages/*`)

- `@phos/shared`: 모바일과 API가 함께 사용하는 순수 TypeScript 인터페이스(DTO)와 상수를 담습니다.
- `@phos/backend-contracts`: `@phos/shared`를 Typia decorator/function으로 감싸 백엔드 전용 검증을 제공합니다.
- `@phos/db`: 중앙 Prisma 스키마, `prisma.config.ts`, 생성된 클라이언트를 제공합니다.

### 백엔드 모듈 맵

- `HealthModule`: 경량 서비스 헬스 엔드포인트
- `FramesModule`: 모바일과 API 소비자를 위한 프레임 카탈로그 제공
- `SessionsModule`: 세션 생명주기와 계약 검증 기반 세션 흐름 담당
- `PrismaModule`: `@phos/db`의 Prisma 클라이언트를 백엔드 서비스에 노출하는 전역 Nest 모듈

## 검증 전략

Phos는 개발 경험과 성능을 함께 최적화하기 위해 "Validation Split" 전략을 사용합니다.

1. **모바일**: 가볍고 tree-shakable한 클라이언트 검증을 위해 Valibot을 사용합니다.
2. **백엔드**: TypeScript 타입 시스템을 컴파일 타임에 활용하는 초고속 타입 안전 검증을 위해 Typia를 사용합니다.
3. **계약**: `packages/shared`의 공유 DTO가 데이터 구조의 단일 진실 소스입니다.

## 로컬 개발

### 사전 준비

- Node.js (`22.13+` 또는 `24.x LTS` 권장)
- pnpm (`10.32.1+`, Corepack 사용 권장)
- Docker Desktop (로컬 데이터베이스와 API 실행용)

### 주요 명령어

- `corepack enable`: 레포가 `packageManager`에 고정된 pnpm 버전을 사용하도록 보장합니다.
- `pnpm install`: 전체 의존성을 설치합니다.
- `pnpm dev`: 모바일과 API를 모두 개발 모드로 실행합니다.
- `pnpm dev:mobile`: 모바일 앱만 실행합니다.
- `pnpm dev:api`: API만 실행합니다.
- `pnpm docker:up`: 로컬 Postgres와 API 컨테이너를 실행합니다.
- `pnpm docker:down`: 로컬 Postgres와 API 컨테이너를 중지합니다.
- `pnpm db:generate`: Prisma 클라이언트를 생성합니다.
- `pnpm typecheck`: 워크스페이스 전체에서 TypeScript 컴파일러 검사를 실행합니다.
- `pnpm lint`: ESLint를 실행합니다.
- `pnpm test`: Turbo를 통해 전체 테스트를 실행합니다.
- `pnpm --dir apps/mobile run doctor`: Expo SDK 패키지 정합성을 검증합니다.

로컬 환경에서 `corepack`을 사용할 수 없다면, 버전 민감한 명령은 `npx pnpm@10.32.1 <command>` 형태로 대체할 수 있습니다.

### 권장 로컬 작업 흐름

1. 레포 루트에서 `corepack enable` 후 `pnpm install`을 한 번 실행합니다.
2. PostgreSQL이 포함된 백엔드 스택이 필요할 때 `pnpm docker:up`을 실행합니다.
3. Expo 앱을 로컬에서 반복 개발할 때 `pnpm dev:mobile`을 실행합니다.
4. Nest 앱을 Docker 밖에서 의도적으로 실행할 때만 `pnpm dev:api`를 사용합니다.

### 의존성 메모

- Expo 관리 패키지는 설치된 Expo SDK가 요구하는 버전에 맞춰 유지해야 합니다. 모바일 의존성을 올릴 때는 `pnpm --dir apps/mobile exec expo install --fix`를 사용합니다.
- 현재 모바일 워크스페이스는 다음 메이저를 안정판 전에 검증하기 위해 Expo SDK 56 canary 계열을 사용합니다. Expo 56 안정판이 배포되면 canary 고정 버전을 대응하는 안정 `56.x` 버전으로 바꿔야 합니다.
- `apps/mobile/app.json`의 루트 `splash` 필드는 Expo 56 canary 스키마 검증에서 거부되어 제거했습니다. splash 설정을 복원하기 전에는 안정판 스키마를 다시 확인해야 합니다.
- Prisma 7은 `packages/db/prisma.config.ts`에서 연결 설정을 읽고, `packages/db/prisma/schema.prisma`에는 datasource provider만 유지합니다.

## 문서 맵

- **제품 요구사항**: `docs/product/PRD-Phos.md` 참고
- **사용자 스토리**: `docs/product/USER-STORIES-Phos.md` 참고
- **API 명세**: `docs/product/API-SPEC-Phos.md` 참고
- **디스커버리 계획**: `docs/discovery/phos-discovery-plan.md` 참고
- **지표 대시보드**: `docs/discovery/phos-metrics-dashboard.md` 참고
