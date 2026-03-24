import type { ConnectivityState } from '../data/network/connectivity-state';

export const SMOKE_STAGE_ORDER = ['launch', 'booth', 'offline', 'recover'] as const;

export type SmokeStageName = (typeof SMOKE_STAGE_ORDER)[number];

export interface SmokeStageLog {
  readonly stage: SmokeStageName;
  readonly outcome: 'passed' | 'failed';
  readonly detail: string;
}

export const OFFLINE_BANNER_TEXT = '인터넷 연결이 없습니다. 일부 부스 기능을 사용할 수 없어요.';

const SMOKE_STAGE_STATE_MAP: Record<SmokeStageName, ConnectivityState> = {
  launch: {
    connectionType: null,
    isConnected: null,
    isInternetReachable: null,
    status: 'unknown',
  },
  booth: {
    connectionType: null,
    isConnected: true,
    isInternetReachable: true,
    status: 'online',
  },
  offline: {
    connectionType: null,
    isConnected: false,
    isInternetReachable: false,
    status: 'offline',
  },
  recover: {
    connectionType: null,
    isConnected: true,
    isInternetReachable: true,
    status: 'online',
  },
};

export function getSmokeStageState(stage: SmokeStageName): ConnectivityState {
  return SMOKE_STAGE_STATE_MAP[stage];
}
