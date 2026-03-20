# Metrics Dashboard: Pho's (모바일 인생네컷)

**Date**: 2026-03-20  
**Scope**: 제품 전체 (MVP v1: Live Booth + 메이킹 영상 + QR 사진/영상 다운로드 + Privacy 플로우)  
**Stage**: Pre-launch -> Recently launched 전환 구간  
**Primary Goal**: `재미 중심 경험`을 2분 내 완주하고 결과물을 저장/공유하게 만드는 것

---

## 1) What We Are Measuring (Step 1)

- **Product/Feature Area**: Live Booth 촬영, 렌더링, QR 다운로드, 개인정보 제어(동의/삭제/내보내기)
- **Current Business Goals / OKRs (derived)**:
  - 첫 세션 완주율 >= 70%
  - 공유 전환율 >= 35%
  - 다운로드 성공률 >= 97%
  - 세션 실패율 < 3%
- **Current State**: 지표 정의는 있으나 계측 체계/대시보드/임계치 운영은 미정
- **Analytics Stack (proposed)**:
  - Product analytics: PostHog or Amplitude
  - Warehouse/BI: BigQuery + Metabase (or Looker)
  - Operational alerts: Grafana/Datadog + Slack/PagerDuty

---

## 2) Metrics Framework (Step 2)

## North Star

**North Star**: 2-Minute Keepsake Secured Rate (KSR)

**Definition**:
```text
KSR = (# sessions where user completes capture -> render and secures at least 1 final asset within 2 minutes)
      / (# sessions_started)

"secure" = local_save_succeeded OR photo_download_succeeded OR video_download_succeeded
Window: daily, rolling 7-day view for trend
```

**Why this North Star**
- 사용자 가치(결과물을 내 손에 확보)와 제품 목표(재미+완주)를 직접 반영
- QR 같은 전달 채널에 과도하게 종속되지 않아 운영 안정성이 높음
- 퍼널 단계별 레버가 명확해 팀별 액션으로 연결 가능

**Target (pre-launch heuristic -> calibrated)**
- Soft launch Week 2: >= 30%
- Launch D+30: >= 45%
- Launch D+90: >= 55%

### Input Metrics (Levers)

| Metric | Definition | Owner | Target | Current |
|---|---|---|---|---|
| Time-to-Camera <=2s Rate | `# sessions with camera_ready_time <=2s / # sessions_started` | Client | >= 80% | TBD |
| Capture Completion Rate | `# sessions_capture_completed / # sessions_started` | Client | >= 85% | TBD |
| Render Ready <=10s Rate | `# sessions where render_succeeded and render_elapsed_ms <=10000 / # sessions_capture_completed` | Media/Backend | >= 90% | TBD |
| Result Access Start Rate | `# sessions with local_save_tapped or qr_opened / # sessions_render_succeeded` | Product | >= 80% | TBD |
| Result Save Completion Rate | `# sessions with local_save_succeeded or successful_download / # sessions_with_result_access_started` | Backend/Web | >= 95% | TBD |

### Health Metrics (Guardrails)

| Metric | Healthy Range | Yellow Threshold | Red Threshold |
|---|---|---|---|
| Session Crash Rate | < 2.0% | 2.0% to <4.0% | >= 4.0% |
| Video Recording Failure Rate | < 3.0% | 3.0% to <5.0% | >= 5.0% |
| Render P95 Latency | < 6.0s | 6.0s to <8.0s | >= 8.0s |
| Result Save Error Rate | < 3.0% | 3.0% to <5.0% | >= 5.0% |
| Deletion SLA Met Rate (<=15m) | >= 99% | 95% to <99% | < 95% |
| Export SLA Met Rate (<=15m) | >= 95% | 90% to <95% | < 90% |
| Expired Asset Access Rate | 0% | >0% to <0.1% | >= 0.1% |

### Counter-Metrics (Goodhart 방지)

| Metric | Why It Matters | Watch For |
|---|---|---|
| Median Time-to-Keepsake | NSM 상승을 위해 사용자를 오래 붙잡는 왜곡 방지 | KSR 상승 + 중앙 완료시간 악화 |
| Both-Asset Availability Rate | 사진만 살리고 메이킹 영상 가치를 희생하는 왜곡 방지 | KSR 유지/상승 + photo/video 동시 확보율 하락 |
| Invalid Training Usage Rate | 동의 없는 학습 활용 방지 | `trainingUsed=true`인데 유효 동의 스냅샷 없음 |

