# Event Schema: Phos MVP v1

**Date**: 2026-03-20  
**Product**: Phos  
**Document Type**: Event schema  
**Related Docs**: `docs/product/API-SPEC-Phos.md`, `docs/product/PRD-Phos.md`, `docs/product/WWA-Backlog-Phos.md`, `docs/discovery/phos-metrics-dashboard.md`  
**Scope**: MVP v1 analytics and operational events

---

## 1) Event Overview (Step 1)

이 문서는 `Phos` MVP에서 기록해야 하는 앱, 웹, privacy, 운영 이벤트를 정의합니다.  
목표는 세 가지입니다.
- KSR와 핵심 퍼널 측정
- 실패 지점 파악
- privacy/retention 감사 가능성 확보

---

## 2) Common Event Properties (Step 2)

모든 relevant event는 가능한 범위에서 아래 공통 속성을 가진다.

| Property | Type | Notes |
|---|---|---|
| `eventId` | string | optional unique id |
| `eventName` | string | canonical event name |
| `occurredAt` | timestamp | UTC |
| `sessionId` | string | required for MVP |
| `deviceTier` | string | `default`, `low_end` |
| `networkType` | string | `wifi`, `cellular`, `offline`, `unknown` |
| `elapsedMs` | integer | optional duration from previous milestone |
| `errorCode` | string | only for failure events |
| `retentionExpiresAt` | timestamp | privacy metadata |
| `trainingUsed` | boolean | privacy metadata |
| `consentVersion` | string | privacy metadata |
| `deletionStatus` | string | privacy metadata |

---

## 3) App Events (Step 3)

| Event | Trigger | Required Properties | Maps To |
|---|---|---|---|
| `session_started` | Live Booth flow begins | `sessionId` | WWA Item 1 |
| `camera_ready` | camera becomes usable | `sessionId`, `elapsedMs` | WWA Item 1, KSR input |
| `camera_prepare_failed` | camera cannot become usable | `sessionId`, `errorCode` | WWA Item 1 |
| `frame_selected` | user confirms frame | `sessionId`, `frameId`, `shotCount` | WWA Item 1 |
| `capture_countdown_started` | countdown begins | `sessionId`, `shotIndex` | WWA Item 2 |
| `capture_completed` | all planned shots captured | `sessionId`, `shotCount` | WWA Item 2, KSR input |
| `capture_interrupted` | capture stops early | `sessionId`, `shotIndex`, `errorCode` | WWA Item 2 |
| `making_video_started` | making video begins | `sessionId` | WWA Item 3 |
| `making_video_failed` | making video cannot complete | `sessionId`, `errorCode` | WWA Item 3 |
| `shot_order_updated` | user changes slot order | `sessionId` | WWA Item 4 |
| `simple_edit_applied` | user applies filter/text/crop | `sessionId`, `editType` | WWA Item 5 |
| `render_started` | render begins | `sessionId` | WWA Item 6 |
| `render_succeeded` | render completes | `sessionId`, `elapsedMs`, `finalPhotoAssetId` | WWA Item 6, KSR input |
| `render_failed` | render fails | `sessionId`, `errorCode` | WWA Item 6 |
| `local_save_tapped` | user starts local save | `sessionId`, `assetType` | WWA Item 8, KSR input |
| `local_save_succeeded` | local save succeeds | `sessionId`, `assetType` | WWA Item 8, KSR input |
| `local_save_failed` | local save fails | `sessionId`, `assetType`, `errorCode` | WWA Item 8 |
| `media_preset_selected` | app picks default or low-end preset | `sessionId`, `mediaPreset`, `deviceTier` | WWA Item 13 |
| `app_backgrounded` | app goes background during active session | `sessionId` | soft-launch |
| `session_restored` | unfinished session is restored | `sessionId` | soft-launch |

---

## 4) Share and Download Events (Step 4)

