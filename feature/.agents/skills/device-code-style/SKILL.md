---
name: device-code-style
description: Apply device-side C++ coding style and edit constraints in projects where generated code, protected regions, UI-device messaging, and cloud relay integration coexist.
---

# Device C++ Style

## Mandatory Rules

1. Work and explain in Korean.
2. Read each target file before editing and check for existing manual changes.
3. Edit only inside `PROTECTED REGION` blocks.
4. Apply `START -> ENABLED START` conversion only for generated files that require explicit protected-region activation:
   - If the target file contains vendor-generated markers defined by the project, convert:
     - `/*PROTECTED REGION ID(...) START*/`
     - `/*PROTECTED REGION ID(...) ENABLED START*/`
   - If the file is custom code without those generator markers, `ENABLED START` conversion is not mandatory.
5. Keep generated structure intact. Do not edit outside protected regions.

## Environment Baseline

- 실제 언어 버전/빌드 시스템/런타임은 프로젝트 `AGENTS.md`를 기준으로 적용한다.
- 이 스킬의 기본 목적은 "생성 코드 + 보호 구간 + 장치 통신" 패턴을 안정적으로 다루는 것이다.

## Core Module Conventions

### ControllerImpl

- 주기 실행 코어 로직은 프로젝트의 메인 컨트롤 루프 진입점에서 처리한다.
- 센서/GPS/상태 입력은 계산 전에 유효성 검증을 수행한다.
- UI/WebSocket JSON 응답은 프로젝트 공통 응답 빌더(예: `createResponse`)를 우선 사용한다.

### External API Flow

- 외부 통신은 요청 전송 성공과 비즈니스 성공을 분리해 해석한다.
- 요청은 송신 후 비동기 응답 경로(다운로드 리스너/콜백 핸들러)에서 처리한다.
- correlation ID는 프로젝트 규약으로 통일한다.
- 요청 JSON 키/형식은 프로젝트 프로토콜 문서(`AGENTS.md` 또는 하위 문서)를 기준으로 고정한다.

Example:

```cpp
Json::Value requestJson(Json::objectValue);
requestJson["correlation-id"] = correlationId; // e.g. EXT_<uuid>
requestJson["externalUrl"] = externalUrl;
requestJson["method"] = method;
requestJson["header"] = header; // Json::objectValue
requestJson["msg"] = msg;       // Json::objectValue

Json::StreamWriterBuilder writerBuilder;
writerBuilder["indentation"] = "";
const std::string jsonStr = Json::writeString(writerBuilder, requestJson);

CloudClient::getInstance()->uploadData(jsonStr, 1);
```

### Async Cloud Response

- 클라우드 다운로드 응답은 프로젝트 표준 리스너 엔트리포인트에서 처리한다.
- 응답의 `type`(또는 동등 필드)으로 디스패치해 각 핸들러로 전달한다.

### WebSocket Contract

- 송수신 엔트리포인트는 프로젝트 표준 WebSocket 컴포넌트를 사용한다.
- 메시지 스키마는 하위 호환성을 유지한다:
  - Request: `{ "type": "...", "payload": { ... } }`
  - Response: `{ "type": "...", "success": bool, "payload": ... }`

## Style Patterns

### Logging

프로젝트 표준 로거를 사용하고 severity 선택 기준을 명시적으로 유지한다.

### JSON Construction

- Initialize objects with `Json::Value(Json::objectValue)`.
- Assign fields explicitly (`type`, `payload`, headers, body keys).
- 외부 통신 업로드 JSON 키는 프로젝트 규약에 맞춰 안정적으로 유지한다.
- Keep key naming consistent across handlers.

## Build and Dependency Pattern

- 외부 라이브러리 추가는 프로젝트가 채택한 공통 빌드 패턴을 따른다.
- 일회성 빌드 해킹이나 임시 의존성 패치를 금지한다.

## Device Edit Checklist

1. Target file was read before modifications.
2. If the file has the Bosch copyright line, convert to `ENABLED START` before editing protected blocks.
3. UI/WebSocket responses use `createResponse()`.
4. External communication request/response 흐름은 프로젝트 프로토콜 규칙을 유지한다.
5. External API response flow is async via the project's cloud/download listener entrypoint.
6. Logging level selection is intentional and consistent.
7. No unrelated formatting or generated-code churn.
