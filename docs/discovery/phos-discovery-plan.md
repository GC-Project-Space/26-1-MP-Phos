# Discovery Plan: Pho's (모바일 인생네컷 포토부스)

**Date**: 2026-03-20  
**Product Stage**: New product (초기 검증 단계)  
**Discovery Question**: `재미 중심` 인생네컷 경험에서, 사용자가 2분 내 촬영-편집-공유를 끝내고 사진/메이킹 영상을 모두 저장/공유하도록 만드는 가장 강한 MVP는 무엇인가?

---

## 1) Discovery Context (Step 1)

### 우리가 이미 아는 것
- 목표: 실용성보다 `재미`와 `짧은 완주 경험`이 핵심.
- 핵심 모드: `Live Booth` (연속 촬영 + 동시 영상 기록) / `Album Edit` (기존 사진으로 프레임 편집).
- MVP v1 필수: 프레임 선택, 라이브 촬영, 동시 영상 녹화, 컷 선택/간편 편집, 최종 렌더링, QR 공유 페이지 사진/영상 다운로드, 로컬 저장, 48h 자동 삭제, 분리 동의, 즉시 삭제/내보내기.
- Privacy/Safety 방향: trainingOptIn 기본 OFF, 최소 수집, 짧은 보관(48h), 동의 분리, 즉시 삭제/내보내기.
- API 방향: Google AIP-121 기반 resource-oriented + 표준 메서드 우선, 필요한 경우에만 custom method.

### 아직 모르는 것 (이번 Discovery로 검증)
- 사용자가 가장 강하게 반응하는 `재미 트리거`는 무엇인가? (프레임/타이머/사운드/메이킹 영상)
- 영상 동시 녹화가 실제 공유율을 얼마나 올리는가?
- 앨범 내 기존 프레임 사진 자동 수집 기능의 정확도/체감 가치가 충분한가?
- 2초 내 촬영 진입과 저사양 대응이 사용자 만족 임계치를 넘는가?

### 이번 Discovery가 inform할 의사결정
- Build/Kill: 메이킹 영상 다운로드를 MVP 핵심으로 고정할지
- Prioritize: 자동 수집 기능 vs 편집 고도화 vs 공유 기능 우선순위
- Pivot: 신규 촬영 중심 앱 vs 앨범 리믹스 중심 앱

---

## 2) Brainstorm Ideas (Step 2)

아래 10개 아이디어를 PM/Designer/Engineer 관점에서 발산했습니다.

| # | 아이디어 | 관점 | 왜 유의미한가 |
|---|---|---|---|
| 1 | 2초 Quick Start 촬영 진입 | PM | 핵심 KPI(완주율)와 직결 |
| 2 | Live 촬영 중 메이킹 영상 자동 기록 + 즉시 다운로드 | PM | 차별점이 명확하고 공유 동기 강함 |
| 3 | 감정 기반 프레임 추천(분위기: 귀여움/레트로/힙) | Designer | 초반 선택 피로 감소, 재미 상승 |
| 4 | 타이머 사운드/진동 연출 세트 | Designer | 촬영 몰입감 강화 |
| 5 | 컷 재배치 + 원탭 필터 + 텍스트 스티커 최소 편집 | PM | 짧은 완주 경험 유지 |
| 6 | Album Edit에서 슬롯별 크롭/회전/확대 템포 빠르게 | Designer | 기존 사진 재활용 가치 확보 |
| 7 | 앨범의 기존 프레임 사진 자동 수집(인생네컷/포토그레이) | Engineer | 장기 재방문 훅 가능 |
| 8 | 공유 페이지에서 사진/영상 분리 다운로드 + 만료시간 | Engineer | 사용성 + 프라이버시 동시 확보 |
| 9 | 저사양 디바이스 자동 해상도 다운스케일 | Engineer | 크래시/끊김 리스크 완화 |
|10| 촬영 중 앱 중단 복귀 시 세션 복구(임시 저장) | Engineer | 신뢰성 확보, 이탈 방지 |

### 이번 라운드에서 carry-forward 할 5개 (권장)
- #2 메이킹 영상 자동 기록/다운로드
- #1 2초 Quick Start
- #8 공유 페이지 이중 다운로드(사진/영상)
- #10 세션 복구 안정성
- #9 저사양 자동 해상도 조절

### Fast-follow 후보
- #7 기존 프레임 사진 자동 수집
- #6 Album Edit 고도화

---

## 3) Identify Assumptions (Step 3)

