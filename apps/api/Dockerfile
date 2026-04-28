FROM node:25-alpine AS base

RUN npm install --global pnpm@10.32.1

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json tsconfig.base.json .npmrc ./
COPY apps/api/package.json apps/api/package.json

RUN pnpm install --frozen-lockfile

COPY apps/api apps/api

RUN pnpm --filter api db:generate && \
    pnpm --filter api build

EXPOSE 3000

CMD ["pnpm", "--filter", "api", "start:prod"]
