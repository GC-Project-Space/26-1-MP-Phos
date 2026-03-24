import type { FrameSummary } from '@phos/shared';
import { StyleSheet, Text, View } from 'react-native';

import { InfoCard } from '../../../shared/ui/InfoCard';
import { palette } from '../../../shared/config/theme';

interface ExperienceOverviewProps {
  frames: FrameSummary[];
}

export function ExperienceOverview({ frames }: ExperienceOverviewProps) {
  return (
    <InfoCard title="프레임 프리셋" subtitle="@phos/shared의 공통 계약 데이터">
      <View style={styles.list}>
        {frames.map((frame) => (
          <View key={frame.frameId} style={styles.item}>
            <View>
              <Text style={styles.itemTitle}>{frame.title}</Text>
              <Text style={styles.itemMeta}>
                {frame.layoutType} · {frame.slotCount}컷
              </Text>
            </View>
            <Text style={styles.itemState}>{frame.isActive ? '사용 가능' : '일시 중지'}</Text>
          </View>
        ))}
      </View>
    </InfoCard>
  );
}

const styles = StyleSheet.create({
  list: {
    gap: 12,
  },
  item: {
    alignItems: 'center',
    backgroundColor: palette.surfaceMuted,
    borderRadius: 18,
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 14,
    paddingVertical: 12,
  },
  itemTitle: {
    color: palette.textPrimary,
    fontSize: 16,
    fontWeight: '700',
  },
  itemMeta: {
    color: palette.textSecondary,
    fontSize: 13,
    marginTop: 4,
  },
  itemState: {
    color: palette.accent,
    fontSize: 13,
    fontWeight: '700',
  },
});
