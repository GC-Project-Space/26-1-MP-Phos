# UI/UX Requirements: Phos MVP v1

**Date**: 2026-03-21  
**Document Type**: UI/UX requirements specification  
**Scope**: Mobile MVP v1 user experience definition  
**Source Docs**: `docs/product/PRD-Phos.md`, `docs/product/USER-STORIES-Phos.md`, `docs/product/WWA-Backlog-Phos.md`, `README.md`  
**Current UI Anchor**: `apps/mobile/src/pages/booth-home/ui/BoothHomeScreen.tsx`

---

## 1) Document Goal

이 문서는 현재 PRD, user story, backlog에 흩어져 있는 요구사항을 실제 모바일 화면 설계 관점으로 재정리한 UI/UX 정의서입니다.

목표는 세 가지입니다.

- 제품 요구사항을 화면 흐름 기준으로 해석한다
- 디자인/개발/QA가 같은 UX 기준으로 일할 수 있게 한다
- 현재의 프론트엔드 스캐폴드와 앞으로 구현할 MVP 화면 사이의 기준선을 만든다

---

## 2) Product UX Thesis

### Experience promise

Phos는 `2분 안에 촬영을 끝내고 결과물을 확보하는 재미 중심 모바일 포토부스`여야 합니다.

### Core UX value

- 빠르게 시작한다
- 촬영 흐름이 끊기지 않는다
- 사진과 메이킹 영상을 함께 남긴다
- 계정 없이 결과물을 확보한다
- 프라이버시 제어가 짧고 명확하다

### UX principles

1. **Fast to first action**: 첫 진입 후 사용자는 최대한 적은 판단으로 촬영을 시작해야 한다.
2. **One-hand understandable**: 핵심 액션은 한 손으로도 이해 가능해야 하며, 화면마다 주 행동은 하나여야 한다.
3. **Momentum over tooling**: 고급 편집보다 리듬감 있는 촬영 완주를 우선한다.
4. **Recover, do not punish**: 실패 시 처음부터 다시 배우게 하지 말고 재시도와 복구 경로를 준다.
5. **Privacy is part of the product**: 동의, 보관, 삭제, 내보내기는 법무 문구가 아니라 사용자 경험이어야 한다.

---

## 3) Primary Users and Context

### Primary users

- 친구, 연인, 소규모 모임에서 짧은 시간 안에 결과물을 남기고 싶은 사용자
- 별도 가입이나 복잡한 편집 없이 바로 찍고 저장하고 싶은 사용자

### Secondary users

- 행사/이벤트에서 여러 사람이 QR로 결과물을 받게 하고 싶은 사용자
- 프라이버시 민감도가 높아 데이터 보관과 삭제 통제를 중요하게 보는 사용자

### Usage context

- 서서 빠르게 사용한다
- 촬영 현장은 밝기, 소음, 네트워크 상태가 일정하지 않다
- 사용자는 앱에 오래 머물 의도가 없고, 즉시 완주를 기대한다

---

## 4) MVP Experience Flow

```text
Entry
  -> Live Booth 시작 CTA
  -> 프레임 선택
  -> 카메라 준비 완료
  -> 카운트다운 연속 촬영
  -> 메이킹 영상 동시 기록
  -> 촬영 결과 검토 / 순서 조정
  -> 간단 편집(선택)
  -> 최종 렌더링
  -> 결과 확인
  -> 로컬 저장 또는 QR 다운로드
  -> 필요 시 삭제 / 내보내기 요청
```

### Flow-level requirements

- 메인 플로우는 계정 생성 없이 완료 가능해야 한다
- `Live Booth 시작`은 즉시 촬영 개시가 아니라 익명 session 생성 후 frame selection으로 진입시키는 시작 액션으로 정의한다
- 사용자는 어떤 단계에 있는지 항상 알 수 있어야 한다
- 각 단계의 primary CTA는 한 개만 강조한다
- 실패 상태는 `왜 실패했는지`, `지금 무엇을 할 수 있는지`를 바로 알려야 한다
- 결과물 확보 전까지 사용자가 시스템 상태를 추측하게 두지 않는다

---

## 5) Screen Requirements

## 5.1 Entry / Home

### Goal

사용자가 제품 가치와 준비 상태를 빠르게 이해하고 `Live Booth 시작`으로 진입하게 한다.

### Required content

- 제품명 `Phos`
- 핵심 가치 한 줄: 사진 + 메이킹 영상 + 빠른 완주
- 현재 이용 가능 프레임 요약
- 세션/앱 준비 상태 요약
- primary CTA: `Live Booth 시작`

### UX requirements

- 첫 화면에서 브랜드와 핵심 액션이 동시에 보여야 한다
- 정보는 소개보다 `바로 시작할 수 있는지` 판단에 집중해야 한다
- MVP 단계에서는 기능 소개보다 사용 흐름 요약이 우선이다

### States

- 기본 상태
- 카메라 준비 불가 상태
- 오프라인/백엔드 준비 불가 상태

---

## 5.2 Frame Selection

### Goal

사용자가 4컷 또는 6컷 프레임을 2초 안에 이해하고 선택하게 한다.

