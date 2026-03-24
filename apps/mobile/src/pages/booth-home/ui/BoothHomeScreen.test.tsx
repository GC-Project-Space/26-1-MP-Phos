import { beforeEach, describe, expect, it, jest } from '@jest/globals';
import React from 'react';
import { act, create, type ReactTestRenderer } from 'react-test-renderer';

import { BoothHomeScreen } from './BoothHomeScreen';
import { useConnectivityState } from '../../../hooks/useConnectivityState';

jest.mock('react-native', () => {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const ReactInstance = require('react');

  const createPrimitive = (displayName: string) => {
    const Primitive = ReactInstance.forwardRef((props: Record<string, unknown>, ref: unknown) =>
      ReactInstance.createElement(displayName, { ...props, ref }, props.children),
    );

    Primitive.displayName = displayName;
    return Primitive;
  };

  return {
    Pressable: createPrimitive('Pressable'),
    StyleSheet: { create: (styles: Record<string, unknown>) => styles },
    Text: createPrimitive('Text'),
    View: createPrimitive('View'),
  };
});

jest.mock('../../../hooks/useConnectivityState', () => ({
  useConnectivityState: jest.fn(),
}));

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

    const renderer = render(<BoothHomeScreen />);

    expect(
      renderer.root.findByProps({
        children: '인터넷 연결이 없습니다. 일부 부스 기능을 사용할 수 없어요.',
      }),
    ).toBeDefined();

    const retryButton = renderer.root.findByProps({ accessibilityRole: 'button' });

    act(() => {
      retryButton.props.onPress();
    });

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

    const renderer = render(<BoothHomeScreen />);

    expect(renderer.root.findByProps({ children: 'Phos MVP' })).toBeDefined();
    expect(renderer.root.findByProps({ children: '프레임 프리셋' })).toBeDefined();
    expect(renderer.root.findByProps({ children: '세션 계약' })).toBeDefined();

    expect(() => {
      renderer.root.findByProps({
        children: '인터넷 연결이 없습니다. 일부 부스 기능을 사용할 수 없어요.',
      });
    }).toThrow();
  });
});
