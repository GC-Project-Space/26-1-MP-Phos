import { Injectable } from '@nestjs/common';

import { FRAME_CATALOG } from '../../contracts/frame';

@Injectable()
export class FramesService {
  public listFrames() {
    return FRAME_CATALOG;
  }

  public getDefaultFrameId() {
    return FRAME_CATALOG[0].frameId;
  }
}
