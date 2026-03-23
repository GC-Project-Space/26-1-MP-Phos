# 이벤트 스키마: Phos MVP v1

- **Status**: Review
- **Owner**: @luke
- **Last Updated**: 2026-03-23
- **문서 역할**: MVP 분석·운영·프라이버시 이벤트와 WWA/테스트 추적성을 정의하는 문서
- **Upstream**: [API-SPEC-Phos.md](./API-SPEC-Phos.md), [PRD-Phos.md](./PRD-Phos.md), [WWA-Backlog-Phos.md](./WWA-Backlog-Phos.md)
- **Downstream**: [TEST-SCENARIOS-Phos.md](./TEST-SCENARIOS-Phos.md), 지표 대시보드, 운영 모니터링
- **Traceability Prefix**: `EVENT-xx`
- **범위**: MVP v1 분석 및 운영 이벤트

---

## 1) 이벤트 개요 (1단계)

이 문서는 `Phos` MVP에서 기록해야 하는 앱, 웹, 프라이버시, 운영 이벤트를 정의합니다.  
목표는 세 가지입니다.

- KSR와 핵심 퍼널 측정
- 실패 지점 파악
- 프라이버시/보관 감사 가능성 확보

## 2) 공통 이벤트 속성 (2단계)

모든 관련 이벤트는 가능한 범위에서 아래 공통 속성을 가진다.

| 속성                 | 타입      | 메모                                     |
| -------------------- | --------- | ---------------------------------------- |
| `eventId`            | string    | 선택적 고유 ID                           |
| `eventName`          | string    | 표준 이벤트 이름                         |
| `occurredAt`         | timestamp | UTC                                      |
| `sessionId`          | string    | MVP에서는 필수                           |
| `deviceTier`         | string    | `default`, `low_end`                     |
| `networkType`        | string    | `wifi`, `cellular`, `offline`, `unknown` |
| `elapsedMs`          | integer   | 이전 이정표 기준 선택적 소요 시간        |
| `errorCode`          | string    | 실패 이벤트에만 사용                     |
| `retentionExpiresAt` | timestamp | 프라이버시 메타데이터                    |
| `trainingUsed`       | boolean   | 프라이버시 메타데이터                    |
| `consentVersion`     | string    | 프라이버시 메타데이터                    |
| `deletionStatus`     | string    | 프라이버시 메타데이터                    |

## 3) 앱 이벤트 (3단계)

| 이벤트                      | 트리거                                | 필수 속성                                     | 매핑 대상             |
| --------------------------- | ------------------------------------- | --------------------------------------------- | --------------------- |
| `session_started`           | Live Booth 흐름 시작                  | `sessionId`                                   | `WWA-01`              |
| `camera_ready`              | 카메라가 사용 가능한 상태가 됨        | `sessionId`, `elapsedMs`                      | `WWA-01`, KSR 입력    |
| `camera_prepare_failed`     | 카메라가 사용 가능한 상태가 되지 못함 | `sessionId`, `errorCode`                      | `WWA-01`              |
| `frame_selected`            | 사용자가 프레임을 확정                | `sessionId`, `frameId`, `shotCount`           | `WWA-01`              |
| `capture_countdown_started` | 카운트다운 시작                       | `sessionId`, `shotIndex`                      | `WWA-02`              |
| `capture_completed`         | 계획된 모든 컷 촬영 완료              | `sessionId`, `shotCount`                      | `WWA-02`, KSR 입력    |
| `capture_interrupted`       | 촬영이 중간에 멈춤                    | `sessionId`, `shotIndex`, `errorCode`         | `WWA-02`              |
| `making_video_started`      | 메이킹 영상 기록 시작                 | `sessionId`                                   | `WWA-03`              |
| `making_video_failed`       | 메이킹 영상 기록 실패                 | `sessionId`, `errorCode`                      | `WWA-03`              |
| `shot_order_updated`        | 사용자가 스트립 슬롯 순서를 변경      | `sessionId`                                   | `WWA-04`              |
| `simple_edit_applied`       | 사용자가 필터/텍스트/크롭 적용        | `sessionId`, `editType`                       | `WWA-05`              |
| `render_started`            | 렌더 시작                             | `sessionId`                                   | `WWA-06`              |
| `render_succeeded`          | 렌더 완료                             | `sessionId`, `elapsedMs`, `finalPhotoAssetId` | `WWA-06`, KSR 입력    |
| `render_failed`             | 렌더 실패                             | `sessionId`, `errorCode`                      | `WWA-06`              |
| `result_view_opened`        | 사용자가 결과 화면을 열었음           | `sessionId`                                   | `WWA-07`, KSR 입력    |
| `local_save_tapped`         | 사용자가 로컬 저장 시작               | `sessionId`, `assetType`                      | `WWA-08`, KSR 입력    |
| `local_save_succeeded`      | 로컬 저장 성공                        | `sessionId`, `assetType`                      | `WWA-08`, KSR 입력    |
| `local_save_failed`         | 로컬 저장 실패                        | `sessionId`, `assetType`, `errorCode`         | `WWA-08`              |
| `media_preset_selected`     | 앱이 기본 또는 저사양 프리셋 선택     | `sessionId`, `mediaPreset`, `deviceTier`      | `WWA-14`              |
| `app_backgrounded`          | 활성 세션 중 앱이 백그라운드로 전환됨 | `sessionId`                                   | `WWA-15`, 소프트 런치 |
| `session_restored`          | 미완료 세션 복구                      | `sessionId`                                   | `WWA-15`, 소프트 런치 |

