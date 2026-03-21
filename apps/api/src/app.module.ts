import { Module } from '@nestjs/common';
import { FramesModule } from './modules/frames/frames.module';
import { HealthModule } from './modules/health/health.module';
import { PrismaModule } from './modules/prisma/prisma.module';
import { SessionsModule } from './modules/sessions/sessions.module';

@Module({
  imports: [PrismaModule, HealthModule, FramesModule, SessionsModule],
})
export class AppModule {}
