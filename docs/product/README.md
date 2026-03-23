# 제품 문서 인덱스 및 관리 규약: Phos

- **Status**: Review
- **Owner**: @luke
- **Last Updated**: 2026-03-23
- **문서 역할**: `docs/product` 스위트의 공식 인덱스이자 문서 관리 규약
- **Upstream**: 디스커버리 계획, 제품 전략 결정
- **Downstream**: `docs/product` 전체 문서 세트
- **Traceability Prefix**: `DOC-xx` (인덱스/규약 문서용 보조 접두사)

이 문서는 `docs/product` 스위트의 제품 문서를 관리하는 공식 규약이자 인덱스입니다. 모든 제품 문서는 이 규약을 따릅니다.

## 1. 제품 문서 인덱스 (Reading Order)

1. [`PRD-Phos.md`](./PRD-Phos.md): 제품 목표, MVP 범위, 핵심 사용자 흐름 정의
2. [`UI-UX-REQUIREMENTS-Phos.md`](./UI-UX-REQUIREMENTS-Phos.md): 화면 흐름 및 UX 상세 요구사항
3. [`DESIGN-SYSTEM-Phos.md`](./DESIGN-SYSTEM-Phos.md): 시각 원칙, 토큰, 상호작용 규칙
4. [`COMPONENT-DESCRIPTIONS-Phos.md`](./COMPONENT-DESCRIPTIONS-Phos.md): 컴포넌트 역할, 상태, 데이터 의존성
5. [`USER-STORIES-Phos.md`](./USER-STORIES-Phos.md): 구현 가능한 사용자 스토리 단위 정의
6. [`WWA-Backlog-Phos.md`](./WWA-Backlog-Phos.md): Why-What-Acceptance 형식의 백로그
7. [`API-SPEC-Phos.md`](./API-SPEC-Phos.md): API 리소스 및 메서드 계약
8. [`EVENT-SCHEMA-Phos.md`](./EVENT-SCHEMA-Phos.md): 제품, 운영, 프라이버시 이벤트 정의
9. [`TEST-SCENARIOS-Phos.md`](./TEST-SCENARIOS-Phos.md): QA 시나리오 및 데이터 직교성 검증

## 2. 업데이트 순서 (Update Order)

문서 사이의 정합성을 유지하기 위해 다음 순서로 업데이트합니다. 상위 문서가 바뀌면 하위 문서도 반드시 검토하고 고쳐야 합니다.

1. [`PRD-Phos.md`](./PRD-Phos.md): 모든 변경의 시작점 (Source of Truth)
2. [`UI-UX-REQUIREMENTS-Phos.md`](./UI-UX-REQUIREMENTS-Phos.md): 화면이나 흐름이 바뀔 때
3. [`DESIGN-SYSTEM-Phos.md`](./DESIGN-SYSTEM-Phos.md), [`API-SPEC-Phos.md`](./API-SPEC-Phos.md): 시각 요소나 인터페이스가 바뀔 때 (동시 업데이트 가능)
4. [`COMPONENT-DESCRIPTIONS-Phos.md`](./COMPONENT-DESCRIPTIONS-Phos.md): 구현 구조가 바뀔 때
5. [`USER-STORIES-Phos.md`](./USER-STORIES-Phos.md): 요구사항을 구현 단위로 나눌 때
6. [`WWA-Backlog-Phos.md`](./WWA-Backlog-Phos.md): 작업 단위와 인수 기준을 확정할 때
7. [`TEST-SCENARIOS-Phos.md`](./TEST-SCENARIOS-Phos.md), [`EVENT-SCHEMA-Phos.md`](./EVENT-SCHEMA-Phos.md): 최종 검증 기준과 이벤트 계약을 맞출 때

## 3. 핵심 문서 계약 (역할 / 입력 / 출력 / 연결)

