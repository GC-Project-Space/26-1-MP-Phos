import { fireEvent, screen } from '@testing-library/react-native';
import { describe, beforeEach, expect, it, jest } from '@jest/globals';

import { BoothHomeScreen } from './BoothHomeScreen';
import { useConnectivityState } from '../../../hooks/useConnectivityState';
import { renderWithProviders } from '../../../test-utils/render';

jest.mock('../../../hooks/useConnectivityState', () => ({
  useConnectivityState: jest.fn(),
}));

describe('BoothHomeScreen offline integration', () => {
  const useConnectivityStateMock = jest.mocked(useConnectivityState);

  beforeEach(() => {
    useConnectivityStateMock.mockReset();
  });

  it('shows offline banner in offline state and triggers retry callback', () => {
    const retry = jest.fn(async () => ({
      connectionType: null,
      isConnected: false,
      isInternetReachable: false,
      status: 'offline' as const,
    }));

    useConnectivityStateMock.mockReturnValue({
      connectivityState: {
        connectionType: null,
        isConnected: false,
        isInternetReachable: false,
        status: 'offline',
      },
      refresh: retry,
    });

    renderWithProviders(<BoothHomeScreen />);

    expect(
      screen.getByText('인터넷 연결이 없습니다. 일부 부스 기능을 사용할 수 없어요.'),
    ).toBeTruthy();

    fireEvent.press(screen.getByRole('button', { name: '재시도' }));

    expect(retry).toHaveBeenCalledTimes(1);
  });

  it('keeps existing hero and widgets visible in online state without offline banner', () => {
    const onlineRefresh = jest.fn(async () => ({
      connectionType: null,
      isConnected: true,
      isInternetReachable: true,
      status: 'online' as const,
    }));

    useConnectivityStateMock.mockReturnValue({
      connectivityState: {
        connectionType: null,
        isConnected: true,
        isInternetReachable: true,
        status: 'online',
      },
      refresh: onlineRefresh,
    });

    renderWithProviders(<BoothHomeScreen />);

    expect(screen.getByText('Phos MVP')).toBeTruthy();
    expect(screen.getByText('프레임 프리셋')).toBeTruthy();
    expect(screen.getByText('세션 계약')).toBeTruthy();
    expect(
      screen.queryByText('인터넷 연결이 없습니다. 일부 부스 기능을 사용할 수 없어요.'),
    ).toBeNull();
  });
});