| Event | Trigger | Required Properties | Maps To |
|---|---|---|---|
| `share_link_created` | QR share link created | `sessionId`, `shareLinkId`, `expiresAt` | WWA Item 7 |
| `qr_opened` | QR page opened | `sessionId`, `shareLinkId` | WWA Item 7, KSR input |
| `photo_download_started` | photo download initiated | `sessionId`, `shareLinkId` | WWA Item 7 |
| `photo_download_succeeded` | photo download succeeded | `sessionId`, `shareLinkId`, `elapsedMs` | WWA Item 7, KSR input |
| `photo_download_failed` | photo download failed | `sessionId`, `shareLinkId`, `errorCode` | WWA Item 7 |
| `video_download_started` | video download initiated | `sessionId`, `shareLinkId` | WWA Item 7 |
| `video_download_succeeded` | video download succeeded | `sessionId`, `shareLinkId`, `elapsedMs` | WWA Item 7, KSR input |
| `video_download_failed` | video download failed | `sessionId`, `shareLinkId`, `errorCode` | WWA Item 7 |
| `asset_access_after_expiry_blocked` | expired asset access blocked | `sessionId`, `shareLinkId`, `assetType` | WWA Item 7, privacy guardrail |

---

## 5) Consent and Privacy Events (Step 5)

| Event | Trigger | Required Properties | Maps To |
|---|---|---|---|
| `consent_updated` | service or data-use consent captured | `sessionId`, `consentVersion`, `trainingOptIn` | WWA Item 9 |
| `export_requested` | export request created | `sessionId` | WWA Item 10 |
| `export_completed` | export request completed | `sessionId`, `elapsedMs` | WWA Item 10 |
| `deletion_requested` | deletion request created | `sessionId` | WWA Item 10 |
| `deletion_completed` | deletion finalization completed | `sessionId`, `elapsedMs` | WWA Item 10/12 |
| `retention_expired` | retention deadline reached | `sessionId`, `retentionExpiresAt` | WWA Item 12 |
| `training_usage_blocked` | system prevents training use without consent snapshot | `sessionId`, `consentVersion` | WWA Item 12 |

---

## 6) Derived Metrics Mapping (Step 6)

| Metric | Formula | Required Events |
|---|---|---|
| `KSR` | sessions that secure at least one asset within 2 minutes / sessions_started | `session_started`, `render_succeeded`, `local_save_succeeded` or `photo_download_succeeded` or `video_download_succeeded` |
| Time-to-camera <=2s | camera_ready within 2000 ms / sessions_started | `session_started`, `camera_ready` |
| Capture completion rate | capture_completed / sessions_started | `session_started`, `capture_completed` |
| Render ready <=10s rate | render_succeeded within 10s / capture_completed | `capture_completed`, `render_succeeded` |
| Result access start rate | local_save_tapped or qr_opened / render_succeeded | `render_succeeded`, `local_save_tapped`, `qr_opened` |
| Result save completion rate | save/download success / result access started | `local_save_succeeded`, `photo_download_succeeded`, `video_download_succeeded` |

---

## 7) Event-to-WWA Mapping (Step 7)

| WWA Item | Events |
|---|---|
| Item 1 | `session_started`, `camera_ready`, `camera_prepare_failed`, `frame_selected` |
| Item 2 | `capture_countdown_started`, `capture_completed`, `capture_interrupted` |
| Item 3 | `making_video_started`, `making_video_failed` |
| Item 4 | `shot_order_updated` |
| Item 5 | `simple_edit_applied` |
| Item 6 | `render_started`, `render_succeeded`, `render_failed` |
| Item 7 | `share_link_created`, `qr_opened`, download events, `asset_access_after_expiry_blocked` |
| Item 8 | `local_save_tapped`, `local_save_succeeded`, `local_save_failed` |
| Item 9 | `consent_updated` |
| Item 10 | `export_requested`, `export_completed`, `deletion_requested`, `deletion_completed` |
| Item 12 | `retention_expired`, `training_usage_blocked` |
| Item 13 | `media_preset_selected` |
| Item 14 | `app_backgrounded`, `session_restored` |

---

## 8) Non-Goals for MVP (Step 8)

- No user-level account identity graph
- No social share destination tracking
- No Album Edit event set for fast-follow
