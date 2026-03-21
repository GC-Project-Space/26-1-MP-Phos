# Component Descriptions: Phos MVP v1

**Date**: 2026-03-21  
**Document Type**: Component inventory and description  
**Scope**: Current scaffold + planned MVP mobile components  
**Source Docs**: `docs/product/UI-UX-REQUIREMENTS-Phos.md`, `docs/product/DESIGN-SYSTEM-Phos.md`, `docs/product/PRD-Phos.md`, `docs/product/USER-STORIES-Phos.md`

---

## 1) Purpose

이 문서는 Phos 모바일 UI를 구성하는 컴포넌트를 화면/도메인 관점으로 정의합니다.

현재 코드에 이미 존재하는 컴포넌트는 `Current`로, 요구사항 기준으로 앞으로 필요한 컴포넌트는 `Planned`로 구분합니다.

---

## 2) Screen-level Components

| Component               | Status  | Purpose                                                            | Primary action       |
| ----------------------- | ------- | ------------------------------------------------------------------ | -------------------- |
| `AppRootShell`          | Current | safe area, status bar, scroll container를 제공하는 앱 루트 셸 패턴 | 없음                 |
| `BoothHomeScreen`       | Current | 현재 요구사항과 시스템 준비 상태를 요약하는 엔트리 화면            | 없음 - CTA planned   |
| `FrameSelectionScreen`  | Planned | 프레임 선택과 세션 반영                                            | 프레임 선택 완료     |
| `CaptureScreen`         | Planned | 카운트다운 연속 촬영과 메이킹 영상 기록                            | 촬영 시작 / 재시작   |
| `ReviewScreen`          | Planned | 촬영 결과 검토와 슬롯 순서 조정                                    | 렌더로 이동          |
| `EditScreen`            | Planned | 빠른 편집 도구 제공                                                | 편집 적용 / 건너뛰기 |
| `RenderScreen`          | Planned | 렌더 진행 상태와 결과 전환                                         | 다시 시도            |
| `ResultScreen`          | Planned | 최종 사진/영상 확보 액션 제공                                      | 기기에 저장          |
| `QRDownloadScreen`      | Planned | QR 진입 후 photo/video 다운로드를 분리 제공                        | 자산 다운로드        |
| `PrivacyControlsScreen` | Planned | 동의와 보관 정책을 안내하고 제어 제공                              | 동의 저장            |
| `DataControlsScreen`    | Planned | 삭제/내보내기 요청과 상태를 제어                                   | 요청 실행            |

---

## 3) Current Components

## 3.1 AppRootShell

**Code anchor**: `apps/mobile/src/app/App.tsx`

### Responsibility

- safe area 적용
- 상태 바 스타일 지정
- 세로 스크롤 컨테이너 제공
- 첫 페이지 마운트

### UX notes

- 현재는 `App.tsx` 안에 인라인으로 존재하는 루트 셸 패턴이다
- 현재는 단일 스크롤 홈을 감싸는 구조다
- 실제 촬영 화면에서는 스크롤 컨테이너 대신 전용 풀스크린 레이아웃이 필요할 수 있다

## 3.2 BoothHomeScreen

**Code anchor**: `apps/mobile/src/pages/booth-home/ui/BoothHomeScreen.tsx`

### Responsibility

- MVP 방향을 소개한다
- 프레임 개요와 세션 준비 상태를 한 화면에 보여준다

### Current state

- 현재 화면에는 실제 CTA가 구현되어 있지 않다
- 따라서 이 화면은 `entry scaffold`이며, `Live Booth 시작` 액션은 planned 상태다

### Required evolution

- 실제 제품 진입 화면으로 전환되어야 한다
- 현재 설명형 copy는 행동형 copy와 CTA 중심 구조로 바뀌어야 한다
- hero 내부 정보는 `브랜드 -> 가치 -> 시작 액션` 순서를 유지해야 한다

## 3.3 ExperienceOverview

**Code anchor**: `apps/mobile/src/widgets/experience-overview/ui/ExperienceOverview.tsx`

### Responsibility

- `FRAME_CATALOG`를 읽어 프레임 목록을 보여준다
- 프레임 이름, 레이아웃 타입, 컷 수, 활성 상태를 전달한다

### Inputs

- `frames: FrameSummary[]`

### States

- 기본 목록 표시
- 활성/비활성 상태 표시

### Future role

- 실제 Frame Selection 리스트의 기초 패턴으로 확장 가능하다
- 선택, 썸네일, disabled reason, currently selected state가 추가되어야 한다
- 현재 shared frame contract에는 disabled reason이 없으므로, 이 상태는 contract 확장 이후 구체화해야 한다

## 3.4 SessionReadiness

**Code anchor**: `apps/mobile/src/widgets/session-readiness/ui/SessionReadiness.tsx`

### Responsibility

- session payload preview를 schema로 검증한다
- 세션 계약이 모바일에서 해석 가능한지 보여준다

### Inputs

- 현재는 내부 preview payload를 사용한다

### Future role

- 운영용 debug surface 또는 session status panel로 분리 가능하다
- 사용자용 제품 화면에서는 기술적 wording을 더 쉬운 상태 안내로 바꿔야 한다
- recovery 관련 상태는 현재 shared session contract에 없으므로, 별도 상태 표시를 하려면 contract 확장이 먼저 필요하다

## 3.5 InfoCard

**Code anchor**: `apps/mobile/src/shared/ui/InfoCard.tsx`

### Responsibility

- 공통 정보 패널 컨테이너
- title + subtitle + content slot 제공

### Inputs

- `title: string`
- `subtitle: string`
- `children`

### Visual role

- `surface`, `border`, `24px radius` 기반 패널 언어를 만든다

