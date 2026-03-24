# Mobile release checklist

## Offline connectivity readiness

- [x] **R1** Booth 화면에서 `unknown`/`offline`/`online` 상태를 일관된 connectivity 계층으로 처리한다.
- [x] **R1/T1** 앱 초기 NetInfo `null`/`unknown` 상태를 `offline`으로 오판하지 않는다.
- [x] **R2** `useConnectivityState()` 훅으로 화면이 connectivity 상태와 refresh 진입점을 사용한다.
- [x] **R3/T2** Booth 상단에 offline 상태 안내 배너를 노출하고 offline→online 전환에 맞춰 상태를 갱신한다.
- [x] **R5/T4** offline 배너의 retry 액션이 refresh 콜백을 호출한다.
- [x] **R4/T5** online 상태에서 기존 hero/프레임/세션 위젯 UI가 유지된다.

## Test case traceability

- [x] **T1** 초기 unknown 상태 노출 검증 (`connectivity-state.test.ts`, `useConnectivityState.test.tsx`)
- [x] **T2** offline 배너 노출 검증 (`BoothHomeScreen.test.tsx`)
- [x] **T3** offline 이후 online 복귀 검증 (`connectivity-state.test.ts`, `useConnectivityState.test.tsx`)
- [x] **T4** retry 콜백 호출 검증 (`BoothHomeScreen.test.tsx`)
- [x] **T5** online 시 기존 UI 회귀 방지 검증 (`BoothHomeScreen.test.tsx`)

## Verification

- [x] `pnpm --filter mobile typecheck`
- [x] `pnpm --filter mobile test`

## Mobile test infrastructure readiness

- [x] **R1** Jest 설정이 React Native Testing Library 기반 컴포넌트/화면 테스트를 안정적으로 지원한다.
- [x] **R2** primitive, provider, data, screen 계층에 각각 의미 있는 테스트가 있다.
- [x] **R3** missing provider, invalid payload 같은 실패 케이스가 실제 fixture 기반으로 검증된다.
- [x] **R4** trivial assertion 대신 UI 노출, context 의존성, validation 실패 같은 실제 동작을 검증한다.

## Test infrastructure traceability

- [x] **T1** primitive render (`src/shared/ui/shared-ui-primitives.test.tsx`)
- [x] **T2** provider missing (`src/app/providers/AppProviders.test.tsx`, `src/app/App.test.tsx`)
- [x] **T3** data validation fail (`src/shared/contracts/session.test.ts`, `src/__fixtures__/sessionSummary.ts`)
- [x] **T4** screen integration (`src/pages/booth-home/ui/BoothHomeScreen.test.tsx`, `src/app/App.test.tsx`)
