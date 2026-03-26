# Phos 모노레포

Phos는 재미 중심의 모바일 인생네컷 포토부스 제품을 만들기 위한 모노레포입니다.

## 제품 요약

- **제품 정의**: 촬영, 간단 편집, 저장까지 한 흐름에서 끝내는 모바일 포토부스 앱입니다.
- **MVP 핵심 모드**: `Live Booth` 중심으로, 최종 포토 스트립과 메이킹 영상을 함께 결과물로 제공합니다.
- **목표 경험**: 가입 없이 시작하고, 약 2분 안에 결과물을 자기 기기에 확보할 수 있어야 합니다.
- **차별점**: 사진 + 메이킹 영상 동시 제공, 앱 내 결과 저장 중심의 빠른 완주 경험, 프라이버시 우선 기본값.
- **프라이버시 원칙**: 익명 `sessionId` 기반 사용, `trainingOptIn=false` 기본값, 48시간 보관, 즉시 삭제/내보내기 지원.

## 제품 목표

- 첫 세션 완주율: `>= 70%`
- 결과물 확보 전환율: `>= 80%`
- 다운로드 성공률: `>= 97%`
- 세션 실패율: `< 3%`
- 노스스타 지표: `2-Minute Keepsake Secured Rate`

## MVP 사용자 흐름

```text
앱 진입
  -> 프레임 선택
  -> Live Booth 촬영 시작
  -> 카운트다운 기반 연속 촬영
  -> 촬영 중 메이킹 영상 동시 기록
  -> 컷 선택 / 재배치 / 간단 편집
  -> 최종 포토 스트립 렌더링
  -> 앱 내 결과 화면에서 사진/영상 확인
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

- **Node.js**: `25.x` (Docker API 런타임 `node:25-alpine` 기준, 로컬 실행은 `>=22`)
- **pnpm**: `10.32.1` (`corepack` 사용 권장)
- **Docker Desktop**: 로컬 `postgres:18-alpine` + API 스택 실행 시 필요
- **Android 로컬 빌드 (macOS)**: `pnpm mobile:android:run`은 `JAVA_HOME`이 없을 때 macOS 기본 JDK 탐지(`/usr/libexec/java_home`)를 먼저 시도하고, 실패하면 Android Studio 번들 JBR를 자동으로 사용합니다.

## 기술 스택

- **모노레포**: `pnpm@10.32.1` workspaces + `turbo@2.8.20`
- **프론트엔드**: `apps/mobile` - `expo@56.0.0-canary-20260305-5163746`, `react-native@0.84.1`, `react@19.2.3`, TypeScript, FSD-inspired 구조
- **백엔드**: `apps/api` - `@nestjs/common@11.1.17`, TypeScript, 멀티모듈 MVC 구조
- **데이터베이스**: `packages/db` - `@prisma/client@7.5.0` + 로컬 컨테이너 `postgres:18-alpine`
- **타입 검증**: 모바일은 `valibot@1.3.1`, 백엔드는 `typia@12.0.1`
- **공유 패키지**: `packages/shared`는 DTO/상수, `packages/backend-contracts`는 Typia 검증기

## 의존성 업데이트 메모

- Expo 관리 패키지(`expo-status-bar`, `react`, `react-dom`, `react-native`, `react-native-safe-area-context`)는 레지스트리 최신값보다 현재 설치된 Expo SDK가 요구하는 호환 버전을 우선합니다.
- 현재 모바일 앱은 다음 메이저 선행 검증을 위해 `expo@56.0.0-canary-20260305-5163746`를 사용합니다. Expo 56 안정판 출시 후에는 canary 태그를 정식 `56.x` 버전으로 치환하는 후속 정리가 필요합니다.
- `apps/mobile/app.json`의 루트 `splash` 설정은 Expo 56 canary 스키마 검증에 맞춰 제거된 상태입니다. 안정판 전환 시 스키마 허용 여부를 다시 확인한 뒤 복원 여부를 판단해야 합니다.
- Prisma CLI 연결 URL은 `packages/db/prisma.config.ts`에서 관리하며, `packages/db/prisma/schema/` 아래 datasource 블록에는 provider만 유지합니다.
- API 런타임은 `DATABASE_URL`을 직접 읽고, 값이 없으면 로컬 기본 스키마 `phos_dev`를 사용합니다.
- 모바일 의존성 정합성 확인은 `pnpm --dir apps/mobile run doctor`로 수행합니다.

## 문서 안내

- **[기술 아키텍처](docs/architecture/ARCHITECTURE-Phos.md)**: 현재 모노레포 구조, 기술 스택, 검증 전략
- **[ERD](docs/architecture/ERD-Phos.md)**: `packages/db/prisma/schema/` 도메인 스키마에서 `prisma-markdown`으로 생성한 데이터 모델 문서
- **[제품 문서 인덱스](docs/product/README.md)**: 제품 문서 읽는 순서와 각 문서 역할 안내
- **[PRD](docs/product/PRD-Phos.md)**: MVP 목표, 핵심 기능, 범위
- **[API 명세](docs/product/API-SPEC-Phos.md)**: 세션 중심 API 계약
- **[사용자 스토리](docs/product/USER-STORIES-Phos.md)**: 구현 단위 사용자 요구사항
- **[테스트 시나리오](docs/product/TEST-SCENARIOS-Phos.md)**: MVP QA 및 데이터 직교성 검증 시나리오
- **[디스커버리 계획](docs/discovery/phos-discovery-plan.md)**: 초기 검증 질문과 실험 계획
- **[지표 대시보드](docs/discovery/phos-metrics-dashboard.md)**: 노스스타 및 핵심 운영 지표

## 워크스페이스 구조

```text
apps/
  api/                # NestJS 백엔드
  mobile/             # Expo React Native 프론트엔드
packages/
  backend-contracts/  # Typia 기반 백엔드 검증기
  db/                 # Prisma 스키마와 클라이언트
  shared/             # 공유 DTO와 상수
docs/
  architecture/       # 기술 아키텍처 문서
  discovery/          # 제품 디스커버리와 리서치
  product/            # 제품 요구사항과 명세
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
| `pnpm db:generate`    | Prisma 클라이언트 생성           |
| `pnpm db:erd`         | Prisma 기반 ERD Markdown 생성    |
| `pnpm db:migrate:dev` | Prisma 개발 마이그레이션 실행    |
| `pnpm typecheck`      | 워크스페이스 전체 타입 점검      |
| `pnpm lint`           | ESLint 실행                      |
| `pnpm test`           | 전체 테스트 실행                 |
| `pnpm test:e2e`       | API e2e 테스트 실행              |
| `pnpm clean`          | 산출물과 설치 파일 정리          |

## 모바일 테스트 메모

- `pnpm --filter mobile test`는 React Native Testing Library 기반으로 mobile primitive/provider/data/screen 계층을 검증합니다.
- 대표 범위는 `shared/ui`, `app/providers`, `shared/contracts`, `pages/booth-home`, `app/App` 테스트입니다.
- negative fixture는 `apps/mobile/src/__fixtures__/sessionSummary.ts`에서 관리합니다.
