# 컴포넌트 설명: Phos MVP v1

- **Status**: Review
- **Owner**: @luke
- **Last Updated**: 2026-03-23
- **문서 역할**: UX 흐름과 디자인 규칙을 화면/컴포넌트 책임, 상태, 데이터 의존성으로 분해하는 문서
- **Upstream**: [UI-UX-REQUIREMENTS-Phos.md](./UI-UX-REQUIREMENTS-Phos.md) (`UX-15` ~ `UX-24`, `UX-25` ~ `UX-45`), [DESIGN-SYSTEM-Phos.md](./DESIGN-SYSTEM-Phos.md) (`DS-01` ~ `DS-03`)
- **Downstream**: [USER-STORIES-Phos.md](./USER-STORIES-Phos.md) (구현 단위 분해), Flutter 구현 코드 `apps/mobile/lib/main.dart`, `apps/mobile/lib/screens/main_layout.dart`, `apps/mobile/lib/screens/home_screen.dart`, `apps/mobile/lib/screens/frame_selection_screen.dart`, `apps/mobile/lib/screens/result_screen.dart`
- **Traceability Prefix**: `COMP-xx`

---

## 1) 목적

이 문서는 Phos 모바일 UI를 구성하는 컴포넌트를 화면/도메인 관점으로 정의합니다.

현재 코드에 이미 존재하는 컴포넌트는 `현재`, 요구사항 기준으로 앞으로 필요한 컴포넌트는 `예정`으로 구분합니다.

이 문서는 각 컴포넌트가 `무엇을 렌더링하고 어떤 상태를 받아야 하는지`를 소유합니다. 시각 토큰/모션 수치 같은 규칙은 [DESIGN-SYSTEM-Phos.md](./DESIGN-SYSTEM-Phos.md), 사용자 가치 단위와 인수 기준은 [USER-STORIES-Phos.md](./USER-STORIES-Phos.md)에서 소유합니다.

## 2) 화면 수준 컴포넌트

| ID        | 컴포넌트                | 상태 | 목적                                                               | 주요 액션            | Upstream                  |
| --------- | ----------------------- | ---- | ------------------------------------------------------------------ | -------------------- | ------------------------- |
| `COMP-01` | `PhotoBoothApp`         | 현재 | Flutter 앱 진입점과 전역 테마 제공                                 | 없음                 | `UX-25`, `UX-38`, `DS-01` |
| `COMP-02` | `MainLayout`            | 현재 | 홈/갤러리/스튜디오 탭 구조 제공                                    | 탭 전환              | `UX-25`, `UX-38`, `DS-01` |
| `COMP-03` | `HomeScreen`            | 현재 | 브랜드, 시작 액션, 최근 촬영 목록을 제공                           | 촬영 시작            | `UX-15`, `UX-32`, `DS-01` |
| `COMP-04` | `FrameSelectionScreen`  | 현재 | 프레임 선택과 촬영 진입                                            | 프레임 선택          | `UX-16`, `DS-03`          |
| `COMP-05` | `FrameConversionScreen` | 현재 | 프레임 변환/촬영 후 처리 흐름                                      | 결과로 이동          | `UX-19`, `UX-21`          |
| `COMP-06` | `ResultScreen`          | 현재 | 최종 포토 스트립 저장과 확인                                       | 로컬 저장            | `UX-22`, `UX-32`          |
| `COMP-07` | `GalleryScreen`         | 현재 | 저장된 결과 목록과 재확인 흐름                                     | 결과 확인            | `UX-22`, `UX-32`          |
| `COMP-09` | `PrivacyControlsScreen` | 예정 | 동의와 보관 정책 안내 및 제어                                      | 동의 저장            | `UX-23`, `UX-39`          |
| `COMP-10` | `DataControlsScreen`    | 예정 | 삭제/내보내기 요청과 상태 제어                                     | 요청 실행            | `UX-24`, `UX-39`          |

## 3) 현재 컴포넌트

### 3.1 PhotoBoothApp / MainLayout

**코드 기준점**: `apps/mobile/lib/main.dart`, `apps/mobile/lib/screens/main_layout.dart`

- **ID / 연결**: `COMP-01` ← `UX-25`, `UX-38`, `DS-01`

- **책임**: MaterialApp, 전역 테마, 홈/갤러리/스튜디오 탭 구조 제공
- **UX 메모**: 실제 촬영 화면은 전용 풀스크린 레이아웃이 필요할 수 있다

### 3.2 HomeScreen

**코드 기준점**: `apps/mobile/lib/screens/home_screen.dart`

- **ID / 연결**: `COMP-02` ← `UX-15`, `UX-32`, `DS-01`

- **책임**: 브랜드, 촬영 시작 CTA, 최근 촬영 목록을 한 화면에 표시
- **현재 상태**: `Take a Shot` CTA로 프레임 선택 흐름에 진입한다
- **필요 변화**: 소개형 카피를 행동형 카피와 CTA 중심 구조로 전환, `브랜드 -> 가치 -> 시작 액션` 순서 유지

### 3.3 FrameSelectionScreen

**코드 기준점**: `apps/mobile/lib/screens/frame_selection_screen.dart`

- **ID / 연결**: `COMP-03`의 현재 기반 ← `UX-16`, `DS-03`

- **책임**: 프레임 선택 옵션을 보여주고 이후 변환/결과 흐름으로 연결
- **미래 역할**: 선택/썸네일/비활성 사유/현재 선택 상태 강화 필요

### 3.4 ResultScreen / GalleryScreen

**코드 기준점**: `apps/mobile/lib/screens/result_screen.dart`, `apps/mobile/lib/screens/gallery_screen.dart`