### Usage rule

- 정보 요약에는 적합하다
- 모든 인터랙션 영역에 무분별하게 적용하면 안 된다

---

## 4) Planned MVP Components

## 4.1 EntryHero

### Purpose

첫 화면에서 제품명, 핵심 가치, 시작 CTA를 보여주는 상단 블록

### Content

- brand
- one-line promise
- primary CTA
- optional trust note

### UX rule

- 브랜드가 가장 먼저 읽혀야 한다
- 설명보다 행동이 먼저 보여야 한다

## 4.2 FramePresetList

### Purpose

4컷/6컷 프레임 옵션을 한눈에 비교하게 하는 목록

### Child component

- `FramePresetItem`

### Required states

- default
- selected
- disabled
- loading

## 4.3 FramePresetItem

### Purpose

단일 프레임의 구조와 상태를 보여준다

### Required content

- frame title
- slot count
- layout preview
- availability

### Interaction

- 탭 시 선택
- selected state가 즉시 보인다

## 4.4 CaptureCountdown

### Purpose

다음 셔터까지 남은 시간을 또렷하게 안내한다

### Required content

- 남은 초
- 현재 shot index
- 전체 shot count

### UX rule

- 텍스트보다 숫자 인지가 우선이다

## 4.5 CaptureProgress

### Purpose

촬영 전체 진행률과 현재 단계를 보여준다

### Required content

- `3 / 6` 같은 진척 표시
- 현재 단계 라벨

## 4.6 MakingVideoStatus

### Purpose

메이킹 영상 기록 여부를 명확히 알려준다

### States

- recording
- saved
- failed

### UX rule

- 실패 시 photo flow는 유지되며, 안내는 짧고 직접적이어야 한다

## 4.7 ShotGrid

### Purpose

캡처된 모든 샷을 썸네일 그리드로 보여준다

### Required interactions

- 선택
- 확대 보기 또는 상세 확인
- 슬롯 배치 진입

## 4.8 ShotOrderTray

### Purpose

최종 스트립 슬롯 순서를 시각적으로 보여주고 조정한다

### UX rule

- 현재 배치와 변경 결과가 동시에 이해되어야 한다

## 4.9 QuickEditToolbar

### Purpose

MVP 범위의 빠른 편집만 제공한다

### Child controls

- `FilterPresetPicker`
- `TextOverlayInput`
- `CropToFrameToggle`

### Non-goal

- 고급 노출/색보정/레이어 편집

## 4.10 RenderStatusPanel

### Purpose

렌더링 진행 중인 상태와 결과를 알려준다

### States

- processing
- success
- failed

### Required actions

- retry
- result 확인

## 4.11 ResultPreview

### Purpose

최종 strip과 메이킹 영상 availability를 보여준다

### Required content

- final photo preview
- making video availability
- session status summary

## 4.12 ResultActionBar

### Purpose

결과물 확보에 필요한 행동을 묶는다

### Actions

- `기기에 저장`
- `QR로 받기`

### UX rule

- local save를 primary로 둔다

## 4.13 QRDownloadPanel

### Purpose

photo/video 자산별 다운로드를 분리 제공한다

### Required states

- both assets available
- photo only
- video only
- expired
- unavailable

### Contract note

- 현재 shared package에는 asset/share-link DTO가 없으므로 이 패널은 planned UI scope다

## 4.14 ConsentSection

### Purpose

필수 동의와 선택 동의를 분리 표시한다

### Required content

- required consent label
- optional training consent label
- retention notice

### UX rule

- optional consent는 기본 선택 상태가 아니어야 한다

### Contract note

- current mobile session contract에는 `trainingUsed`, `consentVersion`, `retentionExpiresAt`만 직접 노출되므로 상세 consent DTO는 별도 계약 정의가 필요하다

## 4.15 PrivacyActionPanel

### Purpose

삭제/내보내기 요청과 현재 상태를 노출한다

### Required actions

- export request
- deletion request

### Required states

- active
- export_requested
- delete_requested
- deleted

### Contract note

- 현재 shared session contract는 deletion status만 직접 노출하며 export/deletion request 리소스 DTO는 아직 shared package에 없다

## 4.16 RecoveryNotice

### Purpose

짧은 중단 이후 unfinished session을 복구할 수 있는지 안내한다

### States

- recovery available
- recovery failed
- finalized session not recoverable

### Contract note

- recovery는 PRD 상 soft-launch hardening 항목이며 현재 shared session status enum에는 전용 상태가 없다

---

## 5) Data-bound Components

| Component                                    | Primary data dependency                                                  | Source contract                            |
| -------------------------------------------- | ------------------------------------------------------------------------ | ------------------------------------------ |
| `FramePresetList`                            | `FrameSummary[]`                                                         | `packages/shared/src/contracts/frame.ts`   |
| `SessionReadiness` / session status surfaces | `SessionSummary`                                                         | `packages/shared/src/contracts/session.ts` |
| `QuickEditToolbar`                           | `SessionEditState`                                                       | `packages/shared/src/contracts/session.ts` |
| `PrivacyActionPanel`                         | `deletionStatus`, `consentVersion`, `trainingUsed`, `retentionExpiresAt` | `packages/shared/src/contracts/session.ts` |

---

## 6) Component Acceptance Rules

- 각 컴포넌트는 한 가지 주 역할만 가져야 한다
- 모든 상태 컴포넌트는 success/failure/unavailable를 구분해야 한다
- 데이터 계약과 분리된 임의 UI 상태를 만들지 않는다
- privacy 관련 컴포넌트는 필수/선택/비가역 상태를 명확히 분리한다
- 촬영 플로우 컴포넌트는 속도와 현재 단계 인지를 최우선으로 한다
