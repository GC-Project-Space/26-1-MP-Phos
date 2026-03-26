import { describe, beforeEach, expect, it, jest } from '@jest/globals';
import { act, renderHook } from '@testing-library/react-native';

import { useConnectivityState } from './useConnectivityState';

const hookTestGlobal = globalThis as typeof globalThis & {
  IS_REACT_ACT_ENVIRONMENT?: boolean;
};

hookTestGlobal.IS_REACT_ACT_ENVIRONMENT = true;

type NetInfoListener = (state: {
  type: 'unknown' | 'none' | 'wifi' | 'cellular';
  isConnected: boolean | null;
  isInternetReachable: boolean | null;
}) => void;

jest.mock('@react-native-community/netinfo', () => ({
  NetInfoStateType: {
    cellular: 'cellular',
    none: 'none',
    unknown: 'unknown',
    wifi: 'wifi',
  },
  __esModule: true,
  default: {
    addEventListener: jest.fn(),
    fetch: jest.fn(),
  },
}));

const mockNetInfoModule: {
  NetInfoStateType: {
    cellular: 'cellular';
    none: 'none';
    unknown: 'unknown';
    wifi: 'wifi';
  };
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
} = jest.requireMock('@react-native-community/netinfo');

const mockNetInfo = mockNetInfoModule.default;

describe('useConnectivityState', () => {
  beforeEach(() => {
    mockNetInfo.addEventListener.mockReset();
    mockNetInfo.fetch.mockReset();
    mockNetInfo.fetch.mockResolvedValue({
      type: 'unknown',
      isConnected: null,
      isInternetReachable: null,
    });
  });

  it('starts with unknown state and updates from offline to online events', () => {
    const unsubscribe = jest.fn();

    mockNetInfo.addEventListener.mockImplementation(() => unsubscribe);

    const { result, unmount } = renderHook(() => useConnectivityState());

    expect(result.current.connectivityState.status).toBe('unknown');

    const registeredListener = mockNetInfo.addEventListener.mock.calls[0]?.[0] as
      | NetInfoListener
      | undefined;

    if (!registeredListener) {
      throw new Error('Expected event listener to be registered');
    }

    act(() => {
      registeredListener({
        type: 'none',
        isConnected: false,
        isInternetReachable: false,
      });
    });

    expect(result.current.connectivityState.status).toBe('offline');

    act(() => {
      registeredListener({
        type: 'wifi',
        isConnected: true,
        isInternetReachable: true,
      });
    });

    expect(result.current.connectivityState.status).toBe('online');

    unmount();

    expect(unsubscribe).toHaveBeenCalledTimes(1);
  });

  it('exposes refresh that re-fetches and returns latest state', async () => {
    mockNetInfo.addEventListener.mockReturnValue(jest.fn());
    mockNetInfo.fetch.mockResolvedValue({
      type: 'wifi',
      isConnected: true,
      isInternetReachable: true,
    });

    const { result } = renderHook(() => useConnectivityState());

    await act(async () => {
      const refreshed = await result.current.refresh();
      expect(refreshed.status).toBe('online');
    });

    expect(mockNetInfo.fetch).toHaveBeenCalled();
    expect(result.current.connectivityState.status).toBe('online');
  });
});