선정 아이디어 기준 가정(Assumption) 통합 목록입니다.

| A# | Assumption | Category |
|---|---|---|
| A1 | 사용자는 `최종 사진 + 메이킹 영상` 2종 결과물을 더 가치 있게 느끼고 실제 공유 행동이 증가한다 | Value |
| A3 | 2초 내 촬영 진입이 완주율 상승에 직접 기여한다 | Value |
| A4 | 자동 수집 정확도(기존 프레임 사진 식별)가 85% 이상 가능하다 | Feasibility |
| A5 | 자동 수집 기능이 실제 재방문 동기로 작동한다 | Value |
| A6 | 저사양에서도 동시 촬영+녹화가 허용 가능한 품질/발열/배터리로 동작한다 | Feasibility |
| A7 | 앱 중단/복귀 시 세션 복구가 사용자 신뢰를 높인다 | Usability |
| A8 | 촬영 중단 상황에서 자동 복구 UX를 사용자가 쉽게 이해한다 | Usability |
| A9 | 공유 페이지에서 사진/영상 분리 다운로드 UX가 혼란을 줄인다 | Usability |
| A10 | 48시간 보관 정책이 사용자 기대와 충돌하지 않는다 | Viability |
| A11 | trainingOptIn OFF와 분리 동의가 동의율 저하 없이 신뢰를 높인다 | Viability |
| A12 | 즉시 삭제/내보내기 기능을 MVP 범위 내 구현 가능하고 사용자가 실제로 수행 가능하다 | Feasibility |
| A13 | custom method(`:render`, `:finalize`)가 표준 메서드와 충돌 없이 명확하다 | Feasibility |
| A14 | share link 만료/권한 설계가 오남용을 실질적으로 줄인다 | Viability |
| A15 | QR 페이지 다운로드 성공률이 네트워크 변동 환경에서도 높게 유지된다 | Feasibility |
| A16 | Album Edit는 초기 MVP가 아닌 Fast-follow여도 제품 가치가 훼손되지 않는다 | Viability |

---

## 4) Prioritize Assumptions (Step 4)

Impact x Uncertainty 기준으로 우선순위를 매겼습니다.

| Priority | Assumption | Impact | Uncertainty | Leap of Faith |
|---|---|---|---|---|
| P1 | A6 저사양 동시 녹화 안정성 | High | High | Yes |
| P2 | A15 QR 다운로드 성공률 | High | High | Yes |
| P3 | A10+A11+A12 보관/동의/삭제-내보내기 신뢰성과 수행 가능성 | High | High | Yes |
| P4 | A1 결과물 2종 가치 + 공유 행동 증가 | High | High | Yes |
| P5 | A3 2초 진입이 완주율 상승 | High | Medium | Yes |
| P6 | A13 custom method 명확성 | Medium | Medium | No |
| P7 | A4+A5 자동 수집 정확도/재방문 가치 | Medium | High | No |
| P8 | A16 Album Edit fast-follow 허용성 | Medium | Medium | No |

가장 먼저 검증할 가정: **A6, A15, A10+A11+A12, A1**.

---

## 5) Opportunity Solution Tree Snapshot (Step 5)

**Desired Outcome**: `첫 세션 완주율 70%+`, `공유 전환율 35%+`, `세션당 평균 완료시간 2분 이내`

| Outcome | Opportunity | Candidate Solutions | Priority |
|---|---|---|---|
| 촬영 완주율 상승 | 촬영 진입/흐름 마찰 제거 | Quick Start(2초), 타이머 연출 단순화, 세션 복구 | High |
| 공유 전환율 상승 | 결과물 차별화 강화 | 메이킹 영상 자동 기록, 사진/영상 분리 다운로드, QR 공유 | High |
| 재방문율 상승 | 기존 자산 활용 가치 제공 | 앨범 프레임 사진 자동 수집, Album Edit 템플릿 | High |
| 신뢰 확보 | 프라이버시 불안 감소 | 분리 동의, 48h 자동 삭제, 즉시 삭제/내보내기 | High |

---

## 6) Validation Experiments (Step 6)

