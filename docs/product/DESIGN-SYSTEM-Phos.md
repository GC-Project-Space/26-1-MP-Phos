# Design System: Phos MVP v1

**Date**: 2026-03-21  
**Document Type**: Product design system baseline  
**Scope**: Mobile MVP v1 visual and interaction system  
**Source Docs**: `docs/product/UI-UX-REQUIREMENTS-Phos.md`, `docs/product/PRD-Phos.md`, `apps/mobile/src/shared/config/theme.ts`, `apps/mobile/src/shared/ui/InfoCard.tsx`

---

## 1) System Purpose

이 문서는 Phos MVP 모바일 UI가 일관된 감도와 사용성을 유지하도록 하는 디자인 시스템 기준서입니다.

현재 앱 코드에는 작은 색상 토큰과 카드 스타일만 존재하므로, 본 문서는 그 초기 구현을 기반으로 MVP에 필요한 시각/상호작용 규칙을 확장 정의합니다.

---

## 2) Experience Direction

### Visual thesis

`따뜻한 필름 톤 위에 빠른 촬영 흐름을 얹는, 가볍지만 신뢰감 있는 모바일 포토부스 인터페이스`

### Content plan

- 시작: 브랜드와 핵심 행동을 바로 보여준다
- 촬영: 현재 단계와 리듬을 분명하게 보여준다
- 결과: 사진과 영상 결과물을 확실히 확보하게 한다
- 신뢰: 보관/삭제/동의 상태를 숨기지 않는다

### Interaction thesis

- 카운트다운과 진행률은 촬영 리듬을 만든다
- 렌더/저장/다운로드 상태는 기다림의 불안을 줄이는 방향으로 움직인다
- 성공/실패/복구 피드백은 짧고 즉각적이어야 한다

---

## 3) Design Principles

1. **Result-first**: 화면은 기능보다 결과물 확보 흐름을 우선한다.
2. **Calm control**: 재미 중심 제품이어도 UI 크롬은 차분해야 한다.
3. **Single dominant action**: 각 화면에는 하나의 주 행동만 강조한다.
4. **Trust by visibility**: 데이터 보관/동의/삭제 상태를 숨기지 않는다.
5. **Prototype to product continuity**: 현재의 색/톤/카드 언어를 버리지 않고 확장한다.

---

## 4) Foundations

## 4.1 Color Tokens

현재 구현 토큰은 `apps/mobile/src/shared/config/theme.ts`에 정의되어 있습니다.

| Token           | Value     | Usage                       |
| --------------- | --------- | --------------------------- |
| `background`    | `#f6f3ee` | 앱 기본 배경                |
| `surface`       | `#fffdf9` | 주요 패널/컨테이너          |
| `surfaceMuted`  | `#efe7db` | 목록 아이템, 보조 블록      |
| `border`        | `#ded2c1` | 얇은 구분선과 패널 경계     |
| `accent`        | `#a35f2b` | 강조 상태, primary emphasis |
| `textPrimary`   | `#1f1711` | 주요 텍스트                 |
| `textSecondary` | `#64564a` | 설명, 메타, 보조 라벨       |

### Semantic usage rules

- `accent`는 한 화면에서 한 가지 핵심 정보만 강조할 때 사용한다
- destructive action은 추후 별도 red 계열 semantic token을 추가하되, 현재는 문서 단계에서 reserved로 둔다
- 상태 구분을 색상 하나에만 의존하지 않는다

## 4.2 Typography

현재 코드 기준으로 자주 사용되는 스케일은 `12 / 13 / 15 / 16 / 18 / 28`입니다.

### Recommended type scale

| Role      | Size | Weight | Usage                   |
| --------- | ---- | ------ | ----------------------- |
| Display   | 28   | 800    | 시작 화면 핵심 타이틀   |
| Heading L | 24   | 700    | 주요 섹션 헤드라인      |
| Heading M | 18   | 700    | 카드/패널 타이틀        |
| Body M    | 15   | 400    | 본문 설명               |
| Body S    | 13   | 400    | 메타 설명, 라벨         |
| Label XS  | 12   | 700    | kicker, badge, overline |

### Typography rules

- 한 화면에서 폰트 역할은 명확히 분리한다
- 긴 설명 문장은 `Body M` 중심으로 유지한다
- badge, status, kicker는 uppercase를 사용하더라도 남발하지 않는다

## 4.3 Spacing

현재 구현은 `4 / 10 / 12 / 16 / 18 / 20 / 24` 단위를 중심으로 구성됩니다.

### Recommended spacing scale

- `4`: 미세 라벨 간격
- `8`: 조밀한 수평 정렬
- `12`: 리스트 아이템 내부 간격
- `16`: 기본 섹션 간격
- `20`: screen padding 기본값
- `24`: 그룹 분리, hero/panel breathing room
- `32+`: 화면 전환 단위 분리

## 4.4 Radius and Borders

| Token        | Current value | Usage                     |
| ------------ | ------------- | ------------------------- |
| Panel radius | `24`          | hero, info card           |
| Item radius  | `18`          | list item, compact block  |
| Border width | `1`           | panel, section separation |

