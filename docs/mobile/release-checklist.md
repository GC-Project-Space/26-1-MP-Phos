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
