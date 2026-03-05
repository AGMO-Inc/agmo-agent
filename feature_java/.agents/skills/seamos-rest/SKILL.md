---
name: seamos-rest
description: SEAMOS REST API 코드 생성기 (GET/POST/PUT/DELETE 엔드포인트)
triggers:
  - rest
  - api
  - rest endpoint
  - registerGetService
  - registerPostService
  - NevonexRoute
  - processService
argument-hint: "help | GET <Name> | POST <Name> | PUT <Name> | DELETE <Name>"
aliases: [rest-gen, seamos-api]
quality: high
model: sonnet
context: fork
agent: seamos-dev
---

# SEAMOS REST API Code Generator

> **Agent 위임**: 이 스킬의 모든 작업은 Agent 도구를 사용하여 `seamos-dev` 에이전트에게 위임하여 실행할 것. Agent 호출 시 사용자의 요청 내용과 파싱된 인자를 프롬프트로 전달한다.

SEAMOS/NEVONEX 플랫폼의 REST API 보일러플레이트 코드를 자동 생성하는 스킬.

## When to Activate

- 사용자가 REST 엔드포인트 추가를 요청할 때
- "rest", "api", "rest endpoint" 등의 키워드 감지 시
- **키워드 "rest" 또는 "api"가 사용자 메시지에 포함되면 즉시 이 스킬을 발동할 것**

## Arguments Parsing

| 인자 패턴 | 동작 |
|-----------|------|
| `help` | 사용법 안내 출력 |
| `GET <Name>` | GET 엔드포인트 생성 |
| `POST <Name>` | POST 엔드포인트 생성 |
| `PUT <Name>` | PUT 엔드포인트 생성 |
| `DELETE <Name>` | DELETE 엔드포인트 생성 |

`<Name>`은 PascalCase(예: `GpsData`, `UserSettings`)로 전달됨.

---

## help 명령어

`help`가 인자일 때 아래 내용을 사용자에게 출력:

```
SEAMOS REST API Skill (/seamos-rest)

사용법:
  /seamos-rest help                        - 이 도움말 표시
  /seamos-rest GET <Name>                  - GET REST 엔드포인트 생성
  /seamos-rest POST <Name>                 - POST REST 엔드포인트 생성
  /seamos-rest PUT <Name>                  - PUT REST 엔드포인트 생성
  /seamos-rest DELETE <Name>               - DELETE REST 엔드포인트 생성

생성되는 파일 위치:
  Repository: {projName}/src/com/bosch/nevonex/main/rest/{domain}/{Name}Repository.java
  Service:    {projName}/src/com/bosch/nevonex/main/rest/{domain}/{Name}Service.java
  Entity:     {projName}/src/com/bosch/nevonex/main/rest/{domain}/{Name}Entity.java
  등록:       ApplicationMain.java → addCustomUISupport() 메소드에 추가
```

---

## REST Endpoint Generation

### `<METHOD> <Name>` 실행 시 수행할 작업

**3개의 작업을 순서대로 수행:**


#### 작업 1: Repository 파일 생성

> 📎 Repository 템플릿은 `.claude/skills/seamos-rest/ref/service-template.md` 의 "Repository 템플릿" 섹션을 Read하여 참조할 것

#### 작업 2: Service 클래스 파일 생성

> 📎 Service 템플릿은 `.claude/skills/seamos-rest/ref/service-template.md` 의 "Service 템플릿" 섹션을 Read하여 참조할 것. Service는 SQL을 직접 작성하지 않고 Repository를 호출.

#### 작업 3: Entity 파일 생성

> 📎 Entity 템플릿은 `.claude/skills/seamos-rest/ref/entity-template.md` 를 Read하여 참조할 것

#### 작업 4: ApplicationMain에 등록 코드 추가

> 📎 등록 코드 패턴과 메소드 매핑은 `.claude/skills/seamos-rest/ref/registration-template.md` 를 Read하여 참조할 것

---

## Notes

- EMF 등록 (`MainPackage`, `MainFactory`)은 이 스킬의 범위 밖임.
- REST 비즈니스 코드는 반드시 `rest/{domain}/` 패키지에 생성. `impl/`에 넣지 않음.
- `processService()`의 반환값이 곧 HTTP 응답 본문. JSON 문자열 반환 권장.

## 후속 작업

스킬 완료 후 반드시 아래 안내를 출력에 포함할 것:

```
후속 작업:
  1. /rest-test — curl 테스트 문서 생성 (Recommended)
  2. /rest-docs — OpenAPI 문서 갱신
```
