import { StatusBar } from 'expo-status-bar';
import { ScrollView, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { BoothHomeScreen } from '../pages/booth-home';
import { AppProviders } from './providers/AppProviders';
import { palette } from '../shared/config/theme';

export default function App() {
  return (
    <AppProviders>
      <SafeAreaView style={styles.safeArea}>
        <StatusBar style="dark" />
        <ScrollView contentContainerStyle={styles.content}>
          <BoothHomeScreen />
        </ScrollView>
      </SafeAreaView>
    </AppProviders>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: palette.background,
  },
  content: {
    flexGrow: 1,
  },
});
