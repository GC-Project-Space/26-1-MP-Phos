# API 명세: Phos MVP v1

- **Status**: Review
- **Owner**: @luke
- **Last Updated**: 2026-03-23
- **문서 역할**: 제품 흐름을 지원하는 MVP API 계약과 source-of-truth 규칙을 정의하는 문서
- **Upstream**: [PRD-Phos.md](./PRD-Phos.md), [UI-UX-REQUIREMENTS-Phos.md](./UI-UX-REQUIREMENTS-Phos.md), [USER-STORIES-Phos.md](./USER-STORIES-Phos.md), [WWA-Backlog-Phos.md](./WWA-Backlog-Phos.md)
- **Downstream**: [EVENT-SCHEMA-Phos.md](./EVENT-SCHEMA-Phos.md), [TEST-SCENARIOS-Phos.md](./TEST-SCENARIOS-Phos.md), 구현 API 레이어
- **Traceability Prefix**: `API-xx`
- **범위**: MVP v1 API 계약만 포함

---

## 1) API 개요 (1단계)

이 문서는 `Phos` MVP v1의 API 계약을 정의합니다.  
원칙은 `세션 중심`, `리소스 지향`, `표준 메서드 우선`, `필요할 때만 커스텀 메서드 사용`입니다.

핵심 리소스:

- `Session`
- `Asset`
- `Frame`
- `Consent`
- `ExportRequest`
- `DeletionRequest`

핵심 커스텀 메서드:

- `POST /v1/sessions/{sessionId}:render`
- `POST /v1/sessions/{sessionId}:finalize`

---

## 2) 공통 규칙 (2단계)

### 식별과 프라이버시

- 사용자는 계정 없이 `sessionId` 기반 익명 세션으로 시작할 수 있다
- 기본값은 `trainingOptIn=false`다
- 모든 session은 생성 시 `retentionExpiresAt = createdAt + 48h`를 가진다
- `trainingUsed=true`는 유효한 `consentVersion` 스냅샷이 있을 때만 허용된다

### 상태 전이

- `session.status`: `active -> rendered -> finalized -> deleted`
- `session.deletionStatus`: `active -> export_requested -> deletion_requested -> deleted`
- `session.status`는 `POST /v1/sessions/{sessionId}:render`, `POST /v1/sessions/{sessionId}:finalize`, 보관 만료, 삭제 확정만 변경할 수 있다
- `deletionStatus`는 내보내기/삭제 요청 흐름에서만 변경할 수 있다
- `shotCount`는 선택한 프레임의 `slotCount`에서 파생된다

### 데이터 권한(Source of Truth) 및 충돌 처리

| 영역             | Source of Truth                                                             | 보조 데이터                    | API 처리 규칙                                                                          |
| ---------------- | --------------------------------------------------------------------------- | ------------------------------ | -------------------------------------------------------------------------------------- |
| 선택 컷/순서     | `SessionShotSelection(sessionId, assetId, position)`                        | `Session.selectedShotAssetIds` | 렌더/조회는 관계형 선택 기준으로 동작하며, 불일치 시 정합성 오류를 반환하거나 보정한다 |
| 최종 산출물 식별 | `Session.finalPhotoAssetId`, `Session.makingVideoAssetId`                   | `Asset.assetRole`              | 사용자 노출은 세션 참조를 기준으로 하며, 역할 분류는 검증용 메타데이터로 취급한다      |
| 동의 버전        | `Consent.consentVersion` (최신 스냅샷)                                      | `Session.consentVersion`       | 정책 판단은 동의 스냅샷 기준으로 수행하고 세션 스냅샷은 프로젝션으로 동기화한다        |
| 삭제 워크플로    | `DeletionRequest.status`                                                    | `Session.deletionStatus`       | 삭제 워커는 요청 상태를 기준으로 세션 상태를 투영하며, 지연 시 재동기화한다            |
| 보관 만료 정책   | `retentionExpiresAt`                                                        | 없음                           | 보관 만료 이후 결과물 접근 요청은 거부한다                                             |
| 편집 상태        | 정규 필드(`selectedShotAssetIds`, `finalPhotoAssetId`, `deletionStatus` 등) | `Session.editState`            | `editState`는 편집 전용 허용 키만 받으며 도메인 정답 필드를 덮어쓰지 못한다            |

