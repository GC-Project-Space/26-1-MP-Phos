# API Spec: Phos MVP v1

**Date**: 2026-03-20  
**Product**: Phos  
**Document Type**: API specification  
**Related Docs**: `docs/product/PRD-Phos.md`, `docs/product/USER-STORIES-Phos.md`, `docs/product/WWA-Backlog-Phos.md`  
**Scope**: MVP v1 API contract only

---

## 1) API Overview (Step 1)

이 문서는 `Phos` MVP v1의 API 계약을 정의합니다.  
원칙은 `session-centered`, `resource-oriented`, `standard methods first`, `custom only when needed` 입니다.

핵심 리소스:
- `Session`
- `Asset`
- `Frame`
- `Consent`
- `ShareLink`
- `ExportRequest`
- `DeletionRequest`

핵심 custom method:
- `POST /v1/sessions/{sessionId}:render`
- `POST /v1/sessions/{sessionId}:finalize`

---

## 2) Common Rules (Step 2)

### Identity and privacy
- 사용자는 계정 없이 `sessionId` 기반 익명 세션으로 시작할 수 있다
- 기본값은 `trainingOptIn=false`다
- 모든 session은 생성 시 `retentionExpiresAt = createdAt + 48h`를 가진다
- `shareLink.expiresAt <= retentionExpiresAt`를 항상 만족해야 한다
- `trainingUsed=true`는 유효한 `consentVersion` snapshot이 있을 때만 허용된다

### State transitions
- `session.status`: `active -> rendered -> finalized -> deleted`
- `session.deletionStatus`: `active -> export_requested -> delete_requested -> deleted`
- Only `POST /v1/sessions/{sessionId}:render`, `POST /v1/sessions/{sessionId}:finalize`, retention expiry, or deletion finalization may change `session.status`
- Only export/deletion request flows may change `deletionStatus`
- `shotCount` is derived from the selected frame's `slotCount`

### Response metadata
Relevant response에는 아래 privacy metadata를 포함할 수 있다.
- `retentionExpiresAt`
- `trainingUsed`
- `consentVersion`
- `deletionStatus`

### Errors
모든 endpoint는 최소한 아래 error shape를 지원한다.

```json
{
  "error": {
    "code": "ASSET_EXPIRED",
    "message": "Requested asset is no longer available.",
    "details": {
      "sessionId": "ses_123",
      "assetId": "ast_456"
    }
  }
}
```

권장 error codes:
- `INVALID_ARGUMENT`
- `NOT_FOUND`
- `FAILED_PRECONDITION`
- `ASSET_EXPIRED`
- `SESSION_FINALIZED`
- `CONSENT_REQUIRED`
- `EXPORT_NOT_ALLOWED`
- `DELETION_ALREADY_REQUESTED`

---

## 3) Resource Model (Step 3)

### Session

```json
{
  "sessionId": "ses_123",
  "mode": "LIVE_BOOTH",
  "status": "active",
  "selectedFrameId": "frm_4cut_basic",
  "selectedShotAssetIds": ["ast_shot_1", "ast_shot_2", "ast_shot_3", "ast_shot_4"],
  "editState": {
    "filterPreset": null,
    "textOverlay": null,
    "cropToFrame": false
  },
  "finalPhotoAssetId": "ast_final_photo",
  "makingVideoAssetId": "ast_making_video",
  "mediaPreset": "default",
  "retentionExpiresAt": "2026-03-22T12:00:00Z",
  "trainingUsed": false,
  "consentVersion": "v1",
  "deletionStatus": "active",
  "createdAt": "2026-03-20T12:00:00Z",
  "updatedAt": "2026-03-20T12:05:00Z"
}
```

### Asset

```json
{
  "assetId": "ast_123",
  "sessionId": "ses_123",
  "assetType": "photo",
  "assetRole": "raw_shot",
  "mimeType": "image/jpeg",
  "status": "available",
  "durationMs": null,
  "createdAt": "2026-03-20T12:01:00Z"
}
```

