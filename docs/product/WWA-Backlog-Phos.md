# WWA Backlog: Phos

**Date**: 2026-03-20  
**Product**: Phos  
**Document Type**: Why-What-Acceptance backlog  
**Related Docs**: `docs/product/PRD-Phos.md`, `docs/product/USER-STORIES-Phos.md`, `docs/discovery/phos-discovery-plan.md`, `docs/discovery/phos-metrics-dashboard.md`  
**Design**: TBD  
**Scope**: MVP v1 first, then soft-launch hardening, then fast-follow

---

## 1) Backlog Overview (Step 1)

이 문서는 `Phos` MVP 구현을 위한 backlog item 모음입니다.  
각 항목은 Why-What-Acceptance 형식으로 정리했고, 한 스프린트 안에 논의하고 추정할 수 있는 크기로 맞췄습니다.

원칙:
- MVP에 직접 필요한 항목부터 먼저 적는다
- soft-launch hardening은 분리한다
- fast-follow는 MVP에서 빼고 남긴다

---

## 2) MVP WWA Items (Step 2)

### Item 1. Start session and ready camera

**Why:** 첫 진입이 느리면 재미 중심 제품의 핵심 가치가 깨집니다. 이 항목은 `빠른 완주`와 첫 세션 완주율 목표를 직접 지지합니다.

**What:** 사용자가 Live Booth를 시작하면 익명 세션을 만들고, 프레임을 고른 뒤 바로 촬영 가능한 카메라 상태로 들어갑니다. 디자인은 추후 연결하되, 현재 논의의 핵심은 `세션 시작 -> 프레임 선택 -> 카메라 ready`를 한 흐름으로 묶는 것입니다.

**Acceptance Criteria:**
- Live Booth 시작 시 익명 session이 생성되고 `session_started`가 기록된다
- 사용자는 최소 1개의 4컷 프레임과 1개의 6컷 프레임 중 선택할 수 있다
- 선택한 프레임은 active session에 저장된 뒤 카메라가 usable 상태가 된다
- 카메라가 usable 상태가 되면 앱은 `camera_ready`를 기록한다
- 카메라 준비 실패 시 사용자는 retry 경로를 보고, 저장된 프레임은 session에 유지된다

### Item 2. Run countdown multi-shot capture

**Why:** 사용자는 포토부스처럼 리듬감 있게 촬영해야 결과를 쉽게 완성할 수 있습니다. 이 항목은 strip 생성의 가장 기본 뼈대입니다.

**What:** 선택한 프레임 타입에 맞춰 4컷 또는 6컷 촬영을 진행합니다. 각 컷 전에 countdown이 보이고, 촬영 결과는 현재 세션에 순서대로 저장됩니다.

**Acceptance Criteria:**
- 캡처 시작 후 각 샷 전 countdown이 표시된다
- 총 샷 수는 선택한 프레임 타입과 일치한다
- 각 이미지 결과는 active session의 일부로 저장된다
- 촬영 도중 중단되면 세션은 restartable 상태로 남는다

### Item 3. Record making video during capture

**Why:** `사진 + 메이킹 영상`은 Phos의 핵심 차별점입니다. 사진만 남기면 경쟁 제품과 차이가 줄어듭니다.

**What:** Live Booth 촬영과 동시에 메이킹 영상을 기록합니다. 이 영상은 최종 strip과 다른 asset로 세션에 연결됩니다.

**Acceptance Criteria:**
- making video는 Live Booth 촬영과 함께 시작된다
- making video는 final photo strip과 분리된 asset로 저장된다
- video recording 실패 시에도 photo flow는 계속된다
- 영상 실패 시 사용자에게 명확한 안내가 표시된다

### Item 4. Review captured shots and set order

**Why:** 사용자는 최종 strip에 어떤 사진이 어떤 순서로 들어가는지 제어할 수 있어야 만족도가 올라갑니다. 이는 재촬영보다 가벼운 품질 보정 수단입니다.

**What:** 촬영 후 사용자는 모든 샷을 보고 strip slot 순서를 정합니다. 선택과 순서 정보는 이후 렌더링에 쓰일 세션 상태로 저장됩니다.

**Acceptance Criteria:**
- 촬영 후 사용자는 active session의 모든 샷을 볼 수 있다
- 사용자는 샷을 strip slot에 배치하고 순서를 바꿀 수 있다
- 선택과 순서는 render에 쓰이는 session state로 저장된다
- 사용자는 편집 없이 바로 render로 넘어갈 수 있다

### Item 5. Apply simple photo edits

**Why:** 너무 많은 편집은 흐름을 깨지만, 아무 편집도 없으면 결과물 만족도가 떨어질 수 있습니다. MVP는 빠른 완주를 해치지 않는 최소 편집만 제공해야 합니다.

