import { FRAME_CATALOG } from '@phos/shared';
import { Injectable } from '@nestjs/common';

@Injectable()
export class FramesService {
  public listFrames() {
    return FRAME_CATALOG;
  }

  public getDefaultFrameId() {
    return FRAME_CATALOG[0].frameId;
  }
}
