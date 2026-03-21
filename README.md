# Phos Monorepo

Phos는 재미 중심의 모바일 인생네컷 포토부스 제품을 만들기 위한 모노레포입니다.

## 제품 요약

- **제품 정의**: 촬영, 간단 편집, 저장, 공유까지 한 흐름에서 끝내는 모바일 포토부스 앱입니다.
- **MVP 핵심 모드**: `Live Booth` 중심으로, 최종 사진과 메이킹 영상을 함께 결과물로 제공합니다.
- **목표 경험**: 가입 없이 시작하고, 약 2분 안에 결과물을 자기 기기에 확보할 수 있어야 합니다.
- **차별점**: 사진 + 메이킹 영상 동시 제공, QR 기반 다운로드, 빠른 완주 경험, privacy-first 기본값.
- **프라이버시 원칙**: 익명 `sessionId` 기반 사용, `trainingOptIn=false` 기본값, 48시간 보관, 즉시 삭제/내보내기 지원.

## 제품 목표

- 첫 세션 완주율: `>= 70%`
- 공유 전환율: `>= 35%`
- 다운로드 성공률: `>= 97%`
- 세션 실패율: `< 3%`
- North Star: `2-Minute Keepsake Secured Rate`

## MVP 사용자 흐름

```text
앱 진입
  -> 프레임 선택
  -> Live Booth 촬영 시작
  -> 카운트다운 기반 연속 촬영
  -> 촬영 중 메이킹 영상 동시 기록
  -> 컷 선택 / 재배치 / 간단 편집
  -> 최종 사진 렌더링
  -> QR 페이지에서 사진/영상 다운로드
  -> 필요 시 로컬 저장 / 삭제 요청 / 내보내기 요청
```

## 빠른 시작

```bash
corepack enable
pnpm install
# 터미널 1
pnpm docker:up

# 터미널 2
pnpm dev:mobile
```

`corepack`이 없는 환경에서는 `npx pnpm@10.32.1 install` 같은 형태로 동일 버전의 pnpm을 직접 호출할 수 있습니다.

- `pnpm docker:up`: 백엔드 로컬 스택(`postgres` + `api`)을 포그라운드로 실행
- `pnpm dev:mobile`: 별도 터미널에서 Expo 모바일 앱 개발 서버 실행

## 개발 환경 기준

- **Node.js**: `22.13+` 또는 `24.x LTS` 권장 (`Prisma 7`, `ESLint 10`, Expo SDK 55 호환 기준)
- **pnpm**: `10.32.1+` (`corepack` 사용 권장)
- **Docker Desktop**: 로컬 Postgres/API 스택 실행 시 필요

## 기술 스택

- **모노레포**: `pnpm` workspaces + `turbo`
- **프론트엔드**: `apps/mobile` - Expo SDK 55, React Native 0.83, React 19, TypeScript, FSD-inspired 구조
- **백엔드**: `apps/api` - NestJS 11, TypeScript, 멀티모듈 MVC 구조
- **데이터베이스**: `packages/db` - Prisma 7 + PostgreSQL
- **타입 검증**: 모바일은 `Valibot`, 백엔드는 `Typia`
- **공유 패키지**: `packages/shared` 는 DTO/상수, `packages/backend-contracts` 는 Typia validator

## 의존성 업데이트 메모

- Expo 관리 패키지(`react`, `react-native`, `react-native-safe-area-context`)는 레지스트리 최신값보다 `Expo SDK 55`가 요구하는 호환 버전을 우선합니다.
- Prisma 7부터 연결 URL은 `packages/db/prisma.config.ts`에서 관리하며, `packages/db/prisma/schema.prisma`의 datasource 블록에는 provider만 유지합니다.
- 모바일 의존성 정합성 확인은 `pnpm --dir apps/mobile run doctor`로 수행합니다.

## 문서 안내

- **[기술 아키텍처](docs/architecture/ARCHITECTURE-Phos.md)**: 현재 모노레포 구조, 기술 스택, 검증 전략
- **[제품 문서 인덱스](docs/product/README.md)**: 제품 문서 읽는 순서와 각 문서 역할 안내
- **[PRD](docs/product/PRD-Phos.md)**: MVP 목표, 핵심 기능, 범위
- **[API 명세](docs/product/API-SPEC-Phos.md)**: 세션 중심 API 계약
- **[유저 스토리](docs/product/USER-STORIES-Phos.md)**: 구현 단위 사용자 요구사항
- **[Discovery Plan](docs/discovery/phos-discovery-plan.md)**: 초기 검증 질문과 실험 계획
- **[Metrics Dashboard](docs/discovery/phos-metrics-dashboard.md)**: North Star 및 핵심 운영 지표

## 워크스페이스 구조

```text
apps/
  api/                # NestJS backend
  mobile/             # Expo React Native frontend
packages/
  backend-contracts/  # Typia-powered backend validators
  db/                 # Prisma schema and client
  shared/             # Shared DTOs and constants
docs/
  architecture/       # Technical architecture docs
  discovery/          # Product discovery and research
  product/            # Product requirements and specs
```

## 주요 명령어

| 명령어                | 설명                             |
| --------------------- | -------------------------------- |
| `pnpm install`        | 전체 의존성 설치                 |
| `pnpm dev`            | 모바일 + API 동시 개발 모드 실행 |
| `pnpm dev:mobile`     | 모바일 앱만 실행                 |
| `pnpm dev:api`        | API만 실행                       |
| `pnpm docker:up`      | 로컬 Postgres + API Docker 실행  |
| `pnpm docker:down`    | 로컬 Docker 서비스 종료          |
| `pnpm db:generate`    | Prisma Client 생성               |
| `pnpm db:migrate:dev` | Prisma 개발 마이그레이션 실행    |
| `pnpm typecheck`      | 워크스페이스 전체 타입 점검      |
| `pnpm lint`           | ESLint 실행                      |
| `pnpm test`           | 전체 테스트 실행                 |
| `pnpm test:e2e`       | API e2e 테스트 실행              |
| `pnpm clean`          | 산출물과 설치 파일 정리          |
