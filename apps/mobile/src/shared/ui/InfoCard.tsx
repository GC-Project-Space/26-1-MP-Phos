import type { PropsWithChildren } from 'react';
import { StyleSheet, Text, View } from 'react-native';

import { palette } from '../config/theme';

interface InfoCardProps extends PropsWithChildren {
  title: string;
  subtitle: string;
}

export function InfoCard({ children, subtitle, title }: InfoCardProps) {
  return (
    <View style={styles.card}>
      <View style={styles.header}>
        <Text style={styles.title}>{title}</Text>
        <Text style={styles.subtitle}>{subtitle}</Text>
      </View>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: palette.surface,
    borderColor: palette.border,
    borderRadius: 24,
    borderWidth: 1,
    gap: 16,
    padding: 18,
  },
  header: {
    gap: 4,
  },
  title: {
    color: palette.textPrimary,
    fontSize: 18,
    fontWeight: '700',
  },
  subtitle: {
    color: palette.textSecondary,
    fontSize: 13,
    lineHeight: 18,
  },
});
