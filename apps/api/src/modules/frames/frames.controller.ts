import { FRAME_CATALOG } from '@phos/shared';
import { Controller, Get } from '@nestjs/common';

import { FramesService } from './frames.service';

@Controller('frames')
export class FramesController {
  public constructor(private readonly framesService: FramesService) {}

  @Get()
  public listFrames() {
    return {
      items: this.framesService.listFrames(),
      total: FRAME_CATALOG.length,
    };
  }
}
