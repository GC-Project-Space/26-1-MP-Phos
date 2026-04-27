# Phos 기술 아키텍처

이 문서는 Phos 모노레포의 기술 아키텍처를 설명합니다.

## 개요

Phos는 `pnpm@10.32.1` + `Turbo@2.8.20` 모노레포로 구성한 모바일 포토부스 제품입니다. Flutter 모바일 애플리케이션과 NestJS API로 이루어져 있으며, 내부 패키지를 통해 백엔드 계약과 데이터 모델을 관리합니다.

## 워크스페이스 구조

```text
.
├── apps/
│   ├── api/                # NestJS 11.1.17 백엔드
│   └── mobile/             # Flutter 모바일 앱
├── docs/
│   ├── architecture/       # 기술 아키텍처 문서 (이 폴더)
│   ├── discovery/          # 제품 디스커버리와 리서치
│   └── product/            # 제품 요구사항과 명세
└── docker-compose.yml      # 로컬 백엔드 스택 (Postgres + API)
```

## 기술 스택

### 프론트엔드 (`apps/mobile`)

- **프레임워크**: Flutter
- **언어**: Dart
- **앱 식별자**: Dart package `phos_mobile`, native bundle/application ID `com.phos.mobile`
- **구조**:
  - `lib/main.dart`: Flutter 앱 진입점
  - `lib/screens`: 홈, 프레임 선택, 변환, 결과, 갤러리 화면
  - `lib/core`: 앱 상수와 공통 값
- **검증**: Flutter analyzer와 Flutter test 기반 정적 분석/테스트

### 백엔드 (`apps/api`)

- **프레임워크**: NestJS `11.1.17`
- **언어**: TypeScript
- **아키텍처**: 멀티모듈 MVC 성격 구조
  - `src/modules`: 도메인별 모듈(Frames, Sessions, Health)과 `PrismaModule`을 통한 인프라 연결
  - `src/common`: 공통 유틸리티와 HTTP 헬퍼
- **검증**: 고성능 AOT 검증에 [Typia](https://typia.io/) 사용
- **데이터베이스**: Prisma `7.5.0` 기반 PostgreSQL (로컬 컨테이너 `postgres:18-alpine`)

### 서버 내부 계약과 데이터

- `apps/api/src/contracts`: API가 사용하는 순수 TypeScript 인터페이스(DTO), 상수, Typia 검증기를 담습니다.
- `apps/api/prisma`: 도메인별 Prisma 스키마 디렉터리와 마이그레이션을 제공합니다.
- `apps/api/generated/client`: Prisma generate로 생성되는 서버 내부 Prisma client입니다.
- `docs/architecture/ERD-Phos.md`: `apps/api/prisma/schema/`에서 `prisma-markdown`으로 생성한 ERD/모델 문서입니다.

### 백엔드 모듈 맵

- `HealthModule`: 경량 서비스 헬스 엔드포인트
- `FramesModule`: 모바일과 API 소비자를 위한 프레임 카탈로그 제공
- `SessionsModule`: 세션 생명주기와 계약 검증 기반 세션 흐름 담당
- `PrismaModule`: API 내부 Prisma 클라이언트를 백엔드 서비스에 노출하는 전역 Nest 모듈

## 검증 전략

Phos는 개발 경험과 성능을 함께 최적화하기 위해 "Validation Split" 전략을 사용합니다.

1. **모바일**: Flutter analyzer와 Flutter test로 Dart 코드의 정적 분석과 위젯 테스트를 수행합니다.
2. **백엔드**: TypeScript 타입 시스템을 컴파일 타임에 활용하는 초고속 타입 안전 검증을 위해 Typia를 사용합니다.
3. **계약**: `apps/api/src/contracts`의 DTO가 API 데이터 구조의 단일 진실 소스입니다.

## 로컬 개발

### 사전 준비

- Node.js (`25.x` 권장, Docker API 런타임 `node:25-alpine`; 로컬 실행은 `>=22`)
- pnpm (`10.32.1`, Corepack 사용 권장)
- Flutter SDK (`apps/mobile` 실행/분석/테스트용)
- Docker Desktop (로컬 `postgres:18-alpine` + API 실행용)

### 주요 명령어

- `corepack enable`: 레포가 `packageManager`에 고정된 pnpm 버전을 사용하도록 보장합니다.
- `pnpm install`: 전체 의존성을 설치합니다.
- `pnpm dev`: API 개발 서버를 실행합니다.
- `pnpm dev:mobile`: Flutter 모바일 앱을 실행합니다.
- `pnpm mobile:android`: Flutter 앱을 Android 대상에서 실행합니다.
- `pnpm mobile:ios`: Flutter 앱을 iOS 대상에서 실행합니다.
- `pnpm mobile:web`: Flutter 앱을 Chrome 대상에서 실행합니다.
- `pnpm mobile:analyze`: Flutter 정적 분석을 실행합니다.
- `pnpm mobile:test`: Flutter 테스트를 실행합니다.
- `pnpm dev:api`: API만 실행합니다.
- `pnpm docker:up`: 로컬 Postgres와 API 컨테이너를 실행합니다.
- `pnpm docker:down`: 로컬 Postgres와 API 컨테이너를 중지합니다.
- `pnpm db:generate`: Prisma 클라이언트를 생성합니다.
- `pnpm db:erd`: Prisma 스키마에서 Markdown ERD 문서를 다시 생성합니다.
- `pnpm typecheck`: 워크스페이스 전체에서 TypeScript 컴파일러 검사를 실행합니다.
- `pnpm lint`: ESLint를 실행합니다.
- `pnpm test`: Turbo를 통해 전체 테스트를 실행합니다.
- `cd apps/mobile && flutter pub get`: Flutter 의존성을 설치합니다.

로컬 환경에서 `corepack`을 사용할 수 없다면, 버전 민감한 명령은 `npx pnpm@10.32.1 <command>` 형태로 대체할 수 있습니다.

### 권장 로컬 작업 흐름

1. 레포 루트에서 `corepack enable` 후 `pnpm install`을 한 번 실행합니다.
2. PostgreSQL이 포함된 백엔드 스택이 필요할 때 `pnpm docker:up`을 실행합니다.
3. Flutter 앱을 로컬에서 반복 개발할 때 `pnpm dev:mobile`을 실행합니다.
4. Nest 앱을 Docker 밖에서 의도적으로 실행할 때만 `pnpm dev:api`를 사용합니다.

### 의존성 메모

- 모바일 앱 의존성은 `apps/mobile/pubspec.yaml`과 `apps/mobile/pubspec.lock`에서 관리합니다.
- 모바일 의존성을 변경한 뒤에는 `flutter pub get`, `flutter analyze`, `flutter test`를 실행합니다.
- Prisma는 `apps/api/prisma.config.ts`에서 연결 설정을 읽고, `apps/api/prisma/schema/`에는 datasource provider만 유지합니다.

## 문서 맵

- **제품 요구사항**: `docs/product/PRD-Phos.md` 참고
- **사용자 스토리**: `docs/product/USER-STORIES-Phos.md` 참고
- **API 명세**: `docs/product/API-SPEC-Phos.md` 참고
- **디스커버리 계획**: `docs/discovery/phos-discovery-plan.md` 참고
- **지표 대시보드**: `docs/discovery/phos-metrics-dashboard.md` 참고