**What:** 사용자는 촬영 후 선택한 샷에 preset filter, one text overlay, crop-to-frame만 적용할 수 있습니다. 편집은 선택 사항이며 결과는 render용 session state에 반영됩니다.

**Acceptance Criteria:**
- 사용자는 preset filter, one text overlay, crop-to-frame만 적용할 수 있다
- 각 편집 결과는 render에 쓰이는 session state를 갱신한다
- 편집은 optional이며 사용자는 바로 render로 넘어갈 수 있다
- advanced edit control은 MVP 범위에 포함되지 않는다

### Item 6. Render final photo strip

**Why:** 렌더링이 안정적으로 끝나야 사용자가 결과물을 확보할 수 있습니다. 이 항목은 KSR과 다운로드 성공의 전 단계입니다.

**What:** 현재 session의 선택 샷과 frame으로 final photo strip을 렌더링합니다. 실패 시에는 다시 시도할 수 있어야 합니다.

**Acceptance Criteria:**
- active session의 선택 샷과 frame으로 render를 시작할 수 있다
- render 성공 시 `render_succeeded`가 기록되고 final photo asset이 session에 저장된다
- render 실패 시 failure event가 기록되고 retry path가 제공된다
- render 결과는 이후 local save와 QR download에 연결된다

### Item 7. Expose QR download page

**Why:** 결과물을 빠르게 받고 공유하는 것은 핵심 가치입니다. QR 다운로드는 계정 없는 사용과 즉시 확보 흐름을 가능하게 합니다.

**What:** render 완료 후 session은 QR download page를 노출하고, 존재하는 asset(photo, video)에 대해 각각 download action을 제공합니다. 사용자는 계정 없이 이 페이지에 접근할 수 있습니다.

**Acceptance Criteria:**
- render 완료 후 QR download page를 노출할 수 있다
- page는 존재하는 asset(photo, video)에 대해 개별 download action을 제공한다
- QR page 접근 시 `qr_opened`가 기록된다
- QR flow는 account creation 없이 동작한다
- `shareLink.expiresAt`는 `retentionExpiresAt`를 넘지 않는다
- asset이 만료되었거나 unavailable이면 broken state 대신 명확한 안내를 표시한다

### Item 8. Save final assets locally

**Why:** 사용자는 QR을 다시 열지 않아도 결과물을 기기에 남기고 싶어 합니다. local save는 keepsake 확보 경험의 핵심입니다.

**What:** 최종 결과 화면에서 local save를 수행하고, 성공/실패를 알려줍니다. 저장 행동은 계측 가능해야 합니다.

**Acceptance Criteria:**
- 사용자는 final result flow에서 local save를 시작할 수 있다
- save 결과는 success 또는 failure로 사용자에게 표시된다
- 시스템은 `local_save_tapped`와 `local_save_succeeded`를 기록할 수 있다
- local save 실패가 session asset을 손상시키지 않는다

### Item 9. Separate service consent and data-use consent

**Why:** 프라이버시 신뢰는 제품 가치 자체입니다. 서비스 사용 동의와 데이터 활용 동의를 섞으면 신뢰와 이해도가 떨어집니다.

**What:** 서비스 이용에 필요한 동의와 optional data-use consent를 분리합니다. `trainingOptIn=false`를 기본값으로 유지합니다.

**Acceptance Criteria:**
- 앱은 service-use consent와 optional data-use consent를 분리해 보여준다
- 새 session에서 `trainingOptIn` 기본값은 `false`다
- consent state는 `consentVersion`과 함께 session에 저장된다
- required service consent 없이는 사용자가 다음 단계로 진행할 수 없다

### Item 10. Support delete and export requests

**Why:** 즉시 삭제/내보내기는 Phos의 privacy promise를 실제 행동으로 보여주는 기능입니다. 단순 안내가 아니라 동작 가능한 제어가 필요합니다.

**What:** 사용자는 retention window 안의 session에 대해 export 또는 deletion request를 보낼 수 있습니다. deletion이 확정되면 share link는 무효화됩니다.

**Acceptance Criteria:**
- 삭제되지 않은 session에 대해 export request를 만들 수 있다
- retention window 안의 session에 대해 deletion request를 만들 수 있다
- `exportRequest`는 deletion finalization 전에만 생성할 수 있다
- deletion confirmed 시 해당 session의 share links는 무효화된다

### Item 11a. Ship core session and render contract

**Why:** capture와 render 흐름이 하나의 작은 안정 계약 위에서 움직여야 작은 팀이 재작업 없이 MVP를 끝낼 수 있습니다.

**What:** PRD 범위 안에서 core MVP flow가 실제로 쓰는 session/frame 조회, session 갱신, `:render`, `:finalize`만 먼저 고정합니다.

**Acceptance Criteria:**
- API는 `POST /v1/sessions`, `GET /v1/sessions/{sessionId}`, `PATCH /v1/sessions/{sessionId}`를 제공한다
- API는 `GET /v1/frames`와 `GET /v1/frames/{frameId}`를 제공한다
- custom method는 `POST /v1/sessions/{sessionId}:render`, `POST /v1/sessions/{sessionId}:finalize`만 제공한다

