---
name: rest-test
description: REST API curl 테스트 마크다운 생성기
triggers:
  - 테스트
  - test
  - curl 테스트
  - test curl
  - api test
argument-hint: "<domain> | all"
aliases: [test-gen, curl-gen]
quality: high
model: sonnet
context: fork
agent: seamos-tester
---

# REST API Test Markdown Generator

> **Agent 위임**: 이 스킬의 모든 작업은 Agent 도구를 사용하여 `seamos-tester` 에이전트에게 위임하여 실행할 것. Agent 호출 시 사용자의 요청 내용과 파싱된 인자를 프롬프트로 전달한다.

SEAMOS REST 엔드포인트의 curl 테스트 샘플을 마크다운 파일로 자동 생성하는 스킬.

## When to Activate

- 사용자가 REST API 테스트 문서를 요청할 때
- curl 샘플 작성을 요청할 때
- **키워드 "테스트" 또는 "test"가 REST/API 관련 맥락에서 사용되면 즉시 이 스킬을 발동할 것**

## Arguments Parsing

| 인자 패턴 | 동작 |
|-----------|------|
| `<domain>` | 특정 도메인의 테스트 마크다운 생성 (예: `machine-model`) |
| `all` | 모든 도메인의 테스트 마크다운 생성 |
| (인자 없음) | 등록된 모든 REST 엔드포인트를 탐색하여 생성 |

`<domain>`은 kebab-case (예: `machine-model`, `gps-data`).

---

## 실행 절차

### Step 1: REST 엔드포인트 탐색

**파일**: `{projName}/src/com/bosch/nevonex/main/impl/ApplicationMain.java`의 `addCustomUISupport()` 메소드에서 등록된 서비스를 파싱 (HTTP Method, Route path, Service 클래스명)

### Step 2: Service 클래스 분석

각 Service 파일에서 SQL 쿼리, 필수 필드 검증, `processService()` 로직 추출

### Step 3: Entity 클래스 분석

해당 도메인의 Entity 클래스에서 필드명과 타입 추출 → 샘플 데이터 생성에 활용

### Step 4: 마크다운 파일 생성

**출력 경로**: `.claude/test/{domain}.md`

> 📎 마크다운 출력 포맷, curl 생성 규칙, 샘플 데이터 규칙, 응답 패턴은 `.claude/skills/rest-test/ref/output-format.md` 를 Read하여 참조할 것

---

## 주요 참조 파일

| 파일 | 역할 |
|------|------|
| `{projName}/src/com/bosch/nevonex/main/impl/ApplicationMain.java` | 등록된 엔드포인트 탐색 |
| `{projName}/src/com/bosch/nevonex/main/rest/{domain}/*Service.java` | 서비스 로직 분석 |
| `{projName}/src/com/bosch/nevonex/main/rest/{domain}/*Entity.java` | 필드/타입 분석 |
| `{projName}/src/com/bosch/nevonex/main/rest/BaseRestService.java` | 공통 응답 패턴 참조 |

## Notes

- 테스트 마크다운은 `.claude/test/` 디렉토리에 도메인별로 분리하여 저장
- 기존 파일이 있으면 덮어쓰기 (최신 엔드포인트 반영)
- Base URL은 `http://localhost:1456` 고정 (feature.config의 CustomUIPort)

## 후속 작업

스킬 완료 후 반드시 아래 안내를 출력에 포함할 것:

```
후속 작업: /rest-verifier — 앱 빌드 후 API 검증을 실행할 수 있습니다.
```