### Business Metrics (for PM/Leadership)

| Metric | Definition | Cadence |
|---|---|---|
| Weekly Active Creators | 주간 기준 1회 이상 세션 완주 사용자 수 | Weekly |
| Share-to-Invite Rate | 공유 링크 노출 대비 신규 유입 발생 비율 | Weekly |
| Cost per Completed Session | 인프라 비용 / 완주 세션 수 | Weekly |

---

## 3) Alert Thresholds (Step 3)

| Metric | Green | Yellow | Red | Check Frequency |
|---|---|---|---|---|
| KSR (North Star) | >= 45% | 35% to <45% | < 35% | Daily |
| Time-to-Camera <=2s Rate | >= 80% | 70% to <80% | < 70% | Hourly + Daily |
| Capture Completion Rate | >= 85% | 75% to <85% | < 75% | Daily |
| Render Ready <=10s Rate | >= 90% | 80% to <90% | < 80% | Hourly + Daily |
| Result Access Start Rate | >= 80% | 70% to <80% | < 70% | Daily |
| Result Save Completion Rate | >= 95% | 90% to <95% | < 90% | Hourly + Daily |
| Session Crash Rate | < 2.0% | 2.0% to <4.0% | >= 4.0% | Hourly |
| Deletion SLA Met Rate | >= 99% | 95% to <99% | < 95% | Daily |
| Export SLA Met Rate | >= 95% | 90% to <95% | < 90% | Daily |
| Expired Asset Access Rate | 0% | >0% to <0.1% | >= 0.1% | Hourly + Daily |

**Calibration rule (pre-launch -> early launch)**
- If denominator < 50 sessions/day, funnel metrics stay `Calibrating` instead of green/yellow/red.
- If delete/export requests < 20 in the last 7 days, privacy SLA metrics stay `Calibrating`.
- Funnel metrics use rolling 7-day averages until traffic stabilizes.
- Hourly alerts are only for crash rate, render latency, and privacy breach metrics.
- Any `Expired Asset Access Rate > 0` or invalid `trainingUsed=true` without consent snapshot is immediate Red.

**Escalation Policy**
- Yellow: 제품/개발 온콜 채널에 알림, 24시간 내 원인분석
- Red: 즉시 PagerDuty, 2시간 내 완화조치/롤백 여부 결정

---

## 4) Dashboard Spec (Step 4)

**North Star**: 2-Minute Keepsake Secured Rate (KSR)  
**Definition**: capture -> render -> secure(로컬저장 or 사진/영상 다운로드) within 2 minutes / sessions_started  
**Current Value**: TBD (런칭 후 캘리브레이션)  
**Target**: W2 30%, D+30 45%, D+90 55%

### Input Metrics
| Metric | Definition | Owner | Target | Current |
|---|---|---|---|---|
| Time-to-Camera <=2s Rate | camera_ready_time <=2s 비율 | Client | >= 80% | TBD |
| Capture Completion Rate | 촬영 완료 비율 | Client | >= 85% | TBD |
| Render Ready <=10s Rate | 렌더 성공 + 10초 이내 완료 비율 | Media/Backend | >= 90% | TBD |
| Result Access Start Rate | 로컬저장 또는 QR 열람 시작 비율 | Product | >= 80% | TBD |
| Result Save Completion Rate | 로컬저장 또는 다운로드 성공 비율 | Backend/Web | >= 95% | TBD |

### Health Metrics
| Metric | Healthy Range | Yellow Threshold | Red Threshold |
|---|---|---|---|
| Session Crash Rate | < 2.0% | 2.0% to <4.0% | >= 4.0% |
| Video Recording Failure Rate | < 3.0% | 3.0% to <5.0% | >= 5.0% |
| Render P95 Latency | < 6.0s | 6.0s to <8.0s | >= 8.0s |
| Result Save Error Rate | < 3.0% | 3.0% to <5.0% | >= 5.0% |
| Deletion SLA Met Rate (<=15m) | >= 99% | 95% to <99% | < 95% |
| Export SLA Met Rate (<=15m) | >= 95% | 90% to <95% | < 90% |
| Expired Asset Access Rate | 0% | >0% to <0.1% | >= 0.1% |

### Counter-Metrics
| Metric | Why It Matters | Watch For |
|---|---|---|
| Median Time-to-Keepsake | 억지 체류 증가 방지 | KSR↑ + 소요시간 악화 |
| Both-Asset Availability Rate | 사진만 최적화하는 왜곡 방지 | photo/video 동시 확보율 하락 |
| Invalid Training Usage Rate | 동의 없는 학습 활용 방지 | trainingUsed=true with invalid consent |