- **ID / 연결**: `COMP-04`, `COMP-07`, `COMP-10`의 상태 기반 샘플 ← `UX-17`, `UX-21`, `UX-24`

- **책임**: 촬영 결과 저장, 저장된 결과 목록 표시, 결과 재확인 흐름 제공
- **미래 역할**: 삭제/내보내기 요청과 보관 정책 표시를 결과 흐름에 결합

## 4) 계획된 MVP 컴포넌트

### 4.1 EntryHero

- **ID / 연결**: `COMP-11` ← `UX-15`, `DS-01`
- **목적**: 첫 화면에서 제품명, 핵심 가치, 시작 CTA를 보여주는 상단 블록
- **콘텐츠**: 브랜드, 한 줄 약속, 주 CTA, 선택 신뢰 메모

### 4.2 FramePresetList / FramePresetItem

- **ID / 연결**: `COMP-12` ← `UX-16`, `DS-03`
- **목적**: 4컷/6컷 프레임 옵션을 한눈에 비교
- **상태**: 기본 / 선택됨 / 비활성 / 로딩
- **표시 요소**: 프레임 제목, 슬롯 수, 레이아웃 미리보기, 사용 가능 여부

### 4.3 CaptureCountdown / CaptureProgress

- **ID / 연결**: `COMP-13` ← `UX-18`, `UX-33`, `UX-41`
- **목적**: 남은 시간, 현재 컷 번호, 전체 진행률을 명확히 안내
- **규칙**: 텍스트보다 숫자 인지가 우선이며 `3 / 6` 같은 진척 표시가 즉시 읽혀야 한다

### 4.4 MakingVideoStatus

- **ID / 연결**: `COMP-14` ← `UX-18`, `UX-40`
- **목적**: 메이킹 영상 기록 여부를 명확히 알림
- **상태**: 기록 중 / 저장됨 / 실패
- **규칙**: 실패 시 사진 흐름은 유지되고, 안내는 짧고 직접적이어야 함

### 4.5 ShotGrid / ShotOrderTray

- **ID / 연결**: `COMP-15` ← `UX-19`, `DS-03`
- **목적**: 촬영된 모든 컷 표시 및 최종 포토 스트립의 스트립 슬롯 순서 조정
- **상호작용**: 선택, 확대/상세 확인, 스트립 슬롯 배치 진입

### 4.6 QuickEditToolbar

- **ID / 연결**: `COMP-16` ← `UX-20`, `DS-03`
- **목적**: MVP 범위의 빠른 편집만 제공
- **하위 제어**: `FilterPresetPicker`, `TextOverlayInput`, `CropToFrameToggle`
- **비목표**: 고급 노출/색보정/레이어 편집

### 4.7 RenderStatusPanel

- **ID / 연결**: `COMP-17` ← `UX-21`, `UX-45`
- **목적**: 렌더링 중 상태와 결과를 알림
- **상태**: 처리 중 / 성공 / 실패
- **행동**: 재시도 / 결과 확인

### 4.8 결과 미리보기 / 결과 액션 바

- **ID / 연결**: `COMP-18` ← `UX-22`, `UX-32`
- **목적**: 최종 포토 스트립과 메이킹 영상 이용 가능 상태를 보여주고 결과물 확보 행동을 묶기
- **행동**: `로컬 저장`
- **규칙**: 로컬 저장을 기본 행동으로 둔다

### 4.9 ConsentSection / PrivacyActionPanel

- **ID / 연결**: `COMP-19` ← `UX-23`, `UX-39`
- **목적**: 서비스 이용 동의와 선택적 데이터 활용 동의를 분리하고, 삭제/내보내기 요청과 상태를 노출
- **상태**: active / export_requested / deletion_requested / deleted
- **계약 메모**: 현재 모바일 세션 계약은 일부 메타만 직접 노출하므로 상세 DTO는 별도 계약 정의가 필요하다

### 4.10 RecoveryNotice

- **ID / 연결**: `COMP-20` ← `UX-24`, `UX-27`
- **목적**: 짧은 중단 이후 미완료 세션 복구 가능 여부 안내
- **상태**: 복구 가능 / 복구 실패 / finalized 세션은 복구 불가
- **계약 메모**: 복구는 소프트 런치 안정화 항목이며 현재 shared 세션 status enum에는 전용 상태가 없다

## 5) 데이터 바운드 컴포넌트

| 컴포넌트                                 | 주요 데이터 의존성                                                       | 원본 계약                                  |
| ---------------------------------------- | ------------------------------------------------------------------------ | ------------------------------------------ |
| `FramePresetList`                        | `FrameSummary[]`                                                         | `apps/api/src/contracts/frame.ts`          |
| 세션 상태 표시 영역                      | `SessionSummary`                                                         | `apps/api/src/contracts/session.ts`        |
| `QuickEditToolbar`                       | `SessionEditState`                                                       | `apps/api/src/contracts/session.ts`        |
| `PrivacyActionPanel`                     | `deletionStatus`, `consentVersion`, `trainingUsed`, `retentionExpiresAt` | `apps/api/src/contracts/session.ts`        |

## 6) 컴포넌트 인수 규칙

- 각 컴포넌트는 한 가지 주 역할만 가져야 한다
- 모든 상태 컴포넌트는 성공/실패/사용 불가를 구분해야 한다
- 데이터 계약과 분리된 임의 UI 상태를 만들지 않는다
- 프라이버시 관련 컴포넌트는 필수/선택/비가역 상태를 명확히 분리한다
- 촬영 플로우 컴포넌트는 속도와 현재 단계 인지를 최우선으로 한다
- 인터랙티브 컴포넌트는 `UX-39`, `UX-40`, `UX-41`을 만족하도록 접근성 이름/역할과 reduced-motion 대응을 고려해야 한다
