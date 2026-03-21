import { Module } from '@nestjs/common';

import { FramesModule } from '../frames/frames.module';
import { SessionsController } from './sessions.controller';
import { SessionsService } from './sessions.service';

@Module({
  imports: [FramesModule],
  controllers: [SessionsController],
  providers: [SessionsService],
})
export class SessionsModule {}
