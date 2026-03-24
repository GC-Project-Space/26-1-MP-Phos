import { beforeEach, describe, expect, it, jest } from '@jest/globals';
import {
  createElement as mockCreateElement,
  forwardRef as mockForwardRef,
  type ReactElement,
  type ReactNode,
} from 'react';
import { act, create, type ReactTestRenderer } from 'react-test-renderer';

import { BoothHomeScreen } from './BoothHomeScreen';
import { useConnectivityState } from '../../../hooks/useConnectivityState';

interface PrimitiveProps {
  readonly children?: ReactNode;
  readonly [key: string]: unknown;
}

function hasOnPress(props: unknown): props is { onPress: () => void } {
  return (
    typeof props === 'object' &&
    props !== null &&
    'onPress' in props &&
    typeof (props as { onPress?: unknown }).onPress === 'function'
  );
}

const boothHomeTestGlobal = globalThis as typeof globalThis & {
  IS_REACT_ACT_ENVIRONMENT?: boolean;
};

boothHomeTestGlobal.IS_REACT_ACT_ENVIRONMENT = true;

jest.mock('react-native', () => {
  const createPrimitive = (displayName: string) => {
    const Primitive = mockForwardRef<unknown, PrimitiveProps>((props, ref) => {
      return mockCreateElement(displayName, { ...props, ref });
    });

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

function render(ui: ReactElement): ReactTestRenderer {
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
    const retry = jest.fn(() =>
      Promise.resolve({
        connectionType: null,
        isConnected: false,
        isInternetReachable: false,
        status: 'offline' as const,
      }),
    );

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
    const retryButtonProps: unknown = retryButton.props;

    if (!hasOnPress(retryButtonProps)) {
      throw new Error('Expected retry button to expose onPress');
    }

    act(() => {
      retryButtonProps.onPress();
    });

    expect(retry).toHaveBeenCalledTimes(1);
  });

  it('keeps existing hero and widgets visible in online state without offline banner', () => {
    const onlineRefresh = jest.fn(() =>
      Promise.resolve({
        connectionType: null,
        isConnected: true,
        isInternetReachable: true,
        status: 'online' as const,
      }),
    );

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
