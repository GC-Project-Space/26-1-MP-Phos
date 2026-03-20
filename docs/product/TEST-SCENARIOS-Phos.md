# Test Scenarios: Phos MVP v1

**Date**: 2026-03-20  
**Product**: Phos  
**Document Type**: QA test scenarios  
**Related Docs**: `docs/product/PRD-Phos.md`, `docs/product/USER-STORIES-Phos.md`, `docs/product/WWA-Backlog-Phos.md`, `docs/product/API-SPEC-Phos.md`, `docs/product/EVENT-SCHEMA-Phos.md`  
**Scope**: MVP v1, soft-launch hardening, fast-follow note

---

## 1) Test Plan Overview (Step 1)

이 문서는 `Phos` MVP의 QA 실행 시나리오입니다.  
목표는 happy path, failure path, privacy path를 모두 검증하는 것입니다.

테스트 우선순위:
- `P0`: 촬영, 렌더, 저장, 다운로드, privacy promise
- `P1`: 저사양 안정성, 중단 복구
- `P2`: fast-follow 준비 항목

---

## 2) MVP Test Scenarios (Step 2)

### Test Scenario 1. Start session and ready camera

**Test Objective:** Live Booth 시작 시 세션이 생성되고 카메라가 usable 상태가 되는지 검증한다.

**Starting Conditions:**
- 앱이 설치되어 있다
- 카메라 권한을 허용할 수 있다
- 네트워크 상태는 정상이다

**User Role:** 사용자

**Test Steps:**
1. 앱에서 Live Booth 진입 버튼을 누른다
2. 4컷 또는 6컷 프레임을 하나 선택한다
3. 카메라 화면이 usable 상태가 되는지 확인한다
4. 실패 시 retry 경로가 보이는지 확인한다

**Expected Outcomes:**
- 익명 session이 생성된다
- 선택한 frame이 session에 연결된다
- `session_started`, `camera_ready`가 기록된다
- 카메라 준비 실패 시 frozen state 대신 retry가 보인다

### Test Scenario 2. Complete countdown multi-shot capture

**Test Objective:** countdown 기반 촬영이 선택한 frame type에 맞춰 끝까지 완료되는지 검증한다.

**Starting Conditions:**
- active session이 존재한다
- frame이 선택되어 있다

**User Role:** 사용자

**Test Steps:**
1. 촬영 시작 버튼을 누른다
2. 각 shot 전 countdown을 확인한다
3. 계획된 모든 shot이 끝날 때까지 촬영을 진행한다
4. shot 목록이 review 단계로 넘어가는지 확인한다

**Expected Outcomes:**
- countdown이 각 shot 전에 표시된다
- shot 수는 frame type과 일치한다
- 각 shot은 active session asset으로 저장된다
- `capture_completed`가 기록된다

### Test Scenario 3. Continue photo flow when making video fails

**Test Objective:** making video recording 실패가 photo strip flow를 막지 않는지 검증한다.

**Starting Conditions:**
- active session이 있다
- video recording failure를 유도할 수 있는 테스트 환경이 있다

**User Role:** 사용자

**Test Steps:**
1. Live Booth 촬영을 시작한다
2. making video failure 조건을 발생시킨다
3. photo shot capture가 계속 가능한지 확인한다
4. 사용자 안내 문구를 확인한다

**Expected Outcomes:**
- video 실패 시에도 photo flow는 계속된다
- making video는 final photo와 분리된 asset 처리 규칙을 따른다
- `making_video_failed`가 기록된다
- 사용자는 명확한 안내를 본다

### Test Scenario 4. Review shots and reorder strip slots

**Test Objective:** 사용자가 촬영 후 샷을 보고 순서를 바꿀 수 있는지 검증한다.

**Starting Conditions:**
- capture가 완료된 session이 있다

**User Role:** 사용자

**Test Steps:**
1. review 화면에 진입한다
2. 각 shot이 모두 보이는지 확인한다
3. 샷의 slot 배치 순서를 바꾼다
4. render 단계로 이동한 뒤 반영 여부를 확인한다

