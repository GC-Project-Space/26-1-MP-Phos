export const SESSION_MODES = ['LIVE_BOOTH'] as const;
export const SESSION_STATUSES = ['active', 'rendered', 'finalized', 'deleted'] as const;
export const DELETION_STATUSES = [
  'active',
  'export_requested',
  'delete_requested',
  'deleted',
] as const;

export type SessionMode = (typeof SESSION_MODES)[number];
export type SessionStatus = (typeof SESSION_STATUSES)[number];
export type DeletionStatus = (typeof DELETION_STATUSES)[number];

export interface SessionEditState {
  filterPreset: string | null;
  textOverlay: string | null;
  cropToFrame: boolean;
}

export interface SessionSummary {
  sessionId: string;
  mode: SessionMode;
  status: SessionStatus;
  selectedFrameId: string;
  selectedShotAssetIds: string[];
  editState: SessionEditState;
  mediaPreset: string;
  retentionExpiresAt: string;
  trainingUsed: boolean;
  consentVersion: string | null;
  deletionStatus: DeletionStatus;
  createdAt: string;
  updatedAt: string;
}

export interface CreateSessionRequest {
  mode: SessionMode;
}

export interface UpdateSessionRequest {
  selectedFrameId?: string;
  selectedShotAssetIds?: string[];
  mediaPreset?: string;
  editState?: SessionEditState;
}

export const DEFAULT_EDIT_STATE: SessionEditState = {
  filterPreset: null,
  textOverlay: null,
  cropToFrame: false,
};
