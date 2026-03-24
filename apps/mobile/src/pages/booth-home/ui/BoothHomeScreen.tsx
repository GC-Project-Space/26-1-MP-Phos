import { FRAME_CATALOG } from '@phos/shared';
import { StyleSheet, Text, View } from 'react-native';

import { useConnectivityState } from '../../../hooks/useConnectivityState';
import { ExperienceOverview } from '../../../widgets/experience-overview/ui/ExperienceOverview';
import { SessionReadiness } from '../../../widgets/session-readiness/ui/SessionReadiness';
import { palette } from '../../../shared/config/theme';
import { OfflineBanner } from '../../../shared/ui/OfflineBanner';

export function BoothHomeScreen() {
  const { connectivityState, refresh } = useConnectivityState();
  const isOffline = connectivityState.status === 'offline';

  return (
    <View style={styles.screen}>
      <OfflineBanner isOffline={isOffline} onRetry={refresh} />

      <View style={styles.hero}>
        <Text style={styles.kicker}>Phos MVP</Text>
        <Text style={styles.title}>기능 개발 전에 포토부스 흐름을 먼저 점검하세요.</Text>
        <Text style={styles.description}>
          모바일 앱은 FSD 레이어 구조로 구성되어 있고, Nest API가 제공하는 프레임/세션 계약을 이미
          공유합니다.
        </Text>
      </View>

      <ExperienceOverview frames={FRAME_CATALOG} />
      <SessionReadiness />
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    gap: 16,
    paddingHorizontal: 20,
    paddingVertical: 24,
  },
  hero: {
    backgroundColor: palette.surface,
    borderColor: palette.border,
    borderRadius: 24,
    borderWidth: 1,
    gap: 10,
    padding: 20,
  },
  kicker: {
    color: palette.accent,
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 1.2,
    textTransform: 'uppercase',
  },
  title: {
    color: palette.textPrimary,
    fontSize: 28,
    fontWeight: '800',
    lineHeight: 34,
  },
  description: {
    color: palette.textSecondary,
    fontSize: 15,
    lineHeight: 22,
  },
});
