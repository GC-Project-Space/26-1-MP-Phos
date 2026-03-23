import { config as loadEnv } from 'dotenv';
import { fileURLToPath } from 'node:url';
import { defineConfig } from 'prisma/config';

const DEFAULT_DATABASE_URL = 'postgresql://phos:phos@localhost:5432/phos?schema=phos_dev';

loadEnv({
  path: fileURLToPath(new URL('.env', import.meta.url)),
});

export default defineConfig({
  schema: 'prisma/schema',
  migrations: {
    path: 'prisma/migrations',
  },
  datasource: {
    url: process.env['DATABASE_URL'] ?? DEFAULT_DATABASE_URL,
  },
});
