import { Controller, Get } from '@nestjs/common';

import { FRAME_CATALOG } from '../../contracts/frame';

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
