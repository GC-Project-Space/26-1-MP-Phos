import { DELETION_STATUSES, SESSION_MODES, SESSION_STATUSES } from '@phos/shared';
import * as v from 'valibot';

const sessionEditStateSchema = v.object({
  filterPreset: v.nullable(v.string()),
  textOverlay: v.nullable(v.string()),
  cropToFrame: v.boolean(),
});

export const sessionSummarySchema = v.object({
  sessionId: v.string(),
  mode: v.picklist(SESSION_MODES),
  status: v.picklist(SESSION_STATUSES),
  selectedFrameId: v.string(),
  selectedShotAssetIds: v.array(v.string()),
  editState: sessionEditStateSchema,
  mediaPreset: v.string(),
  retentionExpiresAt: v.string(),
  trainingUsed: v.boolean(),
  consentVersion: v.nullable(v.string()),
  deletionStatus: v.picklist(DELETION_STATUSES),
  createdAt: v.string(),
  updatedAt: v.string(),
});

export function validateSessionSummary(input: unknown) {
  return v.safeParse(sessionSummarySchema, input);
}
