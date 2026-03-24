import type { PropsWithChildren } from 'react';
import { createContext, useContext } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';

export interface AppRuntime {
  readonly appDisplayName: string;
  readonly offlineBannerEnabled: boolean;
}

interface AppProvidersProps extends PropsWithChildren {
  runtime?: AppRuntime;
}

const DEFAULT_APP_RUNTIME: AppRuntime = {
  appDisplayName: 'Phos MVP',
  offlineBannerEnabled: true,
};

const AppRuntimeContext = createContext<AppRuntime | undefined>(undefined);

export function AppProviders({ children, runtime = DEFAULT_APP_RUNTIME }: AppProvidersProps) {
  return (
    <SafeAreaProvider>
      <AppRuntimeContext.Provider value={runtime}>{children}</AppRuntimeContext.Provider>
    </SafeAreaProvider>
  );
}

export function useAppRuntime(): AppRuntime {
  const runtime = useContext(AppRuntimeContext);

  if (!runtime) {
    throw new Error('useAppRuntime must be used within AppProviders');
  }

  return runtime;
}
