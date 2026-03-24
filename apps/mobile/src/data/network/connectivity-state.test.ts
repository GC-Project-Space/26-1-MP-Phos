import { beforeEach, describe, expect, it, jest } from '@jest/globals';

import {
  createConnectivityStateHolder,
  DEFAULT_CONNECTIVITY_STATE,
  type ConnectivityState,
} from './connectivity-state';

type NetInfoListener = (state: {
  type: 'unknown' | 'none' | 'wifi' | 'cellular';
  isConnected: boolean | null;
  isInternetReachable: boolean | null;
}) => void;

jest.mock('@react-native-community/netinfo', () => ({
  __esModule: true,
  default: {
    addEventListener: jest.fn(),
    fetch: jest.fn(),
  },
}));

const mockNetInfoModule = jest.requireMock('@react-native-community/netinfo') as {
  default: {
    addEventListener: jest.MockedFunction<(listener: NetInfoListener) => () => void>;
    fetch: jest.MockedFunction<
      () => Promise<{
        type: 'unknown' | 'none' | 'wifi' | 'cellular';
        isConnected: boolean | null;
        isInternetReachable: boolean | null;
      }>
    >;
  };
};

const mockNetInfo = mockNetInfoModule.default;

describe('connectivity-state holder', () => {
  beforeEach(() => {
    mockNetInfo.addEventListener.mockReset();
    mockNetInfo.fetch.mockReset();
    mockNetInfo.addEventListener.mockReturnValue(jest.fn());
    mockNetInfo.fetch.mockResolvedValue({
      type: 'unknown',
      isConnected: null,
      isInternetReachable: null,
    });
  });

  it('keeps initial state as unknown and does not misclassify offline', () => {
    const holder = createConnectivityStateHolder();
    const observedStates: ConnectivityState[] = [];

    const unsubscribe = holder.subscribe((state) => {
      observedStates.push(state);
    });

    expect(observedStates[0]).toEqual(DEFAULT_CONNECTIVITY_STATE);

    unsubscribe();
    holder.dispose();
  });

  it('transitions offline and then online from NetInfo events', () => {
    mockNetInfo.addEventListener.mockImplementation((nextListener) => {
      return () => {
        void nextListener;
      };
    });

    const holder = createConnectivityStateHolder();
    const observedStatuses: string[] = [];

    holder.subscribe((state) => {
      observedStatuses.push(state.status);
    });

    const registeredListener = mockNetInfo.addEventListener.mock.calls[0]?.[0] as
      | NetInfoListener
      | undefined;

    if (!registeredListener) {
      throw new Error('Expected NetInfo listener to be registered');
    }

    registeredListener({
      type: 'none',
      isConnected: false,
      isInternetReachable: false,
    });
    registeredListener({
      type: 'wifi',
      isConnected: true,
      isInternetReachable: true,
    });

    expect(observedStatuses).toContain('offline');
    expect(observedStatuses).toContain('online');

    holder.dispose();
  });

  it('refresh fetches latest state and returns online when reachable', async () => {
    mockNetInfo.fetch.mockResolvedValue({
      type: 'wifi',
      isConnected: true,
      isInternetReachable: true,
    });

    const holder = createConnectivityStateHolder();
    const refreshed = await holder.refresh();

    expect(mockNetInfo.fetch).toHaveBeenCalled();
    expect(refreshed.status).toBe('online');

    holder.dispose();
  });
});
