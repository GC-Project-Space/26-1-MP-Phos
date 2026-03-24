export const validSessionSummaryFixture = {
  sessionId: 'ses_preview',
  mode: 'LIVE_BOOTH',
  status: 'active',
  selectedFrameId: 'frm_4cut_basic',
  selectedShotAssetIds: [],
  editState: {
    filterPreset: null,
    textOverlay: null,
    cropToFrame: false,
  },
  mediaPreset: 'default',
  retentionExpiresAt: '2026-03-23T00:00:00.000Z',
  trainingUsed: false,
  consentVersion: null,
  deletionStatus: 'active',
  createdAt: '2026-03-21T00:00:00.000Z',
  updatedAt: '2026-03-21T00:00:00.000Z',
} as const;

export const invalidSessionSummaryFixture = {
  ...validSessionSummaryFixture,
  status: 'unknown-state',
  editState: {
    ...validSessionSummaryFixture.editState,
    cropToFrame: 'yes',
  },
  selectedShotAssetIds: ['shot_1', 42],
} as const;
