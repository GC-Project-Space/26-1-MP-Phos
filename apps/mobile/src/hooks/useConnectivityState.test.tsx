import { beforeEach, describe, expect, it, jest } from '@jest/globals';
import React from 'react';
import { act, create, type ReactTestRenderer } from 'react-test-renderer';

import { useConnectivityState } from './useConnectivityState';
import type { ConnectivityState } from '../data/network/connectivity-state';

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

interface HookProbeProps {
  onState: (state: ConnectivityState) => void;
  onRefresh: (refresh: () => Promise<ConnectivityState>) => void;
}

function HookProbe({ onRefresh, onState }: HookProbeProps) {
  const { connectivityState, refresh } = useConnectivityState();

  onState(connectivityState);
  onRefresh(refresh);

  return null;
}

function render(ui: React.ReactElement): ReactTestRenderer {
  let renderer: ReactTestRenderer | null = null;

  act(() => {
    renderer = create(ui);
  });

  if (!renderer) {
    throw new Error('Expected test renderer to be created');
  }

  return renderer;
}

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
    mockNetInfo.addEventListener.mockImplementation((listener) => {
      return jest.fn();
    });

    const snapshots: ConnectivityState[] = [];

    render(<HookProbe onState={(state) => snapshots.push(state)} onRefresh={jest.fn()} />);

    expect(snapshots[0].status).toBe('unknown');

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

    act(() => {
      registeredListener({
        type: 'wifi',
        isConnected: true,
        isInternetReachable: true,
      });
    });

    const statuses = snapshots.map((state) => state.status);
    expect(statuses).toContain('offline');
    expect(statuses).toContain('online');
  });

  it('exposes refresh that re-fetches and returns latest state', async () => {
    mockNetInfo.addEventListener.mockReturnValue(jest.fn());
    mockNetInfo.fetch.mockResolvedValue({
      type: 'wifi',
      isConnected: true,
      isInternetReachable: true,
    });

    let refreshCallback: (() => Promise<ConnectivityState>) | undefined;

    render(
      <HookProbe
        onState={jest.fn()}
        onRefresh={(refreshFn) => {
          refreshCallback = refreshFn;
        }}
      />,
    );

    const capturedRefresh = refreshCallback;

    if (!capturedRefresh) {
      throw new Error('Expected refresh callback to be captured');
    }

    const refreshed = await capturedRefresh();

    expect(mockNetInfo.fetch).toHaveBeenCalled();
    expect(refreshed.status).toBe('online');
  });
});