### Item 11b. Ship session-scoped share and privacy resources

**Why:** download/privacy request는 필요한 범위만 별도 추적해야 작은 팀이 핵심 촬영 흐름과 병렬로 끝낼 수 있습니다.

**What:** PRD에 정의된 session-scoped `assets`, `consents`, `shareLinks`, `exportRequests`, `deletionRequests` paths만 제공합니다.

**Acceptance Criteria:**
- API는 `assets`, `consents`, `shareLinks`, `exportRequests`, `deletionRequests`의 session-scoped paths를 제공한다
- user-facing deletion은 direct session delete가 아니라 `DeletionRequest`로 처리한다

### Item 12. Enforce retention and privacy metadata

**Why:** 48시간 후 자동 삭제는 규칙이 아니라 제품 약속입니다. 이 약속이 시스템에서 강제되지 않으면 privacy positioning이 무너집니다.

**What:** 각 session에 48시간 retention을 부여하고, 만료 시 삭제 상태로 전환합니다. 응답과 로그에는 필요한 privacy metadata만 포함합니다.

**Acceptance Criteria:**
- 새 session마다 `retentionExpiresAt = createdAt + 48h`가 설정된다
- `shareLink.expiresAt`는 항상 `retentionExpiresAt` 이하이다
- 만료 시간이 지나면 session은 `deleted`로 전환되고 assets/share links는 더 이상 사용 불가다
- session 관련 응답은 relevant한 경우 `retentionExpiresAt`, `trainingUsed`, `consentVersion`, `deletionStatus`를 포함한다
- 로그는 `sessionId`, 시각, 액션, `consentVersion`, 상태 변화만 저장하고 raw asset URL이나 직접 PII는 저장하지 않는다
- `trainingUsed=true`는 해당 session의 유효한 `consentVersion` snapshot이 있을 때만 허용된다

### Item 13. Apply low-end media preset automatically

**Why:** 저사양 기기에서 실패하면 완주율과 신뢰가 함께 무너집니다. 사용자가 기술 옵션을 고르게 하지 않고도 안정성을 확보해야 합니다.

**What:** 기기 capability를 기준으로 default preset 또는 low-end preset을 자동 선택합니다. 이 preset은 multi-shot capture와 making video 모두에 적용됩니다.

**Acceptance Criteria:**
- capture 시작 전 app은 default 또는 low-end preset을 자동 선택한다
- low-end preset은 video resolution 또는 frame-processing load 중 하나 이상을 낮춘다
- 사용자는 manual technical setting을 고를 필요가 없다
- 선택된 preset은 session과 함께 분석용으로 저장된다

---

## 3) Soft-Launch Hardening Item (Step 3)

### Item 14. Recover unfinished session after short interruption

**Why:** soft launch에서는 작은 중단도 사용자 불만으로 이어집니다. 다만 이 항목은 V1 출시 게이트가 아니라 안정화 항목입니다.

**What:** `finalize` 이전의 짧은 background interruption 후 재진입 시, unfinished session recovery를 시도합니다. 실패하면 새 세션 시작을 안내합니다.

**Acceptance Criteria:**
- app이 짧게 backgrounded 된 뒤 재진입하면 unfinished session recovery를 시도할 수 있다
- recovery 성공 시 사용자는 unfinished state로 돌아간다
- recovery 실패 시 사용자는 새 session 시작 안내를 본다
- 이 항목은 soft-launch hardening으로 추적되고 V1 release gate는 아니다

---

## 4) Fast-Follow Item (Step 4)

### Item 15. Edit strip from existing photos

**Why:** 기존 사진 재활용은 장기 가치가 있지만, 첫 출시에서 핵심 완주 흐름보다 우선순위가 낮습니다. MVP를 가볍게 유지하기 위해 fast-follow로 둡니다.

**What:** 사용자가 기존 사진을 frame slot에 넣고 basic slot edit를 적용하는 Album Edit 흐름입니다. MVP 이후에 계획합니다.

**Acceptance Criteria:**
- 사용자는 기존 사진을 frame slot에 가져올 수 있다
- 사용자는 replace, crop, rotate 수준의 basic slot edit를 할 수 있다
- 이 항목은 MVP v1 release에 필수는 아니다
- core Live Booth, privacy, download flow 안정화 이후 계획한다

---

## 5) Delivery Guidance (Step 5)

- MVP 구현 순서는 `session/privacy contract -> capture -> render -> save/download -> retention enforcement` 흐름을 따른다
- Item 14는 soft launch 전 품질 여유가 생길 때 넣는다
- Item 15는 MVP release 이후 backlog로 남긴다
- design link는 아직 없으므로 모든 item에 `TBD`로 유지한다