### Metrics Tree
```text
North Star: 2-Minute Keepsake Secured Rate
├── Input: Time-to-Camera <=2s Rate -> driven by camera init/perf work
├── Input: Capture Completion Rate -> driven by UX flow and stability
├── Input: Render Ready <=10s Rate -> driven by render pipeline reliability
├── Input: Result Access Start Rate -> driven by save/share UX clarity
├── Input: Result Save Completion Rate -> driven by app/web reliability
└── Counter: Time-to-Keepsake / Both-Asset Availability / Invalid Training Usage
```

### Implementation Notes
- **Data sources**:
  - App event log: `session_started`, `camera_ready`, `capture_completed`, `render_succeeded`, `app_backgrounded`, `session_restored`
  - App event log (save): `local_save_tapped`, `local_save_succeeded`, `local_save_failed`
  - Share web log: `qr_opened`, `photo_download_started/succeeded/failed`, `video_download_started/succeeded/failed`, `asset_access_after_expiry_blocked`
  - Privacy log: `consent_updated`, `export_requested/completed`, `deletion_requested/completed`
- **Required properties**:
  - `sessionId`, `deviceTier`, `networkType`, `elapsedMs`, `errorCode`
  - Privacy 메타: `retentionExpiresAt`, `trainingUsed`, `consentVersion`, `deletionStatus`
- **Refresh frequency**:
  - Operational health: 5~15분
  - Product funnel: hourly
  - Leadership dashboard: daily snapshot
- **Tool recommendation**:
  - Product funnel/cohort: PostHog/Amplitude
  - SQL dashboard: BigQuery + Metabase
  - Alerting: Datadog/Grafana + Slack + PagerDuty

### Review Cadence
- **Daily**: North Star + crash/download/privacy health 지표 확인
- **Weekly**: Input 지표 드라이버 리뷰 + 실험 결과 공유
- **Monthly**: North Star vs 목표 갭 분석, 팀별 액션 재할당
- **Quarterly**: 지표 프레임워크 재검토(지표 폐기/추가)

---

## 5) Launch Calibration Plan (Pre-launch 필수)

런칭 전에는 임계치가 heuristic이므로 아래 순서로 보정합니다.

1. **Week 0**: 이벤트 스키마 고정 + QA 시뮬레이션 데이터로 수집 검증
2. **Week 1**: Soft launch 데이터로 baseline 산출 (P50/P95, 실패 코드 Top 5)
3. **Week 2**: Green/Yellow/Red 임계치 1차 조정
4. **Week 4**: NSM/Input 상관관계 검증 후 North Star 목표 재설정

---

## 6) External Benchmark Notes (validated vs heuristic)

| Metric Area | Baseline Type | Reference Range | How We Use It |
|---|---|---|---|
| Mobile retention (D1/D7/D30) | Validated industry baseline | Social/consumer 앱은 초기 리텐션 분산이 큼 | 절대 목표로 고정하지 않고 soft-launch baseline 비교에 사용 |
| Crash-free sessions | Validated reliability baseline | 상위 모바일 앱은 99%+ crash-free 지향 | 우리 지표는 `Session Crash Rate`로 역변환해 운영 알림에 사용 |
| DAU/MAU stickiness | Validated framework baseline | 카테고리별 편차 큼 (social > utility) | Pho's는 이벤트형 사용이라 과도 목표 설정 금지 |
| Share/Viral coefficient | Mixed (validated + heuristic) | 앱/루프 구조 따라 편차 큼 | Early stage에는 참고만, 핵심 운영지표는 아님 |
| Time-to-value thresholds | Heuristic (team-defined) | 제품 플로우 특화 기준 필요 | `2-minute` 경험 목표를 NSM과 퍼널에 반영 |

주의사항:
- 런치 초기(표본 작음)에는 benchmark 절대치보다 `추세`와 `이상징후 탐지`를 우선
- 공개 벤치마크 수치는 카테고리/국가/채널 편향이 있어 직접 목표치로 쓰지 않음

---

## 7) Open Items

- analytics 툴 확정(PostHog vs Amplitude)
- 익명 사용자 식별 정책(session 기준 vs install 기준)
- 공유 링크 만료 기본값(예: 24h)과 48h retention 정책 정합성