### Required content

- 프레임 썸네일 또는 구조 미리보기
- 프레임 이름
- 컷 수
- 활성 여부
- 선택 완료 CTA

### UX requirements

- 최소 1개의 4컷, 1개의 6컷 프레임이 보여야 한다
- 프레임 간 차이는 시각적으로 바로 이해되어야 한다
- 선택 결과는 active session에 저장된 뒤 다음 단계로 이동해야 한다
- 비활성 프레임은 감추지 말고 비활성 사유를 설명 가능해야 한다
- 현재 shared frame contract에는 비활성 사유 필드가 없으므로, 이 요구사항은 contract 확장 전까지 planned UX requirement로 본다

### States

- 선택 전
- 선택됨
- 비활성
- 로딩/재시도

---

## 5.3 Camera Ready / Capture Start

### Goal

사용자가 카메라가 촬영 가능한 상태임을 확신하고 망설임 없이 촬영을 시작하게 한다.

### Required content

- 선택된 프레임 요약
- 현재 세션 상태
- 카메라 준비 완료 여부
- primary CTA: `촬영 시작`

### UX requirements

- 카메라 usable 상태가 되기 전에는 촬영 CTA를 활성화하지 않는다
- 준비 실패 시 retry path를 명확히 보여준다
- 프레임 선택 정보는 실패 후에도 유지되어야 한다

---

## 5.4 Countdown Multi-shot Capture

### Goal

사용자가 포토부스처럼 리듬감 있게 4컷 또는 6컷 촬영을 완료하게 한다.

### Required content

- 현재 몇 번째 샷인지 표시
- 다음 촬영까지 카운트다운
- 진행률 표시
- 중단 또는 재시작 가능 여부
- 메이킹 영상 기록 상태

### UX requirements

- 사용자는 현재 촬영 위치를 명확히 이해해야 한다
- 각 샷 전 countdown은 충분히 읽히되 흐름을 늦추지 않아야 한다
- 메이킹 영상 실패는 photo flow를 막지 않아야 한다
- 중단 시 session은 restartable 또는 recoverable 상태로 남아야 한다
- 현재 shared session contract에는 recovery 전용 상태가 없으므로 recovery UX는 soft-launch hardening 및 future contract work로 관리한다

### States

- 대기
- 카운트다운
- 촬영 중
- 일시 중단
- 영상 기록 실패
- 캡처 실패

---

## 5.5 Shot Review and Reorder

### Goal

사용자가 촬영한 컷 전체를 빠르게 훑고 최종 스트립 구성을 결정하게 한다.

### Required content

- 전체 샷 썸네일
- 현재 슬롯 순서
- 선택 상태
- render 진입 CTA
- optional edit CTA

### UX requirements

- 모든 샷을 한 번에 스캔할 수 있어야 한다
- 순서 변경은 직접적이고 되돌릴 수 있어야 한다
- 사용자는 편집 없이 바로 렌더로 넘어갈 수 있어야 한다
- 마지막 저장 상태가 복원되어야 한다

---

## 5.6 Simple Edit

### Goal

사용자가 흐름을 깨지 않는 최소 편집만 적용하게 한다.

### Allowed edit scope

- preset filter
- one text overlay
- crop-to-frame

### UX requirements

- 편집 도구는 적고 빠르게 이해 가능해야 한다
- 편집은 optional이어야 하며 skip이 명확해야 한다
- 편집 실패가 기존 샷 선택/순서를 손상시키면 안 된다
- 고급 편집 UI는 MVP에 포함하지 않는다

---

## 5.7 Render

### Goal

사용자가 `최종 결과를 만드는 중`임을 이해하고, 성공 또는 실패 이후 다음 행동을 바로 알게 한다.

### Required content

- 렌더링 진행 상태
- 성공 시 결과 미리보기
- 실패 시 재시도 CTA

### UX requirements

- 렌더링 중에는 시스템 상태를 숨기지 않는다
- 성공 후 photo asset이 결과 화면과 저장/공유 액션에 연결되어야 한다
- 실패 시 사용자는 다시 시도할 수 있어야 한다

---

## 5.8 Result / Save / QR Download

### Goal

사용자가 최종 사진과 메이킹 영상을 가장 확실한 방식으로 확보하게 한다.

### Required content

- 최종 사진 미리보기
- 메이킹 영상 존재 여부
- primary CTA: `기기에 저장`
- secondary CTA: `QR로 받기`
- asset별 다운로드 구분

### UX requirements

- 저장과 QR 다운로드의 역할 차이를 분명히 구분한다
- QR 페이지에서는 photo/video를 각각 독립적으로 받을 수 있어야 한다
- 만료되었거나 없는 asset은 broken state가 아니라 설명형 상태로 처리한다
- 다운로드 성공/실패는 사용자가 이해할 수 있게 피드백한다

---

## 5.9 Privacy Consent

### Goal

사용자가 필수 동의와 선택 동의를 헷갈리지 않고 이해하게 한다.

### Required content

