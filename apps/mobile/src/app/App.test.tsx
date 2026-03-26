import { render, screen } from '@testing-library/react-native';
import { describe, expect, it, jest } from '@jest/globals';

import App from './App';
import { BoothHomeScreen } from '../pages/booth-home';
import { useConnectivityState } from '../hooks/useConnectivityState';
import { renderWithProviders } from '../test-utils/render';

jest.mock('../hooks/useConnectivityState', () => ({
  useConnectivityState: jest.fn(),
}));

jest.mock('expo-status-bar', () => ({
  StatusBar: () => null,
}));

describe('App screen integration', () => {
  const useConnectivityStateMock = jest.mocked(useConnectivityState);

  it('renders the booth home screen through app providers', () => {
    useConnectivityStateMock.mockReturnValue({
      connectivityState: {
        connectionType: null,
        isConnected: true,
        isInternetReachable: true,
        status: 'online',
      },
      refresh: jest.fn(async () => ({
        connectionType: null,
        isConnected: true,
        isInternetReachable: true,
        status: 'online' as const,
      })),
    });

    renderWithProviders(<App />);

    expect(screen.getByText('기능 개발 전에 포토부스 흐름을 먼저 점검하세요.')).toBeTruthy();
    expect(screen.getByText('세션 계약')).toBeTruthy();
  });

  it('fails fast when booth screen is rendered without AppProviders', () => {
    useConnectivityStateMock.mockReturnValue({
      connectivityState: {
        connectionType: null,
        isConnected: true,
        isInternetReachable: true,
        status: 'online',
      },
      refresh: jest.fn(async () => ({
        connectionType: null,
        isConnected: true,
        isInternetReachable: true,
        status: 'online' as const,
      })),
    });

    expect(() => render(<BoothHomeScreen />)).toThrow(
      'useAppRuntime must be used within AppProviders',
    );
  });
});