**Expected Outcomes:**
- 모든 shot이 review 화면에 보인다
- 순서 변경이 가능하다
- 저장된 순서가 render state에 반영된다
- 편집 없이도 render로 진행 가능하다

### Test Scenario 5. Apply simple photo edits

**Test Objective:** MVP 범위의 빠른 편집만 적용되고, 실패 시 기존 선택 상태가 보존되는지 검증한다.

**Starting Conditions:**
- review 가능한 session이 있다

**User Role:** 사용자

**Test Steps:**
1. preset filter를 적용한다
2. one text overlay를 적용한다
3. crop-to-frame을 적용한다
4. edit 실패 상황을 유도해 기존 상태 보존 여부를 확인한다

**Expected Outcomes:**
- MVP 범위의 edit만 제공된다
- 각 edit는 render용 session state를 갱신한다
- edit는 optional이다
- 실패해도 captured shots와 shot order는 보존된다

### Test Scenario 6. Render final photo strip with retry

**Test Objective:** render 성공과 실패 재시도 흐름을 검증한다.

**Starting Conditions:**
- selected shots와 frame이 준비된 session이 있다

**User Role:** 사용자

**Test Steps:**
1. render를 시작한다
2. 성공 시 final photo asset 생성 여부를 확인한다
3. 실패 환경에서 render를 다시 시작한다
4. retry path가 보이는지 확인한다

**Expected Outcomes:**
- render 성공 시 final photo asset이 session에 저장된다
- `render_succeeded` 또는 failure event가 기록된다
- 실패 시 retry path가 보인다
- render 결과는 save/download flow에 연결된다

### Test Scenario 7. Download photo and video from QR page

**Test Objective:** account 없이 QR page에서 존재하는 asset을 개별 다운로드할 수 있는지 검증한다.

**Starting Conditions:**
- rendered session이 있다
- active share link가 있다

**User Role:** 사용자

**Test Steps:**
1. rendered session에서 share link를 생성한다
2. 반환된 `url`로 QR page를 연다
3. video asset이 존재하면 video download도 시도한다
4. asset expiry 또는 unavailable 상태에서 메시지를 확인한다

**Expected Outcomes:**
- `share_link_created`, `qr_opened`가 기록된다
- page는 존재하는 asset에 대해서만 개별 action을 제공한다
- account 없이 download가 가능하다
- expired/unavailable asset은 broken state 대신 명확한 안내를 보여준다

### Test Scenario 8. Save final assets locally

**Test Objective:** local save 시작, 성공, 실패 흐름과 event 기록을 검증한다.

**Starting Conditions:**
- final result 화면이 준비되어 있다

**User Role:** 사용자

**Test Steps:**
1. local save 버튼을 누른다
2. 성공 시 저장 완료 메시지를 확인한다
3. 실패 환경에서 다시 시도한다
4. session asset integrity를 확인한다

**Expected Outcomes:**
- `local_save_tapped`가 기록된다
- 성공 시 `local_save_succeeded`가 기록된다
- 실패 시 asset이 손상되지 않는다
- local save는 QR download와 독립적으로 동작한다

### Test Scenario 9. Separate service consent and data-use consent

**Test Objective:** required service consent와 optional data-use consent가 분리되어 동작하는지 검증한다.

**Starting Conditions:**
- 새로운 session을 시작할 수 있다

**User Role:** 사용자

**Test Steps:**
1. consent 화면을 연다
2. required service consent만 수락해 본다
3. optional data-use consent를 비활성 상태로 둔다
4. 다음 단계로 진행 가능한지 확인한다

**Expected Outcomes:**
- required consent와 optional consent가 분리되어 보인다
- `trainingOptIn` 기본값은 false다
- required consent 없이는 다음 단계로 갈 수 없다
- consent snapshot은 `consentVersion`과 함께 저장된다

### Test Scenario 10. Request export and deletion

**Test Objective:** export/deletion request가 retention rule과 lifecycle rule에 맞게 동작하는지 검증한다.

**Starting Conditions:**
- session이 아직 deleted가 아니다

**User Role:** 사용자

**Test Steps:**
1. export request를 생성한다
2. export status를 확인한다
3. deletion request를 생성한다
4. deletion confirmed 뒤 share link 상태를 확인한다