Allowed `assetType` values:
- `photo`
- `video`

Allowed `assetRole` values:
- `raw_shot`
- `final_photo`
- `making_video`

### Frame

```json
{
  "frameId": "frm_4cut_basic",
  "layoutType": "4_cut",
  "title": "Basic 4 Cut",
  "slotCount": 4,
  "isActive": true
}
```

### Consent

```json
{
  "consentId": "con_123",
  "sessionId": "ses_123",
  "serviceConsentAccepted": true,
  "trainingOptIn": false,
  "consentVersion": "v1",
  "createdAt": "2026-03-20T12:00:30Z"
}
```

### ShareLink

```json
{
  "shareLinkId": "shr_123",
  "sessionId": "ses_123",
  "status": "active",
  "url": "https://phos.app/s/shr_123",
  "expiresAt": "2026-03-21T12:00:00Z",
  "createdAt": "2026-03-20T12:06:00Z"
}
```

### ExportRequest

```json
{
  "exportRequestId": "exp_123",
  "sessionId": "ses_123",
  "status": "requested",
  "createdAt": "2026-03-20T12:07:00Z",
  "completedAt": null
}
```

### DeletionRequest

```json
{
  "requestId": "del_123",
  "sessionId": "ses_123",
  "status": "requested",
  "createdAt": "2026-03-20T12:08:00Z",
  "completedAt": null
}
```

---

## 4) Endpoints (Step 4)

### 4.1 Sessions

#### `POST /v1/sessions`
Create an anonymous session.

Request:
```json
{
  "mode": "LIVE_BOOTH"
}
```

Response `201`:
```json
{
  "session": {
    "sessionId": "ses_123",
    "mode": "LIVE_BOOTH",
    "status": "active",
    "retentionExpiresAt": "2026-03-22T12:00:00Z",
    "trainingUsed": false,
    "consentVersion": null,
    "deletionStatus": "active"
  }
}
```

#### `GET /v1/sessions/{sessionId}`
Get current session state.

#### `PATCH /v1/sessions/{sessionId}`
Update mutable session state used by MVP.

Allowed mutable fields:
- `selectedFrameId`
- `selectedShotAssetIds`
- `mediaPreset`
- `editState`

Request example:
```json
{
  "selectedFrameId": "frm_4cut_basic",
  "mediaPreset": "low_end",
  "editState": {
    "filterPreset": "warm",
    "textOverlay": "Tonight!",
    "cropToFrame": true
  }
}
```

#### `DELETE /v1/sessions/{sessionId}`
Internal lifecycle endpoint only. User-facing deletion must use `DeletionRequest`.

### 4.2 Frames

#### `GET /v1/frames`
List active frames.

Optional query params:
- `layoutType=4_cut|6_cut`
- `active=true`

#### `GET /v1/frames/{frameId}`
Get frame details.

### 4.3 Assets

#### `POST /v1/sessions/{sessionId}/assets`
Register a shot or video asset for the session.

Request example:
```json
{
  "assetType": "photo",
  "assetRole": "raw_shot",
  "mimeType": "image/jpeg"
}
```

#### `GET /v1/sessions/{sessionId}/assets`
List all assets for a session.

Optional query params:
- `assetType=photo|video`
- `assetRole=raw_shot|final_photo|making_video`

#### `GET /v1/sessions/{sessionId}/assets/{assetId}`
Get single asset metadata.

### 4.4 Consents

#### `POST /v1/sessions/{sessionId}/consents`
Create or update consent snapshot for the session.

Request example:
```json
{
  "serviceConsentAccepted": true,
  "trainingOptIn": false,
  "consentVersion": "v1"
}
```

#### `GET /v1/sessions/{sessionId}/consents`
List consent snapshots for audit/debug.

#### `GET /v1/sessions/{sessionId}/consents/{consentId}`
Get single consent snapshot.

### 4.5 Share links

#### `POST /v1/sessions/{sessionId}/shareLinks`
Create share link for rendered outputs.

