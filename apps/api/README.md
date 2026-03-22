# Phos API 문서

`apps/api`는 Phos 모노레포의 NestJS 11 기반 백엔드 앱입니다. 세션, 프레임, 헬스 체크 모듈과 `@phos/db` Prisma client를 사용합니다.

## 환경 기준

- Node.js: `22.13+` 또는 `24.x LTS` 권장
- pnpm: 루트 `package.json`의 `packageManager` 기준(`10.32.1`)
- 데이터베이스: PostgreSQL (`DATABASE_URL` 필요)

## 시작하기

레포 루트에서 의존성을 설치합니다.

```bash
corepack enable
pnpm install
```

`corepack`이 없는 환경에서는 `npx pnpm@10.32.1 install`을 사용해도 됩니다.

필요한 환경 변수를 준비합니다.

```bash
cp apps/api/.env.example apps/api/.env
cp packages/db/.env.example packages/db/.env
```

로컬 DB/API 스택을 Docker로 올리거나, API만 단독 실행할 수 있습니다.

```bash
# 레포 루트
pnpm docker:up

# 별도 터미널에서 API만 감시 모드로 실행
pnpm dev:api
```

## 주요 명령어

```bash
# 레포 루트
pnpm dev:api
pnpm --filter api build
pnpm --filter api test
pnpm --filter api test:e2e
pnpm db:generate
pnpm db:migrate:dev
```

## Prisma 메모

- Prisma 7부터 DB 연결 설정은 `packages/db/prisma.config.ts`에서 읽습니다.
- `packages/db/prisma/schema.prisma`의 datasource 블록에는 provider만 유지합니다.
- Prisma client 재생성은 루트에서 `pnpm db:generate`로 실행합니다.

## 참고 문서

- 루트 가이드: [`../../README.md`](../../README.md)
- 아키텍처 문서: [`../../docs/architecture/ARCHITECTURE-Phos.md`](../../docs/architecture/ARCHITECTURE-Phos.md)
- API 명세: [`../../docs/product/API-SPEC-Phos.md`](../../docs/product/API-SPEC-Phos.md)
