import { useCallback, useEffect, useMemo, useSyncExternalStore } from 'react';

import {
  createConnectivityStateHolder,
  type ConnectivityState,
  type ConnectivityStateHolder,
} from '../data/network/connectivity-state';

interface UseConnectivityStateResult {
  connectivityState: ConnectivityState;
  refresh: () => Promise<ConnectivityState>;
}

export function useConnectivityState(): UseConnectivityStateResult {
  const connectivityStateHolder = useMemo<ConnectivityStateHolder>(() => {
    return createConnectivityStateHolder();
  }, []);

  const subscribe = useCallback(
    (onStoreChange: () => void) => {
      return connectivityStateHolder.subscribe(() => {
        onStoreChange();
      });
    },
    [connectivityStateHolder],
  );

  const getSnapshot = useCallback(() => {
    return connectivityStateHolder.getState();
  }, [connectivityStateHolder]);

  const connectivityState = useSyncExternalStore(subscribe, getSnapshot, getSnapshot);

  useEffect(() => {
    return () => {
      connectivityStateHolder.dispose();
    };
  }, [connectivityStateHolder]);

  const refresh = useCallback(() => {
    return connectivityStateHolder.refresh();
  }, [connectivityStateHolder]);

  return {
    connectivityState,
    refresh,
  };
}
