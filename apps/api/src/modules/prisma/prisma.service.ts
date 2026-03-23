import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@phos/db';

const DEFAULT_DATABASE_URL = 'postgresql://phos:phos@localhost:5432/phos?schema=phos_dev';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleDestroy {
  public constructor() {
    super({
      adapter: new PrismaPg({
        connectionString: process.env['DATABASE_URL'] ?? DEFAULT_DATABASE_URL,
      }),
    });
  }

  public async onModuleDestroy() {
    await this.$disconnect();
  }
}