## 4) 결과 접근 이벤트 (4단계)

| 이벤트                              | 트리거                        | 필수 속성                | 매핑 대상                     |
| ----------------------------------- | ----------------------------- | ------------------------ | ----------------------------- |
| `asset_access_after_expiry_blocked` | 보관 만료 이후 자산 접근 차단 | `sessionId`, `assetType` | `WWA-07`, 프라이버시 가드레일 |

## 5) 동의 및 프라이버시 이벤트 (5단계)

| 이벤트                   | 트리거                            | 필수 속성                                      | 매핑 대상          |
| ------------------------ | --------------------------------- | ---------------------------------------------- | ------------------ |
| `consent_updated`        | 서비스 또는 데이터 활용 동의 저장 | `sessionId`, `consentVersion`, `trainingOptIn` | `WWA-09`           |
| `export_requested`       | 내보내기 요청 생성                | `sessionId`                                    | `WWA-10`           |
| `export_completed`       | 내보내기 요청 완료                | `sessionId`, `elapsedMs`                       | `WWA-10`           |
| `deletion_requested`     | 삭제 요청 생성                    | `sessionId`                                    | `WWA-10`           |
| `deletion_completed`     | 삭제 확정 완료                    | `sessionId`, `elapsedMs`                       | `WWA-10`, `WWA-13` |
| `retention_expired`      | 보관 만료 시점 도달               | `sessionId`, `retentionExpiresAt`              | `WWA-13`           |
| `training_usage_blocked` | 동의 스냅샷 없어서 학습 활용 차단 | `sessionId`, `consentVersion`                  | `WWA-13`           |

## 6) 파생 지표 매핑 (6단계)

| 지표                     | 공식                                                         | 필요한 이벤트                                                 |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------- |
| `KSR`                    | 2분 안에 최소 1개 자산을 확보한 sessions / `session_started` | `session_started`, `render_succeeded`, `local_save_succeeded` |
| Time-to-camera <=2s      | 2000 ms 이내 `camera_ready` / `session_started`              | `session_started`, `camera_ready`                             |
| Capture completion rate  | `capture_completed` / `session_started`                      | `session_started`, `capture_completed`                        |
| Render ready <=10s rate  | 10초 이내 render_succeeded / capture_completed               | `capture_completed`, `render_succeeded`                       |
| Result access start rate | local_save_tapped 또는 result_view_opened / render_succeeded | `render_succeeded`, `local_save_tapped`, `result_view_opened` |
| 결과 저장 완료 비율      | save success / result access started                         | `local_save_succeeded`                                        |

## 7) 이벤트-대-WWA 매핑 (7단계)

| WWA 항목 | 이벤트                                                                             |
| -------- | ---------------------------------------------------------------------------------- |
| `WWA-01` | `session_started`, `camera_ready`, `camera_prepare_failed`, `frame_selected`       |
| `WWA-02` | `capture_countdown_started`, `capture_completed`, `capture_interrupted`            |
| `WWA-03` | `making_video_started`, `making_video_failed`                                      |
| `WWA-04` | `shot_order_updated`                                                               |
| `WWA-05` | `simple_edit_applied`                                                              |
| `WWA-06` | `render_started`, `render_succeeded`, `render_failed`                              |
| `WWA-07` | `result_view_opened`, `asset_access_after_expiry_blocked`                          |
| `WWA-08` | `local_save_tapped`, `local_save_succeeded`, `local_save_failed`                   |
| `WWA-09` | `consent_updated`                                                                  |
| `WWA-10` | `export_requested`, `export_completed`, `deletion_requested`, `deletion_completed` |
| `WWA-13` | `retention_expired`, `training_usage_blocked`                                      |
| `WWA-14` | `media_preset_selected`                                                            |
| `WWA-15` | `app_backgrounded`, `session_restored`                                             |

## 8) MVP 비목표 (8단계)

- 사용자 계정 수준 식별 그래프 없음
- 소셜 공유 목적지 추적 없음
- 후속 우선순위용 Album Edit 이벤트 세트 없음