| # | Tests Assumption | Method | Success Criteria | Effort | Timeline |
|---|---|---|---|---|---|
| E1 | A1 | 실사용 태스크 테스트(10명, 본인 폰 QR 저장/공유) | 2분 내 사진+영상 저장 완료율 70%+, 실제 공유 행동 35%+ | M | W1 |
| E2 | A3 | 프로토타입 사용성 타이밍 테스트(후속으로 트래픽 확보 시 A/B) | time-to-camera 2초 내 달성률 80%+, 완주율 +15%p 잠재 확인 | M | W1-W2 |
| E3 | A6 | 저사양 기기 기술 스파이크(3종) | 프레임 드랍/발열/크래시 허용치 내(세션 실패율 <3%) | M | W1 |
| E4 | A4, A5, A16 | 앨범 자동 수집 규칙 기반 PoC + 수동 라벨 검증 | precision 0.85+, 사용자 가치 4.0/5, MVP 제외 허용 의견 60%+ | H | W2 |
| E5 | A10, A11, A12 | 프라이버시 태스크 테스트(동의 이해, 삭제/내보내기 실제 수행) | 정책 이해도 90%+, 삭제/내보내기 완료율 95%+, 이탈률 증가 <5%p | M | W2 |
| E6 | A15 | QR 다운로드 네트워크 변동 테스트 | 사진/영상 다운로드 성공률 97%+ | M | W2-W3 |

### Experiment Details

#### E1. 결과물 가치 검증
- **Hypothesis**: 메이킹 영상을 함께 제공하면 실제 저장/공유 행동이 증가한다.
- **Setup**: 사용자 본인 폰으로 QR 페이지 진입 후 사진/영상 저장 및 1회 공유까지 수행.
- **Measurement**: 2분 내 저장 완료율, 실제 공유 수행률, 실패 지점.
- **Decision**: 기준 미달 시 영상 기본 ON 대신 토글형으로 전환.

#### E2. 2초 진입 퍼널 검증
- **Hypothesis**: 촬영 진입시간 단축이 완주율을 올린다.
- **Setup**: 프로토타입 기반 태스크 테스트(Quick Start vs 일반 진입), 트래픽 확보 후 A/B.
- **Measurement**: time-to-camera, 진입-촬영완료-저장완료 전환률.
- **Decision**: 2초 달성률/완주율 기준 미달 시 진입 UI 재설계 우선.

#### E3. 저사양 안정성 스파이크
- **Hypothesis**: 해상도 자동 조절로 저사양에서도 동시 녹화 가능.
- **Setup**: 해상도 프로파일(High/Medium/Low) 자동 전환 로직 시험.
- **Measurement**: 세션 실패율, 메모리 피크, 체감 지연.
- **Decision**: 실패율 3% 초과 시 녹화 품질 단계별 제한 도입.

#### E4. 자동 수집 정확도 검증
- **Hypothesis**: 규칙 기반 분류로 프레임 사진 자동 식별 가능.
- **Setup**: 앨범 샘플 라벨셋 구축 후 룰 기반 분류기 측정.
- **Measurement**: precision/recall, 사용자 체감 유용성.
- **Decision**: 정확도 미달 시 즉시 사용자 확인형(추천 후보 + 체크) UX로 축소하고 Fast-follow로 이관.

#### E5. 프라이버시 신뢰 UX 검증
- **Hypothesis**: 분리 동의 + 48h 삭제 명시가 신뢰를 높인다.
- **Setup**: 동의 UI 2종 비교(기본형 vs 투명성 강화형).
- **Measurement**: 정책 이해도, 삭제/내보내기 task 완료율, 이탈률.
- **Decision**: 이해도/완료율 기준 미달 시 카피 재작성 + 정보 구조 단순화.

#### E6. QR 다운로드 안정성 검증
- **Hypothesis**: 링크 만료/재시도 UX가 다운로드 성공률을 유지한다.
- **Setup**: 3G/불안정 Wi-Fi 포함 네트워크 시나리오 테스트.
- **Measurement**: 재시도 성공률, 총 완료시간, 에러 회복률.
- **Decision**: 성공률 미달 시 링크 만료 정책/재시도 플로우/파일 분할 전략을 우선 개선.

---

## 7) API/Privacy Concretization (검색 결과 반영)

### A) Resource-oriented API (AIP-121 계열 반영)
- 표준 메서드 우선: `Get/List/Create/Update/Delete`
- custom method는 꼭 필요한 동작에만 사용
  - `POST /v1/sessions/{sessionId}:render`
  - `POST /v1/sessions/{sessionId}:finalize`

