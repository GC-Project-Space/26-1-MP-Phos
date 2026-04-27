# Mobile release checklist

## Flutter readiness

- [ ] **R1** `apps/mobile`이 Flutter 앱의 단일 모바일 프론트엔드 경로다.
- [ ] **R2** Dart package는 `phos_mobile`, native bundle/application ID는 `com.phos.mobile`이다.
- [ ] **R3** 홈, 프레임 선택, 변환, 결과, 갤러리 흐름이 Flutter 화면에서 유지된다.

## Verification

- [ ] `cd apps/mobile && flutter pub get`
- [ ] `cd apps/mobile && flutter analyze`
- [ ] `cd apps/mobile && flutter test`
- [ ] 필요한 대상에서 `pnpm mobile:android`, `pnpm mobile:ios`, 또는 `pnpm mobile:web` 수동 기동 확인

## React Native removal checks

- [ ] Expo/React Native 앱 코드와 Jest smoke harness가 제거되어 있다.
- [ ] 루트 명령어는 Flutter CLI 기준으로 동작한다.
- [ ] 문서와 lockfile에 Expo/React Native 모바일 앱 의존성이 남아 있지 않다.
