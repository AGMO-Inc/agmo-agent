---
name: swagger
description: sdm-backend에서 Swagger(springdoc-openapi) 문서화를 일관되게 작성하기 위한 스킬이다. Controller 구현체의 Swagger 어노테이션 과다로 인한 오염을 방지하기 위해 ApiDocs 인터페이스로 문서만 분리하고, 엔드포인트/DTO에 필요한 어노테이션을 표준 규칙에 따라 적용한다. 이 문서의 목적은 (1) 문서 가독성을 높여 구현 의도/사용 방식의 오해를 줄이고 (2) AI가 검색/해석 가능한 구조를 만들어 자동화(MCP 검색 등)에 활용하는 것이다.
---

# Swagger Skill

## 1.1. 기본원칙

Swagger 컨벤션 문서의 목적은 다음과 같다.

* Swagger 문서의 가독성을 높여 구현 의도와 사용 방식의 오해를 줄이고, 클라이언트와 서버 개발자 간 소통의 매개체로 활용할 수 있게 한다.
* AI가 해석 및 검색 가능한 구조(json)를 생성하여 MCP 서버에서 쉽게 검색 가능하도록 한다.

## 1.2. API 인터페이스

Swagger 어노테이션이 과도해져 Controller 구현체를 오염시키는 문제를 피하기 위해 인터페이스로 문서만 분리한다.

해당 구조 예시는 `.agents/skills/swagger/examples.md`를 참고한다.

## 참고
- 어노테이션 사용 시 아래 어노테이션 문서를 참고한다.
- 어노테이션 문서(규칙 + 예제)
  - ApiDocs 인터페이스에서 사용되는 어노테이션
    - `AGENT_ROOT/skills/swagger/anotations/Tag.md`
    - `AGENT_ROOT/skills/swagger/anotations/Operation.md`
    - `AGENT_ROOT/skills/swagger/anotations/Parameter.md`
    - `AGENT_ROOT/skills/swagger/anotations/ApiResponses.md`
    - `AGENT_ROOT/skills/swagger/anotations/SecurityRequirement.md`
    - `AGENT_ROOT/skills/swagger/anotations/ParameterObject.md`
  - DTO 클래스에서 사용되는 어노테이션
    - `AGENT_ROOT/skills/swagger/anotations/Schema.md`
    - `AGENT_ROOT/skills/swagger/anotations/ArraySchema.md`
    - `AGENT_ROOT/skills/swagger/anotations/Hidden.md`