충돌 처리 원칙:

- 불일치 감지 시 `FAILED_PRECONDITION`을 우선 사용한다.
- 읽기 API는 Source of Truth 기준 상태만 노출한다.
- 비동기 워커 경합으로 인한 일시 불일치는 재동기화 잡으로 수렴시킨다.

### 응답 메타데이터

관련 응답에는 아래 프라이버시 메타데이터가 포함될 수 있다.

- `retentionExpiresAt`
- `trainingUsed`
- `consentVersion`
- `deletionStatus`

### 오류

모든 엔드포인트는 최소한 아래 오류 응답 형태를 지원한다.

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

권장 오류 코드:

- `INVALID_ARGUMENT`
- `NOT_FOUND`
- `FAILED_PRECONDITION`
- `ASSET_EXPIRED`
- `SESSION_FINALIZED`
- `CONSENT_REQUIRED`
- `EXPORT_NOT_ALLOWED`
- `DELETION_ALREADY_REQUESTED`

---

## 3) 리소스 모델 (3단계)

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

허용되는 `assetType` 값:

- `photo`
- `video`

허용되는 `assetRole` 값:

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

## 4) 엔드포인트 (4단계)

### 4.1 Sessions

#### `POST /v1/sessions`

익명 세션을 생성한다.

요청:

```json
{
  "mode": "LIVE_BOOTH"
}
```

응답 `201`:

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

현재 세션 상태를 조회한다.

#### `PATCH /v1/sessions/{sessionId}`

MVP에서 사용하는 변경 가능한 세션 상태를 갱신한다.

허용되는 변경 필드:

- `selectedFrameId`
- `selectedShotAssetIds`
- `mediaPreset`
- `editState`

요청 예시:

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

내부 생명주기 전용 엔드포인트다. 사용자용 삭제는 반드시 `DeletionRequest`를 사용해야 한다.

### 4.2 Frames

#### `GET /v1/frames`

활성 프레임 목록을 조회한다.

선택 쿼리 파라미터:

- `layoutType=4_cut|6_cut`
- `active=true`

#### `GET /v1/frames/{frameId}`

프레임 상세를 조회한다.

### 4.3 Assets

#### `POST /v1/sessions/{sessionId}/assets`

세션의 컷 이미지 또는 영상 자산을 등록한다.

요청 예시:

```json
{
  "assetType": "photo",
  "assetRole": "raw_shot",
  "mimeType": "image/jpeg"
}
```

#### `GET /v1/sessions/{sessionId}/assets`

세션의 전체 자산을 조회한다.

선택 쿼리 파라미터:

- `assetType=photo|video`
- `assetRole=raw_shot|final_photo|making_video`

#### `GET /v1/sessions/{sessionId}/assets/{assetId}`

단일 자산 메타데이터를 조회한다.

### 4.4 Consents

#### `POST /v1/sessions/{sessionId}/consents`

세션의 동의 스냅샷을 생성하거나 갱신한다.

요청 예시:

```json
{
  "serviceConsentAccepted": true,
  "trainingOptIn": false,
  "consentVersion": "v1"
}
```

#### `GET /v1/sessions/{sessionId}/consents`

감사/디버그용 동의 스냅샷 목록을 조회한다.

#### `GET /v1/sessions/{sessionId}/consents/{consentId}`

단일 동의 스냅샷을 조회한다.

### 4.5 내보내기 요청

#### `POST /v1/sessions/{sessionId}/exportRequests`

내보내기 요청을 생성한다.

검증:

- 현재 시간이 `retentionExpiresAt`를 넘으면 거부한다
- `deletionStatus = deleted`이면 거부한다

#### `GET /v1/sessions/{sessionId}/exportRequests`

내보내기 요청 목록을 조회한다.

#### `GET /v1/sessions/{sessionId}/exportRequests/{exportRequestId}`