Request example:
```json
{
  "expiresAt": "2026-03-21T12:00:00Z"
}
```

Validation:
- reject if `expiresAt > retentionExpiresAt`
- reject if session is `deleted`
- reject if no rendered asset exists

Response `201`:
```json
{
  "shareLink": {
    "shareLinkId": "shr_123",
    "sessionId": "ses_123",
    "status": "active",
    "url": "https://phos.app/s/shr_123",
    "expiresAt": "2026-03-21T12:00:00Z"
  }
}
```

#### `GET /v1/sessions/{sessionId}/shareLinks`
List share links.

#### `GET /v1/sessions/{sessionId}/shareLinks/{shareLinkId}`
Get share link metadata.

### 4.6 Export requests

#### `POST /v1/sessions/{sessionId}/exportRequests`
Create export request.

Validation:
- reject if current time > `retentionExpiresAt`
- reject if `deletionStatus = deleted`

#### `GET /v1/sessions/{sessionId}/exportRequests`
List export requests.

#### `GET /v1/sessions/{sessionId}/exportRequests/{exportRequestId}`
Get export request status.

### 4.7 Deletion requests

#### `POST /v1/sessions/{sessionId}/deletionRequests`
Create deletion request.

Validation:
- reject if current time > `retentionExpiresAt`
- reject if `deletionStatus = deleted`
- when deletion becomes `completed` or `retentionExpiresAt` passes, set `session.status = deleted`, `deletionStatus = deleted`, invalidate all share links, and make assets unavailable

#### `GET /v1/sessions/{sessionId}/deletionRequests`
List deletion requests.

#### `GET /v1/sessions/{sessionId}/deletionRequests/{requestId}`
Get deletion request status.

### 4.8 Custom methods

#### `POST /v1/sessions/{sessionId}:render`
Render final photo strip from current session state.

Request example:
```json
{
  "selectedShotAssetIds": ["ast_1", "ast_2", "ast_3", "ast_4"]
}
```

Response example:
```json
{
  "sessionId": "ses_123",
  "renderStatus": "succeeded",
  "finalPhotoAssetId": "ast_final_photo"
}
```

#### `POST /v1/sessions/{sessionId}:finalize`
Mark session immutable for delivery flow.

Validation:
- require final photo asset
- allow making video missing, but keep session finalizable with warning state

---

## 5) Endpoint-to-WWA Mapping (Step 5)

| WWA Item | API Surface |
|---|---|
| Item 1 Start session and ready camera | `POST /v1/sessions`, `GET /v1/frames`, `PATCH /v1/sessions/{sessionId}` |
| Item 2 Countdown multi-shot capture | `POST /v1/sessions/{sessionId}/assets`, `GET /v1/sessions/{sessionId}` |
| Item 3 Making video recording | `POST /v1/sessions/{sessionId}/assets` |
| Item 4 Review captured shots and set order | `PATCH /v1/sessions/{sessionId}` |
| Item 5 Apply simple photo edits | `PATCH /v1/sessions/{sessionId}` |
| Item 6 Render final photo strip | `POST /v1/sessions/{sessionId}:render` |
| Item 7 Expose QR download page | `POST /v1/sessions/{sessionId}/shareLinks`, `GET /v1/sessions/{sessionId}/shareLinks/{shareLinkId}` |
| Item 8 Save final assets locally | no new endpoint required; depends on session/asset metadata |
| Item 9 Separate service consent and data-use consent | `POST /v1/sessions/{sessionId}/consents` |
| Item 10 Support delete and export requests | `POST /v1/sessions/{sessionId}/exportRequests`, `POST /v1/sessions/{sessionId}/deletionRequests` |
| Item 11a/11b API contracts | all above |
| Item 12 Retention and metadata | all session/share/export/delete responses |
| Item 13 Low-end preset | `PATCH /v1/sessions/{sessionId}` |

---

## 6) Non-Goals for MVP (Step 6)

- No authenticated user accounts
- No public album listing API
- No Album Edit API for existing photo upload flow
- No advanced edit resources beyond session patch state
