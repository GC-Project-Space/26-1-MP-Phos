# User Stories: Phos MVP v1

**Date**: 2026-03-20  
**Product**: Phos  
**Source Docs**: `docs/product/PRD-Phos.md`, `docs/discovery/phos-discovery-plan.md`, `docs/discovery/phos-metrics-dashboard.md`  
**Design**: TBD  
**Scope**: MVP v1 only (Fast-follow stories are separated at the end)

---

## 1) Story Set Overview (Step 1)

이 문서는 `Phos` MVP v1 구현을 위한 user stories 모음입니다.  
각 story는 한 스프린트 안에 끝낼 수 있는 크기로 나누었고, acceptance criteria는 테스트 가능한 문장으로 적었습니다.

주요 역할:
- 사용자(촬영/저장/공유)
- 운영 관점의 시스템(렌더/삭제/내보내기)

---

## 2) MVP User Stories (Step 2)

### Story 1. Start Session, Select Frame, and Ready Camera

**Description:** As a user, I want to start a session, choose a frame, and get to a ready camera quickly, so that I can begin shooting with minimal friction.

**Design:** TBD

**Acceptance Criteria:**
1. Starting Live Booth creates an anonymous session and records `session_started`.
2. Before capture, the user can choose at least one 4-cut and one 6-cut frame.
3. The selected frame is saved to the active session before the camera becomes usable.
4. After frame selection, the camera becomes usable and the app records `camera_ready`.
5. If camera preparation fails, the user sees a retry action and the saved frame remains attached to the session.

### Story 2. Countdown Multi-Shot Capture

**Description:** As a user, I want the app to guide me through countdown-based multi-shot capture, so that I can complete a photo strip easily.

**Design:** TBD

**Acceptance Criteria:**
1. After capture starts, the app runs a countdown before each shot.
2. The total shot count follows the selected frame type.
3. Each captured image is stored as part of the active session.
4. If capture is interrupted before completion, the system keeps the session in a recoverable or restartable state.
5. The user can clearly tell which shot they are currently taking.

### Story 3. Making Video Recording During Capture

**Description:** As a user, I want the app to record a making video while I take booth photos, so that I get a second keepsake from the same moment.

**Design:** TBD

**Acceptance Criteria:**
1. Making video recording starts together with the Live Booth capture flow.
2. The making video is stored as a separate asset from the final photo strip.
3. If video recording fails, the app still allows the photo flow to continue.
4. The user is informed when the making video cannot be completed.
5. The system can later link the making video to the same session as the final photo.

### Story 4. Shot Review and Order

**Description:** As a user, I want to review captured shots and set their order, so that I control the final strip before rendering.

**Design:** TBD

**Acceptance Criteria:**
1. After capture, the user sees every shot stored in the active session.
2. The user can assign shots to strip slots and reorder them before rendering.
3. The selected order is saved to the session state used for rendering.
4. The user can proceed to render without using any edit tools.
5. If the user leaves and returns before render, the last saved selection and order are restored.

### Story 5. Simple Photo Edit

**Description:** As a user, I want a small set of quick edits, so that I can improve the strip without slowing down the flow.

**Design:** TBD

**Acceptance Criteria:**
1. The user can apply only the MVP edit actions: preset filter, one text overlay, and crop-to-frame.
2. Each edit updates the session state used for rendering.
3. Editing is optional and the user can skip directly to render.
4. Advanced editing controls are not included.
5. If an edit fails, the captured shots and saved order remain intact.

### Story 6. Final Photo Strip Render

**Description:** As a user, I want the app to generate my final photo strip from the selected shots and frame, so that I get a complete keepsake.

**Design:** TBD

**Acceptance Criteria:**
1. The system can trigger a render for the active session using the selected shots and chosen frame.
2. The rendered output is saved as a final photo asset tied to the session.
3. If rendering fails, the user sees a retry option.
4. The render flow is measurable through a `render_succeeded` or failure event.
5. The rendered result is available for local save and QR download after success.

### Story 7. QR Download Page for Photo and Video

**Description:** As a user, I want a QR page where I can download my final photo and making video separately, so that I can keep or share each result easily.

**Design:** TBD

**Acceptance Criteria:**
1. After rendering is complete, the session can expose a QR download page.
2. The QR page shows separate download actions for photo and video when both assets exist.
3. The QR flow works without requiring account creation.
4. The system records `qr_opened` when the QR page is accessed.
5. Share link expiration never exceeds `retentionExpiresAt`.
6. If an asset is expired or unavailable, the page shows a clear message instead of a broken state.

### Story 8. Local Save of Final Assets

**Description:** As a user, I want to save my final result to my device, so that I can keep it even without reopening the share page.

**Design:** TBD

**Acceptance Criteria:**
1. The user can start local save from the final result flow.
2. The app confirms success or failure after the save attempt.
3. The system records `local_save_tapped` and `local_save_succeeded` when applicable.
4. A local save failure does not delete or corrupt the session assets.
5. The save action works independently from QR download.

### Story 9. Privacy Consent Separation

**Description:** As a user, I want service consent and data-use consent to be separate, so that I understand what is required and what is optional.

**Design:** TBD

**Acceptance Criteria:**
1. The app shows service-use consent separately from optional data-use consent.
2. `trainingOptIn` defaults to `false` for a new session.
3. The system stores the consent state with `consentVersion` for the session.
4. The user can proceed only when required service consent is accepted.
5. Optional data-use consent is not pre-selected.

### Story 10. Delete and Export Requests

