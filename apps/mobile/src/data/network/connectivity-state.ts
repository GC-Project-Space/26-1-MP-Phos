import NetInfo, { type NetInfoState, type NetInfoStateType } from '@react-native-community/netinfo';

export type ConnectivityStatus = 'unknown' | 'offline' | 'online';

export interface ConnectivityState {
  readonly status: ConnectivityStatus;
  readonly connectionType: NetInfoStateType | null;
  readonly isConnected: boolean | null;
  readonly isInternetReachable: boolean | null;
}

export type ConnectivityStateListener = (state: ConnectivityState) => void;

export interface ConnectivityStateHolder {
  getState(): ConnectivityState;
  refresh(): Promise<ConnectivityState>;
  subscribe(listener: ConnectivityStateListener): () => void;
  dispose(): void;
}

export const DEFAULT_CONNECTIVITY_STATE: ConnectivityState = {
  status: 'unknown',
  connectionType: null,
  isConnected: null,
  isInternetReachable: null,
};

const areStatesEqual = (left: ConnectivityState, right: ConnectivityState): boolean => {
  return (
    left.status === right.status &&
    left.connectionType === right.connectionType &&
    left.isConnected === right.isConnected &&
    left.isInternetReachable === right.isInternetReachable
  );
};

const normalizeConnectivityState = (state: NetInfoState): ConnectivityState => {
  const normalizedState: ConnectivityState = {
    connectionType: state.type,
    isConnected: state.isConnected,
    isInternetReachable: state.isInternetReachable,
    status: 'unknown',
  };

  if (state.type === 'unknown' || state.isConnected === null) {
    return normalizedState;
  }

  if (state.isConnected === false || state.type === 'none' || state.isInternetReachable === false) {
    return {
      ...normalizedState,
      status: 'offline',
    };
  }

  if (state.isConnected === true && state.isInternetReachable === true) {
    return {
      ...normalizedState,
      status: 'online',
    };
  }

  return normalizedState;
};

export const createConnectivityStateHolder = (): ConnectivityStateHolder => {
  let currentState: ConnectivityState = DEFAULT_CONNECTIVITY_STATE;
  let isDisposed = false;
  let bootstrapStarted = false;
  let sourceVersion = 0;
  let latestAppliedVersion = 0;
  let unsubscribeNetInfo: (() => void) | null = null;
  const listeners = new Set<ConnectivityStateListener>();

  const notifyIfChanged = (nextState: ConnectivityState): ConnectivityState => {
    if (isDisposed) {
      return currentState;
    }

    if (areStatesEqual(currentState, nextState)) {
      return currentState;
    }

    currentState = nextState;

    listeners.forEach((listener) => {
      listener(currentState);
    });

    return currentState;
  };

  const applyNetInfoState = (state: NetInfoState, version: number): ConnectivityState => {
    if (version < latestAppliedVersion) {
      return currentState;
    }

    latestAppliedVersion = version;
    const normalizedState = normalizeConnectivityState(state);
    return notifyIfChanged(normalizedState);
  };

  const applyFallbackState = (version: number): ConnectivityState => {
    if (version < latestAppliedVersion) {
      return currentState;
    }

    latestAppliedVersion = version;
    return notifyIfChanged(DEFAULT_CONNECTIVITY_STATE);
  };

  const ensureObservationStarted = (): void => {
    if (isDisposed) {
      return;
    }

    if (!unsubscribeNetInfo) {
      unsubscribeNetInfo = NetInfo.addEventListener((state) => {
        sourceVersion += 1;
        applyNetInfoState(state, sourceVersion);
      });
    }

    if (bootstrapStarted) {
      return;
    }

    bootstrapStarted = true;
    sourceVersion += 1;
    const bootstrapVersion = sourceVersion;

    void NetInfo.fetch()
      .then((state) => {
        applyNetInfoState(state, bootstrapVersion);
      })
      .catch(() => {
        applyFallbackState(bootstrapVersion);
      });
  };

  return {
    getState(): ConnectivityState {
      return currentState;
    },
    async refresh(): Promise<ConnectivityState> {
      ensureObservationStarted();
      sourceVersion += 1;
      const refreshVersion = sourceVersion;

      try {
        const state = await NetInfo.fetch();
        return applyNetInfoState(state, refreshVersion);
      } catch {
        return applyFallbackState(refreshVersion);
      }
    },
    subscribe(listener: ConnectivityStateListener): () => void {
      ensureObservationStarted();
      listeners.add(listener);
      listener(currentState);

      return () => {
        listeners.delete(listener);
      };
    },
    dispose(): void {
      isDisposed = true;
      unsubscribeNetInfo?.();
      unsubscribeNetInfo = null;
      listeners.clear();
    },
  };
};
