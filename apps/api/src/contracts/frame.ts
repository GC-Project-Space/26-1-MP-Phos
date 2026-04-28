export const FRAME_LAYOUTS = ['4_cut', '6_cut'] as const;

export type FrameLayout = (typeof FRAME_LAYOUTS)[number];

export interface FrameSummary {
  frameId: string;
  layoutType: FrameLayout;
  title: string;
  slotCount: number;
  isActive: boolean;
}

export const FRAME_CATALOG: FrameSummary[] = [
  {
    frameId: 'frm_4cut_basic',
    layoutType: '4_cut',
    title: 'Basic 4 Cut',
    slotCount: 4,
    isActive: true,
  },
  {
    frameId: 'frm_6cut_party',
    layoutType: '6_cut',
    title: 'Party 6 Cut',
    slotCount: 6,
    isActive: true,
  },
];
