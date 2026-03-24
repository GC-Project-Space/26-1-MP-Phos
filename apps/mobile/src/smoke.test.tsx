import { beforeEach, describe, expect, it, jest } from '@jest/globals';
import {
  createElement as mockCreateElement,
  forwardRef as mockForwardRef,
  type ReactNode,
} from 'react';

import { useConnectivityState } from './hooks/useConnectivityState';
import { runSmokeFlow, SmokeStageError } from './smoke/harness';

interface PrimitiveProps {
  readonly children?: ReactNode;
  readonly [key: string]: unknown;
}

const smokeGlobal = globalThis as typeof globalThis & {
  IS_REACT_ACT_ENVIRONMENT?: boolean;
};

smokeGlobal.IS_REACT_ACT_ENVIRONMENT = true;

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
    ScrollView: createPrimitive('ScrollView'),
    StyleSheet: { create: (styles: Record<string, unknown>) => styles },
    Text: createPrimitive('Text'),
    View: createPrimitive('View'),
  };
});

jest.mock('expo-status-bar', () => ({
  StatusBar: () => null,
}));

jest.mock('react-native-safe-area-context', () => {
  return {
    SafeAreaView: ({ children }: { children: ReactNode }) => {
      return mockCreateElement('SafeAreaView', null, children);
    },
  };
});

jest.mock('./hooks/useConnectivityState', () => ({
  useConnectivityState: jest.fn(),
}));

describe('mobile smoke flow', () => {
  beforeEach(() => {
    jest.mocked(useConnectivityState).mockReset();
  });

  it('[T1] reproduces the launch to booth to offline to recover flow', () => {
    const result = runSmokeFlow();

    expect(result.logs.map((entry) => entry.stage)).toEqual([
      'launch',
      'booth',
      'offline',
      'recover',
    ]);
    expect(result.logs.every((entry) => entry.outcome === 'passed')).toBe(true);
  });

  it('[T2] detects the offline stage deterministically and exposes retry', () => {
    const result = runSmokeFlow();
    const offlineStage = result.logs.find((entry) => entry.stage === 'offline');

    expect(offlineStage?.detail).toContain('offline banner');
    expect(result.refresh).toHaveBeenCalledTimes(1);
  });

  it('[T3] returns to the normal booth widgets after recover stage', () => {
    const result = runSmokeFlow();
    const recoverStage = result.logs.find((entry) => entry.stage === 'recover');

    expect(recoverStage?.detail).toContain('removes offline fallback');
  });

  it('[T4] reports the failing stage when a failure fixture is injected', () => {
    try {
      runSmokeFlow({ failStage: 'recover' });
      throw new Error('Expected smoke harness to fail at recover stage');
    } catch (error) {
      if (!(error instanceof SmokeStageError)) {
        throw error;
      }

      expect(error.stage).toBe('recover');
      expect(error.message).toContain('Smoke stage failed [recover]');
      expect(error.logs[error.logs.length - 1]).toEqual({
        detail: 'forced fixture failure',
        outcome: 'failed',
        stage: 'recover',
      });
    }
  });
});