### Rules

- radius는 부드럽지만 과장되지 않게 유지한다
- border는 구조를 설명할 때만 사용한다
- 그림자보다 색 대비와 간격으로 위계를 만든다

---

## 5) Layout System

## 5.1 App Shell

- Safe area를 기본으로 한다
- 화면 배경은 `background`를 사용한다
- 세로 스크롤 화면에서는 핵심 CTA가 아래로 밀려 사라지지 않게 우선순위를 조정한다

## 5.2 Screen Composition

- 화면은 `header -> primary content -> action zone`의 3단 구조를 기본으로 한다
- 홈/결과 화면에서는 상단 설명 영역과 하단 행동 영역을 명확히 분리한다
- 촬영 화면에서는 카메라 프리뷰와 진행 정보가 시각적 중심이 된다

## 5.3 Panel Usage

- 현재 코드의 `InfoCard` 패턴은 informational panel의 기본형으로 사용한다
- 모든 영역을 카드로 감싸지 않는다
- 실제 인터랙션이 없는 영역은 카드보다 plain layout이 우선이다

---

## 6) Component Styling Rules

## 6.1 Buttons

### Primary button

- 한 화면에 하나만 강하게 강조한다
- `accent` 기반 채움 또는 강한 대비형 버튼을 사용한다
- 저장, 촬영 시작, 다음 단계 진입에 사용한다

### Secondary button

- 외곽선 또는 toned surface 스타일
- skip, retry, QR 받기 같은 보조 액션에 사용한다

### Tertiary action

- 텍스트 버튼
- 설정, 정책 상세, 도움말 같은 저우선 행동에 사용한다

## 6.2 Status Badge

- 짧은 상태 단어 중심으로 사용한다
- `Ready`, `Paused`, `Saved`, `Recording failed`처럼 즉시 해석 가능해야 한다
- badge만으로 상태를 전하지 말고 주변 컨텍스트를 함께 둔다

## 6.3 Lists and Items

- 프레임 목록과 샷 목록은 스캔 가능한 리듬이 중요하다
- 항목마다 주 정보와 보조 정보의 위계를 분명히 나눈다
- selection state는 배경/테두리/아이콘 중 최소 두 가지로 구분한다

---

## 7) Motion and Feedback

### Required motion patterns

1. **Countdown motion**: 숫자 변화가 또렷하고 리듬감 있어야 한다
2. **Progress transition**: 컷 완료마다 다음 단계로 넘어감을 분명히 보여준다
3. **Result feedback**: 렌더/저장/다운로드 성공 상태를 짧은 전환으로 확인시킨다

### Motion rules

- 빠르고 짧아야 한다
- 상태 전달이 목적이어야 한다
- 저사양 기기에서 끊기면 장식 모션을 먼저 줄인다

---

## 8) Content System

### Product copy style

- 짧은 문장
- 행동 유도 중심
- 기술 구현보다 사용자 행위 설명 우선

### UI copy examples

- `4컷 프레임 선택`
- `지금 촬영을 시작할게요`
- `사진은 준비됐어요`
- `영상 저장에 실패했어요. 사진은 계속 진행할 수 있어요`
- `48시간 후 자동 삭제돼요`

---

## 9) Trust, Privacy, and Safety Patterns

- 필수 동의와 선택 동의는 체크 영역부터 분리한다
- 보관 기간, 삭제, 내보내기 정보는 FAQ 뒤가 아니라 흐름 안에서 보여준다
- deletion action은 강한 경고와 irreversible messaging을 포함한다
- export / delete request 이후에는 현재 상태를 노출해야 한다

---

## 10) Accessibility Baseline

- 중요한 텍스트는 `textSecondary`만으로 오래 읽게 하지 않는다
- 밝은 배경에서도 contrast가 유지되어야 한다
- 버튼과 토글은 충분한 터치 영역을 가진다
- 상태 변화는 텍스트, 아이콘, 위치 변화 등 복수 수단으로 전달한다

---

## 11) Current-to-Future Mapping

| Current code anchor    | Current role        | Future system role                   |
| ---------------------- | ------------------- | ------------------------------------ |
| `palette`              | 최소 색상 토큰      | 정식 semantic color foundation       |
| `InfoCard`             | 정보 패널 공통형    | panel primitive                      |
| `ExperienceOverview`   | 프레임 목록 샘플    | Frame Selection preview/list pattern |
| `SessionReadiness`     | 계약/상태 검증 샘플 | session status card / debug aid      |
| `BoothHomeScreen` hero | 소개형 scaffold     | Entry screen content block           |

---

## 12) Design Review Checklist

- 한 화면에 primary action이 하나만 또렷한가
- 촬영 화면에서 현재 컷/진행률/기록 상태가 동시에 읽히는가
- 카드가 없어도 되는 영역을 카드로 감싸지 않았는가
- privacy 정보가 보조 화면에만 숨지 않았는가
- 성공/실패/만료/복구 상태가 각각 다른 시각 언어를 갖는가
- 현재 토큰과 충돌 없이 확장 가능한가
