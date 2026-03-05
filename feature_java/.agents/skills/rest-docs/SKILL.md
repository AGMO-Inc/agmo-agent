---
name: rest-docs
description: REST API OpenAPI 3.0 JSON 문서 자동 생성기
triggers:
  - swagger
  - docs
  - 문서
  - api docs
  - rest docs
argument-hint: "[domain] | all"
aliases: [swagger, api-docs]
quality: high
model: sonnet
context: fork
agent: seamos-tester
---

# REST API Documentation Generator (OpenAPI 3.0)

> **Agent 위임**: 이 스킬의 모든 작업은 Agent 도구를 사용하여 `seamos-tester` 에이전트에게 위임하여 실행할 것. Agent 호출 시 사용자의 요청 내용과 파싱된 인자를 프롬프트로 전달한다.

SEAMOS REST 엔드포인트를 분석하여 OpenAPI 3.0 기반 JSON 문서를 자동 생성하는 범용 스킬.

## When to Activate

- 사용자가 REST API 문서 생성을 요청할 때
- swagger, api docs, 문서 등의 키워드 감지 시
- **키워드 "swagger", "docs", "문서"가 REST/API 맥락에서 사용되면 즉시 이 스킬을 발동할 것**

## Arguments Parsing

| 인자 패턴 | 동작 |
|-----------|------|
| `all` | 모든 도메인의 엔드포인트 문서 생성 |
| `<domain>` | 특정 도메인만 문서 생성 (예: `machine-model`) |
| (인자 없음) | `all`과 동일하게 동작 |

---

## 실행 절차

### Step 1: 프로젝트명 감지

1. **pom.xml 탐색**: `pom.xml`을 찾아 `<artifactId>` 값 추출
2. **디렉토리 구조**: `ApplicationMain.java`를 포함하는 디렉토리명 사용
3. **Fallback**: 사용자에게 질문

### Step 2: 포트번호 감지

`{projName}/feature.config`에서 `CustomUIPort` 값 읽기 (기본값 `1456`)

### Step 3~5: 엔드포인트 탐색 및 분석


> 📎 Java → JSON Schema 타입 매핑은 `.claude/skills/rest-docs/ref/schema-mapping.md` 를 Read하여 참조할 것

### Step 6: OpenAPI JSON 생성

**출력 경로**: `{projName}/docs/rest/api.json` (디렉토리 없으면 자동 생성)

> 📎 OpenAPI JSON 구조, Method별 paths 규칙, 공통 schemas, Entity schema 규칙은 `.claude/skills/rest-docs/ref/openapi-template.md` 를 Read하여 참조할 것

---

## 범용성 보장 규칙

1. **하드코딩 금지**: 프로젝트명, 포트, 패키지명을 절대 하드코딩하지 않음
2. **동적 탐색**: Glob/Grep으로 파일 위치를 동적으로 찾음
3. **Fallback 체인**: pom.xml → 디렉토리명 → 사용자 질문
4. **SEAMOS 공통 패턴 의존**: `NevonexRoute`, `BaseRestService`, `UIWebServiceProvider`

## Notes

- 생성된 `api.json`은 Swagger UI에서 바로 로드하여 시각화 가능
- 기존 `api.json`이 있으면 덮어쓰기 (최신 엔드포인트 반영)
- Entity 클래스가 없는 서비스는 `processService()` 코드 분석으로 fallback