권장 리소스 트리 (MVP):
- `Session`: `/v1/sessions`, `/v1/sessions/{sessionId}`
- `Asset`: `/v1/sessions/{sessionId}/assets`, `/v1/sessions/{sessionId}/assets/{assetId}`
- `Frame`: `/v1/frames`, `/v1/frames/{frameId}`
- `Consent`: `/v1/sessions/{sessionId}/consents`, `/v1/sessions/{sessionId}/consents/{consentId}`
- `ShareLink`: `/v1/sessions/{sessionId}/shareLinks`, `/v1/sessions/{sessionId}/shareLinks/{shareLinkId}`
- `ExportRequest`: `/v1/sessions/{sessionId}/exportRequests`, `/v1/sessions/{sessionId}/exportRequests/{exportRequestId}`
- `DeletionRequest`: `/v1/sessions/{sessionId}/deletionRequests`, `/v1/sessions/{sessionId}/deletionRequests/{requestId}`

표준/커스텀 메서드 매핑:
- 표준: `Create/Get/List/Update/Delete`는 Session/Asset/ShareLink/Consent/ExportRequest/DeletionRequest에 우선 적용
- 커스텀: 렌더/확정만 `:render`, `:finalize` 사용

응답 메타(요구사항 고정):
- `retentionExpiresAt`
- `trainingUsed`
- `consentVersion`
- `deletionStatus`

### B) Privacy/Safety 운영 가드레일
- 기본값: `trainingOptIn=false`
- 최소 수집: 계정 없이 세션 생성 가능(익명 sessionId)
- 보관: 기본 48시간 자동 삭제, 목적/만료시간 명시
- 동의 분리: 서비스 이용 동의 vs 데이터 활용 동의 분리
- 사용자 권리: 즉시 삭제 요청, 데이터 내보내기 요청
- 삭제/공유 불변조건:
  - `shareLink.expiresAt <= retentionExpiresAt`
  - 세션 삭제 즉시 해당 세션 `shareLink` 전체 무효화
  - 삭제 확정 전 export 요청 가능, export 완료 후에도 retention 규칙 동일 적용
- 로그 안전성: 해시/내부 ID, 시각, 액션 타입, consentVersion만 보관(원본 URL/PII 미보관)
- 학습 활용 보장: `trainingUsed=true`는 해당 세션의 동의 스냅샷(`consentVersion`)이 있을 때만 허용

프라이버시 상태 전이:
- `active -> export_requested -> delete_requested -> deleted`

---

## 8) Discovery Timeline (Step 7)

- **Week 1**: E1, E3 실행 (핵심 가치/기술 가능성 동시 검증)
- **Week 2**: E2, E4, E5 실행 (퍼널/자동수집/프라이버시 UX)
- **Week 3**: E6 + 통합 분석 + Build/Kill/Pivot 의사결정

---

## 9) Decision Framework (Step 7)

- If `E1+E2` 성공 -> Live Booth 중심 MVP 확정, 영상 기본 제공 유지
- If `E3` 실패 -> 저사양 모드 기본값 강화(해상도/프레임레이트 제한)
- If `E4` 실패 -> 자동 수집 기능은 Fast-follow로 이관, 반자동 추천 UX만 유지
- If `E5` 성공 -> 분리 동의/48h 정책을 온보딩 핵심 메시지로 전면 배치
- If `E6` 실패 -> 공유 링크 만료 정책/다운로드 재시도 플로우 우선 개선
- If `E5` 또는 `E6` 실패 -> 출시 게이트 보류(privacy/download 신뢰성 미충족)

최종 게이트(Go 조건):
- 완주율 >= 70%
- 공유 전환율 >= 35%
- 세션 실패율 < 3%
- 다운로드 성공률 >= 97%

---

## 10) Next Steps (Step 8)

1. 최상위 아이디어 기준으로 **PRD 초안 생성**
2. 사용자 검증용 **인터뷰 스크립트 작성** (E1/E5 보완)
3. 실험 추적용 **metrics dashboard 정의**
4. MVP 범위의 **user stories + effort 추정**

---

## 부록: 즉시 실행 가능한 MVP 우선순위

### Must
- Live 촬영 + 동시 영상 기록
- 최종 사진 렌더링
- QR 공유 페이지에서 사진/영상 각각 다운로드
- 48h 자동 삭제 + 분리 동의 + 즉시 삭제/내보내기
- Session 중심 API + `:render`/`:finalize` + ExportRequest/DeletionRequest

### Should
- 세션 복구 안정성
- 저사양 자동 해상도 조절
- Album Edit 기본 버전(슬롯 교체/크롭/회전)

### Could
- 앨범 자동 수집 고도화
- 감정 기반 프레임 추천
