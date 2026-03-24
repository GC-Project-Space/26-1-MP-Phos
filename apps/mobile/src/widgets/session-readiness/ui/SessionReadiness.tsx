import type { InferOutput } from 'valibot';
import { safeParse } from 'valibot';
import { StyleSheet, Text, View } from 'react-native';

import { sessionSummarySchema } from '../../../shared/contracts/session';
import { InfoCard } from '../../../shared/ui/InfoCard';
import { palette } from '../../../shared/config/theme';

const sessionPreview = {
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
};

type MobileSessionSummary = InferOutput<typeof sessionSummarySchema>;

const validationResult = safeParse(sessionSummarySchema, sessionPreview);
const validatedPreview: MobileSessionSummary | null = validationResult.success
  ? validationResult.output
  : null;

export function SessionReadiness() {
  return (
    <InfoCard title="세션 계약" subtitle="모바일에서 Valibot으로 API 형태 페이로드를 검증합니다">
      <View style={styles.row}>
        <View>
          <Text style={styles.label}>미리보기 페이로드</Text>
          <Text style={styles.value}>{validatedPreview ? '검증 완료' : '검증 실패'}</Text>
        </View>
        <Text style={styles.badge}>{validatedPreview ? '검증 정상' : '검토 필요'}</Text>
      </View>
    </InfoCard>
  );
}

const styles = StyleSheet.create({
  row: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  label: {
    color: palette.textSecondary,
    fontSize: 13,
    marginBottom: 4,
  },
  value: {
    color: palette.textPrimary,
    fontSize: 18,
    fontWeight: '700',
  },
  badge: {
    color: palette.accent,
    fontSize: 13,
    fontWeight: '700',
    textTransform: 'uppercase',
  },
});