내보내기 요청 상태를 조회한다.

### 4.6 삭제 요청

#### `POST /v1/sessions/{sessionId}/deletionRequests`

삭제 요청을 생성한다.

검증:

- 현재 시간이 `retentionExpiresAt`를 넘으면 거부한다
- `deletionStatus = deleted`이면 거부한다
- 삭제가 `completed`가 되거나 `retentionExpiresAt`가 지나면 `session.status = deleted`, `deletionStatus = deleted`로 바꾸고, 자산을 사용 불가 상태로 만든다

#### `GET /v1/sessions/{sessionId}/deletionRequests`

삭제 요청 목록을 조회한다.

#### `GET /v1/sessions/{sessionId}/deletionRequests/{requestId}`

삭제 요청 상태를 조회한다.

### 4.7 커스텀 메서드

#### `POST /v1/sessions/{sessionId}:render`

현재 세션 상태에서 최종 포토 스트립을 렌더링한다.

요청 예시:

```json
{
  "selectedShotAssetIds": ["ast_1", "ast_2", "ast_3", "ast_4"]
}
```

응답 예시:

```json
{
  "sessionId": "ses_123",
  "renderStatus": "succeeded",
  "finalPhotoAssetId": "ast_final_photo"
}
```

#### `POST /v1/sessions/{sessionId}:finalize`

전달 흐름을 위해 세션을 변경 불가 상태로 표시한다.

검증:

- 최종 포토 스트립 자산이 필요하다
- 메이킹 영상이 없어도 경고 상태와 함께 세션 `finalize`는 허용한다

---

## 5) 엔드포인트-대-WWA 매핑 (5단계)

| WWA 항목 | API 표면                                                                                                                                                                                                              |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `WWA-01` | `POST /v1/sessions`, `GET /v1/frames`, `PATCH /v1/sessions/{sessionId}`                                                                                                                                               |
| `WWA-02` | `POST /v1/sessions/{sessionId}/assets`, `GET /v1/sessions/{sessionId}`                                                                                                                                                |
| `WWA-03` | `POST /v1/sessions/{sessionId}/assets`                                                                                                                                                                                |
| `WWA-04` | `PATCH /v1/sessions/{sessionId}`                                                                                                                                                                                      |
| `WWA-05` | `PATCH /v1/sessions/{sessionId}`                                                                                                                                                                                      |
| `WWA-06` | `POST /v1/sessions/{sessionId}:render`                                                                                                                                                                                |
| `WWA-07` | 새 엔드포인트는 필요 없음; 세션/자산 메타데이터에 의존                                                                                                                                                                |
| `WWA-08` | 새 엔드포인트는 필요 없음; 세션/자산 메타데이터에 의존                                                                                                                                                                |
| `WWA-09` | `POST /v1/sessions/{sessionId}/consents`                                                                                                                                                                              |
| `WWA-10` | `POST /v1/sessions/{sessionId}/exportRequests`, `POST /v1/sessions/{sessionId}/deletionRequests`                                                                                                                      |
| `WWA-11` | `POST /v1/sessions`, `GET /v1/sessions/{sessionId}`, `PATCH /v1/sessions/{sessionId}`, `GET /v1/frames`, `GET /v1/frames/{frameId}`, `POST /v1/sessions/{sessionId}:render`, `POST /v1/sessions/{sessionId}:finalize` |
| `WWA-12` | `GET /v1/sessions/{sessionId}/assets`, `POST /v1/sessions/{sessionId}/consents`, `POST /v1/sessions/{sessionId}/exportRequests`, `POST /v1/sessions/{sessionId}/deletionRequests`                                     |
| `WWA-13` | 모든 세션/내보내기/삭제 응답                                                                                                                                                                                          |
| `WWA-14` | `PATCH /v1/sessions/{sessionId}`                                                                                                                                                                                      |

---

## 6) MVP 비목표 (6단계)

- 인증된 사용자 계정 없음
- 공개 앨범 목록 API 없음
- 기존 사진 업로드 흐름용 Album Edit API 없음
- 세션 패치 상태를 넘는 고급 편집 리소스 없음
