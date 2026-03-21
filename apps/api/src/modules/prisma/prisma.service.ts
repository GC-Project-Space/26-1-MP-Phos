import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@phos/db';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleDestroy {
  public async onModuleDestroy() {
    await this.$disconnect();
  }
}