- 서비스 이용 필수 동의
- 데이터 활용 선택 동의
- 보관 기간 안내
- 삭제/내보내기 가능 안내

### UX requirements

- 필수와 선택 항목을 시각적으로 분리한다
- `trainingOptIn=false`가 기본 상태여야 한다
- 필수 동의가 없으면 다음 단계로 진행할 수 없다
- 법률 문구만 길게 두지 말고 한 줄 요약을 먼저 보여준다

---

## 5.10 Delete / Export Controls

### Goal

사용자가 자신의 세션 데이터를 직접 제어할 수 있다고 느끼게 한다.

### Required content

- 현재 deletion status
- export request action
- deletion request action
- request 이후 상태 안내

### UX requirements

- 삭제는 돌이킬 수 없음을 분명히 알려야 한다
- export는 deletion finalization 전에만 가능해야 한다
- 삭제 확정 후 share link 무효화 결과를 사용자에게 설명해야 한다

---

## 6) Information Architecture

### MVP screen map

1. Entry / Home
2. Frame Selection
3. Camera Ready
4. Countdown Capture
5. Shot Review
6. Simple Edit
7. Render Progress
8. Final Result
9. QR Download Page
10. Consent / Privacy Controls
11. Delete / Export Request Surface

QR download surface와 delete/export surface는 구현 단계에서 별도 screen 또는 panel로 분리될 수 있으나, UX 책임은 문서상 분리해서 관리한다.

### Navigation rules

- 메인 플로우는 선형 구조를 유지한다
- 사용자는 이전 단계로 돌아갈 수 있지만, 이미 생성된 session state는 유지해야 한다
- 시스템이 자동으로 복구 가능한 경우, 복구 제안을 먼저 보여준다

---

## 7) Content Requirements

### Voice and tone

- 짧고 직접적이어야 한다
- 마케팅 문장보다 안내 문장 중심이어야 한다
- 기술 용어보다 행동 중심 언어를 사용한다

### Copy rules

- 화면당 headline은 하나
- 버튼 문구는 행동 동사 중심
- 에러 문구는 원인 + 다음 행동을 같이 제시
- privacy 문구는 숨기지 말고 짧게 요약

예시:

- 좋음: `지금 3번째 컷을 찍어요`
- 좋음: `영상 저장에 실패했어요. 사진 촬영은 계속할 수 있어요`
- 피해야 함: `예기치 못한 오류가 발생했습니다`

---

## 8) Visual and Interaction Requirements

### Visual direction

- 앱은 `재미 중심` 제품이지만 조작은 차분하고 명확해야 한다
- 결과물 중심 제품이므로 촬영 상태와 결과물 미리보기가 시각적 중심이어야 한다
- 프라이버시 관련 정보는 보조 정보가 아니라 신뢰 레이어로 보여야 한다

### Interaction requirements

- 주요 액션은 엄지 닿는 영역 안에 배치한다
- 카운트다운, 진행률, 성공/실패 상태는 즉시 피드백해야 한다
- 모션은 분위기보다 방향성과 상태 전달에 써야 한다

---

## 9) Accessibility and Performance Requirements

### Accessibility

- 텍스트와 배경 대비는 모바일 야외 사용을 고려해 충분해야 한다
- 상태 변화는 색상만으로 구분하지 않는다
- 터치 타깃은 충분히 커야 한다
- 중요한 상태와 CTA는 스크롤 없이 인지 가능해야 한다

### Performance

- 카메라 진입은 체감 2초 내를 목표로 한다
- 저사양 기기에서는 자동 preset 조정이 적용되어야 한다
- 렌더/저장/다운로드는 장시간 무응답처럼 보이지 않아야 한다

---

## 10) Non-goals for MVP

- 고급 사진 편집 도구
- 복잡한 템플릿 커스터마이징
- 계정 기반 개인화 흐름
- Album Edit 본 기능
- 출시 게이트로서의 고도화된 세션 복구

---

## 11) Implementation Notes from Current Repo State

- 현재 모바일 앱은 `BoothHomeScreen`, `ExperienceOverview`, `SessionReadiness`, `InfoCard` 중심의 스캐폴드 상태다
- 현재 화면은 요구사항 설명용 홈에 가깝고, 실제 촬영 플로우 화면은 아직 구현 전이다
- 따라서 이 문서는 `현재 구현을 설명하는 문서`라기보다 `현재 요구사항을 구현하기 위한 UX 기준 문서`로 사용해야 한다

---

## 12) Acceptance Checklist for Design and Build

- 첫 화면에서 제품명, 핵심 가치, 시작 CTA가 동시에 보이는가
- 프레임 선택이 2초 안에 이해되는가
- 촬영 중 현재 컷과 진행 상태가 명확한가
- 메이킹 영상 실패가 photo flow를 막지 않는가
- 편집 없이도 렌더로 갈 수 있는가
- 결과 화면에서 저장과 QR 다운로드의 차이가 분명한가
- 필수 동의와 선택 동의가 시각적으로 분리되어 있는가
- 삭제/내보내기 제어가 실제 행동으로 이어지는가
- 만료/실패/복구 상태가 모두 설명 가능한가
