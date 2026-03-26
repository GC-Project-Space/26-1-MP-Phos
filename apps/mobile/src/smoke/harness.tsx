import { expect, jest } from '@jest/globals';
import React from 'react';
import { act, create, type ReactTestRenderer } from 'react-test-renderer';

import App from '../app/App';
import type { ConnectivityState } from '../data/network/connectivity-state';
import { useConnectivityState } from '../hooks/useConnectivityState';
import {
  getSmokeStageState,
  OFFLINE_BANNER_TEXT,
  type SmokeStageLog,
  type SmokeStageName,
} from './fixture';

interface SmokeFlowOptions {
  readonly failStage?: SmokeStageName;
}

interface ExecuteStageOptions {
  readonly shouldAdvanceStage?: boolean;
}

export interface SmokeFlowResult {
  readonly logs: readonly SmokeStageLog[];
  readonly refresh: jest.Mock<() => Promise<ConnectivityState>>;
}

export class SmokeStageError extends Error {
  readonly logs: readonly SmokeStageLog[];
  readonly stage: SmokeStageName;

  constructor(stage: SmokeStageName, detail: string, logs: readonly SmokeStageLog[]) {
    super(`Smoke stage failed [${stage}]: ${detail}`);
    this.name = 'SmokeStageError';
    this.logs = logs;
    this.stage = stage;
  }
}

const HERO_TEXT = 'Phos MVP';
const FRAME_WIDGET_TEXT = '프레임 프리셋';
const SESSION_WIDGET_TEXT = '세션 계약';

function hasOnPress(props: unknown): props is { onPress: () => void } {
  return (
    typeof props === 'object' &&
    props !== null &&
    'onPress' in props &&
    typeof (props as { onPress?: unknown }).onPress === 'function'
  );
}

function render(ui: React.ReactElement): ReactTestRenderer {
  let renderer: ReactTestRenderer | null = null;

  act(() => {
    renderer = create(ui);
  });

  if (!renderer) {
    throw new Error('Expected smoke renderer to be created');
  }

  return renderer;
}

function expectText(renderer: ReactTestRenderer, text: string): void {
  expect(renderer.root.findByProps({ children: text })).toBeDefined();
}

function expectTextMissing(renderer: ReactTestRenderer, text: string): void {
  expect(() => {
    renderer.root.findByProps({ children: text });
  }).toThrow();
}

function stageDetail(stage: SmokeStageName): string {
  switch (stage) {
    case 'launch':
      return 'app launch renders the initial booth shell';
    case 'booth':
      return 'booth widgets stay visible in the online ready state';
    case 'offline':
      return 'offline banner is shown and retry entrypoint is available';
    case 'recover':
      return 'flow returns online and removes offline fallback';
  }
}

function validateStage(
  stage: SmokeStageName,
  renderer: ReactTestRenderer,
  refresh: jest.Mock<() => Promise<ConnectivityState>>,
  getCurrentStage: () => SmokeStageName,
): void {
  expectText(renderer, HERO_TEXT);

  switch (stage) {
    case 'launch':
      expectTextMissing(renderer, OFFLINE_BANNER_TEXT);
      break;
    case 'booth':
      expectText(renderer, FRAME_WIDGET_TEXT);
      expectText(renderer, SESSION_WIDGET_TEXT);
      expectTextMissing(renderer, OFFLINE_BANNER_TEXT);
      break;
    case 'offline': {
      expectText(renderer, OFFLINE_BANNER_TEXT);
      const retryButton = renderer.root.findByProps({ accessibilityRole: 'button' });
      const retryButtonProps: unknown = retryButton.props;

      if (!hasOnPress(retryButtonProps)) {
        throw new Error('Expected smoke retry button to expose onPress');
      }

      act(() => {
        retryButtonProps.onPress();
      });

      expect(refresh).toHaveBeenCalledTimes(1);
      expect(getCurrentStage()).toBe('recover');
      break;
    }
    case 'recover':
      if (getCurrentStage() !== 'recover') {
        throw new Error('Expected recover stage to be triggered by offline retry');
      }

      expectText(renderer, FRAME_WIDGET_TEXT);
      expectText(renderer, SESSION_WIDGET_TEXT);
      expectTextMissing(renderer, OFFLINE_BANNER_TEXT);
      break;
  }
}

export function runSmokeFlow(options: SmokeFlowOptions = {}): SmokeFlowResult {
  const logs: SmokeStageLog[] = [];
  let currentStage: SmokeStageName = 'launch';
  const refresh = jest.fn<() => Promise<ConnectivityState>>(() => {
    if (currentStage === 'offline') {
      currentStage = 'recover';
    }

    return Promise.resolve(getSmokeStageState(currentStage));
  });
  const useConnectivityStateMock = jest.mocked(useConnectivityState);

  useConnectivityStateMock.mockImplementation(() => ({
    connectivityState: getSmokeStageState(currentStage),
    refresh,
  }));

  const renderer = render(<App />);

  const executeStage = (stage: SmokeStageName, stageOptions: ExecuteStageOptions = {}): void => {
    const shouldAdvanceStage = stageOptions.shouldAdvanceStage ?? true;

    if (shouldAdvanceStage) {
      currentStage = stage;
    }

    act(() => {
      renderer.update(<App />);
    });

    try {
      if (options.failStage === stage) {
        throw new Error('forced fixture failure');
      }

      validateStage(stage, renderer, refresh, () => currentStage);
      logs.push({
        detail: stageDetail(stage),
        outcome: 'passed',
        stage,
      });
    } catch (error) {
      const detail = error instanceof Error ? error.message : 'Unknown smoke harness error';
      const nextLogs = [
        ...logs,
        {
          detail,
          outcome: 'failed' as const,
          stage,
        },
      ];

      throw new SmokeStageError(stage, detail, nextLogs);
    }
  };

  executeStage('launch');
  executeStage('booth');
  executeStage('offline');
  executeStage('recover', { shouldAdvanceStage: false });

  return {
    logs,
    refresh,
  };
}
