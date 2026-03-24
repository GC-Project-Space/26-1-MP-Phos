import { Pressable, StyleSheet, Text, View } from 'react-native';

import { palette } from '../config/theme';

export interface OfflineBannerProps {
  isOffline: boolean;
  message?: string;
  onRetry?: () => void;
}

export function OfflineBanner({
  isOffline,
  message = '인터넷 연결이 없습니다. 일부 부스 기능을 사용할 수 없어요.',
  onRetry,
}: OfflineBannerProps) {
  if (!isOffline) {
    return null;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.message}>{message}</Text>
      {onRetry ? (
        <Pressable accessibilityRole="button" onPress={onRetry} style={styles.retryButton}>
          <Text style={styles.retryText}>재시도</Text>
        </Pressable>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    backgroundColor: '#fde8d6',
    borderColor: palette.accent,
    borderRadius: 16,
    borderWidth: 1,
    flexDirection: 'row',
    gap: 12,
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  message: {
    color: palette.textPrimary,
    flex: 1,
    fontSize: 13,
    fontWeight: '600',
    lineHeight: 18,
  },
  retryButton: {
    backgroundColor: palette.accent,
    borderRadius: 12,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  retryText: {
    color: palette.surface,
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 0.4,
    textTransform: 'uppercase',
  },
});