| 문서                                                                 | 문서 역할                                               | 주요 입력                 | 주요 출력                         | Upstream            | Downstream               | Traceability Prefix |
| :------------------------------------------------------------------- | :------------------------------------------------------ | :------------------------ | :-------------------------------- | :------------------ | :----------------------- | :------------------ |
| [`PRD-Phos.md`](./PRD-Phos.md)                                       | 제품 목표, MVP 범위, 비목표를 정의하는 기준 문서        | 디스커버리, 비즈니스 목표 | 핵심 기능, 범위, 출시 기준        | 디스커버리 문서     | UX / API / US / WWA / TS | `PRD-xx`            |
| [`UI-UX-REQUIREMENTS-Phos.md`](./UI-UX-REQUIREMENTS-Phos.md)         | 화면 흐름, 상태, 카피, 접근성 기준의 권한 문서          | PRD                       | 사용자 흐름, 상태 정의, UX 규칙   | PRD                 | DS / COMP / US / TS      | `UX-xx`             |
| [`DESIGN-SYSTEM-Phos.md`](./DESIGN-SYSTEM-Phos.md)                   | UX 요구사항을 시각 규칙과 토큰으로 해석하는 문서        | UX 요구사항, 코드 기준점  | UI 토큰, 레이아웃, 상호작용 규칙  | UX                  | COMP                     | `DS-xx`             |
| [`COMPONENT-DESCRIPTIONS-Phos.md`](./COMPONENT-DESCRIPTIONS-Phos.md) | 화면/컴포넌트 책임, 상태, 데이터 의존성을 정의하는 문서 | UX, DS                    | 컴포넌트 명세, 책임 경계, 상태 맵 | UX / DS             | US                       | `COMP-xx`           |
| [`USER-STORIES-Phos.md`](./USER-STORIES-Phos.md)                     | 구현 가능한 사용자 가치 단위로 요구사항을 분해하는 문서 | PRD, UX, COMP             | 스토리, 인수 기준                 | PRD / UX / COMP     | WWA / TS                 | `US-xx`             |
| [`WWA-Backlog-Phos.md`](./WWA-Backlog-Phos.md)                       | 작업 순서와 인수 기준을 backlog 단위로 고정하는 문서    | USER-STORIES              | Why / What / Acceptance backlog   | US                  | TS                       | `WWA-xx`            |
| [`API-SPEC-Phos.md`](./API-SPEC-Phos.md)                             | 제품 흐름을 지원하는 API 계약 문서                      | PRD, UX                   | 리소스/메서드 계약                | PRD / UX            | EVENT / TS               | `API-xx`            |
| [`TEST-SCENARIOS-Phos.md`](./TEST-SCENARIOS-Phos.md)                 | 제품 요구사항을 검증 가능한 시나리오로 바꾸는 문서      | UX, US, WWA, API          | 테스트 시나리오, SoT 검증         | UX / US / WWA / API | 구현 검증                | `TS-xx`             |

보조 문서:

- [`EVENT-SCHEMA-Phos.md`](./EVENT-SCHEMA-Phos.md): 제품/운영/프라이버시 이벤트 정의 (`EVENT-xx` 권장)
- [`API-SPEC-Phos.md`](./API-SPEC-Phos.md)와 [`EVENT-SCHEMA-Phos.md`](./EVENT-SCHEMA-Phos.md)는 핵심 체인을 지원하는 계약 문서이므로, PRD/UX 변경 시 함께 검토합니다.

## 4. 추적성 ID 규칙 (Traceability ID)

문서 사이의 요구사항을 추적하기 위해 접두사와 2자리 숫자를 합친 ID를 사용합니다. (예: `PRD-01`)

- **PRD**: `PRD-xx`
- **UX**: `UX-xx`
- **DS**: `DS-xx`
- **COMP**: `COMP-xx`
- **US**: `US-xx`
- **WWA**: `WWA-xx`
- **API**: `API-xx`
- **EVENT**: `EVENT-xx`
- **TS**: `TS-xx`

한 문서에서 새 항목을 추가할 때는 같은 접두사 안에서 번호를 건너뛰지 않습니다.

## 5. 공통 인라인 메타데이터 규칙

YAML Frontmatter는 사용하지 않습니다. 문서 맨 위에 헤딩이나 불렛으로 메타데이터를 적습니다.

**예시:**

```markdown
# 문서 제목

- **Status**: Draft / Review / Approved
- **Owner**: @username
- **Last Updated**: 2026-03-23
- **문서 역할**: 이 문서가 authoritative 한 범위
- **Upstream**: 참조해야 하는 상위 문서와 ID
- **Downstream**: 이 문서를 참조해야 하는 하위 문서
- **Traceability Prefix**: `PRD-xx` 같은 문서별 접두사
```

문서별 메타데이터는 이 순서를 기본으로 유지합니다.

## 6. 플레이스홀더 정책

내용이 정해지지 않았을 때 이유 없는 약식 placeholder를 적지 않습니다. 반드시 이유를 포함해서 `Pending: <이유>` 형식을 사용합니다.

- **나쁜 예**: `비고: 미정`
- **좋은 예**: `비고: Pending: API 설계 확정 후 업데이트 예정`

## 7. 참조 및 추적 가이드

- **상향(Upstream) 참조**: 하위 문서는 상위 문서의 ID를 적어서 근거를 남깁니다. (예: "이 스토리는 `PRD-03`에 근거함")
- **하향(Downstream) 참조**: 상위 문서는 하위 문서로 연결되는 링크나 맥락을 유지합니다.
- **중복 금지**: 상위 문서 내용을 그대로 복붙하지 않고, 필요한 경우 ID와 링크로 연결합니다.
- **링크 형식**: `docs/product` 내부 참조는 가능한 한 클릭 가능한 상대 링크(`./파일명.md`)를 사용합니다.

## 관련 문서

- 아키텍처: [`../architecture/ARCHITECTURE-Phos.md`](../architecture/ARCHITECTURE-Phos.md)
- 디스커버리 계획: [`../discovery/phos-discovery-plan.md`](../discovery/phos-discovery-plan.md)
- 지표 대시보드: [`../discovery/phos-metrics-dashboard.md`](../discovery/phos-metrics-dashboard.md)
