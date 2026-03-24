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
        <Text style={styles.title}>Capture the booth flow before feature work starts.</Text>
        <Text style={styles.description}>
          The mobile app is structured with FSD layers and already shares the frame/session
          contracts that the Nest API exposes.
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