**Expected Outcomes:**
- export request는 deleted 이전에만 생성된다
- deletion request는 retention window 안에서만 생성된다
- deletion 완료 후 share links는 무효화된다
- `export_requested`, `export_completed`, `deletion_requested`, `deletion_completed`가 기록된다

### Test Scenario 11. Validate minimum session API contract

**Test Objective:** MVP에서 필요한 endpoint와 resource path가 문서 계약대로 존재하는지 검증한다.

**Starting Conditions:**
- API test environment가 준비되어 있다

**User Role:** QA / backend tester

**Test Steps:**
1. session create/get/patch endpoint를 호출한다
2. frame list/get endpoint를 호출한다
3. session-scoped resource path들을 확인한다
4. undocumented custom method가 없는지 확인한다

**Expected Outcomes:**
- sessions, frames, scoped resources가 문서 계약과 일치한다
- custom method는 `:render`, `:finalize`만 존재한다
- user-facing deletion은 `DeletionRequest` 경로를 사용한다

### Test Scenario 12. Enforce retention and privacy metadata

**Test Objective:** 48시간 retention, metadata inclusion, no-PII logging, consent invariant를 검증한다.

**Starting Conditions:**
- session 생성 및 expiry simulation이 가능하다

**User Role:** QA / privacy tester

**Test Steps:**
1. new session을 생성하고 `retentionExpiresAt`를 확인한다
2. share link expiry가 retention을 넘지 않는지 확인한다
3. expiry 이후 asset access를 시도한다
4. response metadata와 logs를 확인한다

**Expected Outcomes:**
- 모든 session은 `createdAt + 48h` retention을 가진다
- expiry 후 session은 deleted 상태가 된다
- relevant response는 privacy metadata를 포함한다
- logs는 raw asset URL이나 직접 PII를 저장하지 않는다
- `trainingUsed=true`는 유효한 consent snapshot이 있을 때만 허용된다

### Test Scenario 13. Apply low-end preset automatically

**Test Objective:** 저사양 기기에서 low-end preset이 자동 적용되어 capture/video flow가 유지되는지 검증한다.

**Starting Conditions:**
- low-end device 또는 equivalent simulation 환경이 있다

**User Role:** 사용자 / QA

**Test Steps:**
1. low-end device에서 Live Booth를 시작한다
2. preset 선택 결과를 확인한다
3. multi-shot capture를 진행한다
4. making video recording이 함께 동작하는지 확인한다

**Expected Outcomes:**
- app은 default 또는 low-end preset을 자동 선택한다
- low-end preset은 resolution 또는 processing load를 줄인다
- manual technical setting 없이 flow를 완료할 수 있다
- 선택된 preset은 session과 함께 저장된다

---

## 3) Soft-Launch Hardening Scenario (Step 3)

### Test Scenario 14. Recover unfinished session after short interruption

**Test Objective:** 짧은 interruption 후 unfinished session recovery가 안정적으로 동작하는지 검증한다.

**Starting Conditions:**
- `finalize` 전 active session이 있다

**User Role:** 사용자

**Test Steps:**
1. capture 또는 review 도중 앱을 background로 보낸다
2. 짧은 시간 안에 앱으로 돌아온다
3. recovery success/failure 경로를 각각 확인한다

**Expected Outcomes:**
- recovery 성공 시 unfinished state로 돌아간다
- recovery 실패 시 새 session 시작 안내를 본다
- finalized session은 corrupt 되지 않는다

---

## 4) Fast-Follow Scenario (Step 4)

### Test Scenario 15. Edit strip from existing photos

**Test Objective:** fast-follow Album Edit에서 기존 사진 import와 기본 slot edit가 가능한지 검증한다.

**Starting Conditions:**
- fast-follow build 또는 feature flag가 켜져 있다

**User Role:** 사용자

**Test Steps:**
1. 기존 사진을 frame slot에 가져온다
2. replace, crop, rotate를 적용한다
3. 저장 가능한 결과 상태를 확인한다

**Expected Outcomes:**
- 기존 사진 import가 가능하다
- basic slot edit가 동작한다
- 이 시나리오는 MVP release blocking 항목이 아니다
