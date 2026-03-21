import { FramesService } from './frames.service';

describe('FramesService', () => {
  it('returns the seeded frame catalog', () => {
    const service = new FramesService();

    expect(service.listFrames()).toHaveLength(2);
    expect(service.getDefaultFrameId()).toBe('frm_4cut_basic');
  });
});