**Description:** As a user, I want to request deletion or export of my session data, so that I stay in control of my content.

**Design:** TBD

**Acceptance Criteria:**
1. The user can trigger an export request for a session that is not yet deleted.
2. The user can trigger a deletion request for a session that is still within its retention window.
3. `exportRequest` can be created only before deletion is finalized.
4. A deletion request invalidates the session's share links when deletion is confirmed.
5. The session exposes `deletionStatus` so the system can show the current state.
6. The system records `export_requested`, `export_completed`, `deletion_requested`, and `deletion_completed` as applicable.

### Story 11. MVP Session API Contract

**Description:** As a backend engineer, I want the minimum session-based API contract for capture, render, share, and privacy requests, so that client flows can ship against one stable MVP contract.

**Design:** TBD

**Acceptance Criteria:**
1. The API provides `POST /v1/sessions`, `GET /v1/sessions/{sessionId}`, and `PATCH /v1/sessions/{sessionId}`.
2. The API provides `GET /v1/frames` and `GET /v1/frames/{frameId}`.
3. The API provides session-scoped resource paths for `assets`, `consents`, `shareLinks`, `exportRequests`, and `deletionRequests` exactly as defined in the PRD.
4. The only custom methods are `POST /v1/sessions/{sessionId}:render` and `POST /v1/sessions/{sessionId}:finalize`.
5. User-facing deletion is requested through `DeletionRequest`; the MVP client flow does not rely on direct session deletion.

### Story 12. Retention Enforcement and Privacy Metadata

**Description:** As a system operator, I want each session to expire and delete automatically after 48 hours, so that Phos keeps its privacy promise without manual work.

**Design:** TBD

**Acceptance Criteria:**
1. Each new session is assigned `retentionExpiresAt = createdAt + 48h`.
2. `shareLink.expiresAt` is never later than `retentionExpiresAt`.
3. When `retentionExpiresAt` passes, the session transitions to `deleted`, assets are no longer downloadable, and all share links are invalidated.
4. Session-related responses include `retentionExpiresAt`, `trainingUsed`, `consentVersion`, and `deletionStatus` where relevant.
5. Logs store `sessionId`, timestamp, action, `consentVersion`, and state changes, and do not store raw asset URLs or direct PII.

### Story 13. Low-End Media Preset in Live Booth

**Description:** As a user on a low-end device, I want the app to switch to a lower media preset automatically, so that photo capture and making-video recording finish reliably.

**Design:** TBD

**Acceptance Criteria:**
1. Before capture begins, the app selects either a default preset or a low-end preset based on a device capability check.
2. The low-end preset reduces at least one of video resolution or frame-processing load for the session.
3. The user does not need to choose technical settings manually.
4. The selected preset is stored with the session for analysis.
5. The preset is applied to both multi-shot capture and making-video recording.

---

## 3) Soft-Launch Hardening Story (Step 3)

### Story 14. Session Recovery After Short Interruption

**Description:** As a user, I want the app to recover my unfinished session after a short interruption, so that I do not have to restart from zero.

**Design:** TBD

**Acceptance Criteria:**
1. If the app is backgrounded briefly before `finalize`, it can attempt session recovery on re-entry.
2. If recovery succeeds, the user returns to the unfinished session state.
3. If recovery fails, the app explains that the user must start a new session.
4. This recovery flow is tracked as a soft-launch hardening item and not as a V1 release gate.
5. Recovery behavior does not corrupt already rendered or finalized sessions.

---

## 4) Fast-Follow Story (Step 4)

### Story 15. Album Edit for Existing Photos

**Description:** As a user, I want to place my existing photos into a Phos frame, so that I can create a strip even when I did not use Live Booth.

**Design:** TBD

**Acceptance Criteria:**
1. The user can import an existing photo into a frame slot.
2. The user can do basic slot edits such as replace, crop, or rotate.
3. This story is not required for MVP v1 release.
4. The feature can be planned after the core Live Booth, privacy, and download flows are stable.

---

## 5) Story Dependencies (Step 5)

- Stories 1, 2, and 3 are the capture foundation for Stories 4, 5, 6, 7, and 8.
- Story 6 depends on Stories 1, 2, 4, and optionally 5.
- Story 7 depends on Story 6 and backend share-link support from Story 11.
- Story 8 depends on Story 6.
- Stories 9, 10, and 12 depend on the privacy and session model from Story 11.
- Story 13 should ship together with Stories 2 and 3 as a stability layer.
- Story 14 is soft-launch hardening and should not block V1 feature completion.
- Story 15 is fast-follow and should stay out of MVP sprint commitments.

---

## 6) Suggested Delivery Order (Step 6)

### Sprint 1 candidates
- Story 1. Start Session, Select Frame, and Ready Camera
- Story 2. Countdown Multi-Shot Capture
- Story 11. MVP Session API Contract

### Sprint 2 candidates
- Story 3. Making Video Recording During Capture
- Story 4. Shot Review and Order
- Story 5. Simple Photo Edit
- Story 6. Final Photo Strip Render
- Story 13. Low-End Media Preset in Live Booth

### Sprint 3 candidates
- Story 7. QR Download Page for Photo and Video
- Story 8. Local Save of Final Assets
- Story 9. Privacy Consent Separation
- Story 12. Retention Enforcement and Privacy Metadata

### Sprint 4 candidates
- Story 10. Delete and Export Requests
- Story 14. Session Recovery After Short Interruption

### After MVP
- Story 15. Album Edit for Existing Photos
