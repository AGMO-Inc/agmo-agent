---
name: api-convention
description: API 컨벤션을 준수하는 Kotlin/Spring API 코드를 생성하는 스킬이다. Controller, ApiDocs 인터페이스, Request/Response DTO, BusinessException 등 API 계층 전체를 컨벤션에 맞춰 생성한다. "API 만들어줘", "CRUD 생성해줘", "엔드포인트 추가해줘" 같은 요청에서 사용한다. 생성 시 URL 설계, HTTP 메서드/상태코드, DTO 분리, Validation, 에러 처리 규칙을 자동으로 적용한다.
---

# API Convention Skill

## 목적

AI가 Kotlin/Spring API 코드를 생성할 때 팀 API 컨벤션을 일관되게 적용하도록 가이드한다.

## 실행 절차

### 1. 사전 정보 수집

- 사용자에게 도메인명, 엔드포인트 목록, 필드 정의를 확인한다.
- 관리자/사용자/me 패턴 여부를 확인한다.

### 2. 코드 생성 순서

1. Controller 생성 -> `.agents/skills/api-convention/references/controller.md`
2. ApiDocs 인터페이스 생성 (swagger 스킬 참조)
3. Request DTO 생성 -> `.agents/skills/api-convention/references/dto.md`
4. Response DTO 생성 -> `.agents/skills/api-convention/references/dto.md`
5. BusinessException 생성 (필요 시) -> `.agents/skills/api-convention/references/error-handling.md`

### 3. 검증

- 체크리스트로 컨벤션 준수 확인 -> `.agents/skills/api-convention/references/checklist.md`

## 참고

- `.agents/skills/api-convention/references/controller.md`: 기본 원칙, RESTful, DTO 분리, 프로젝트 구조, Controller 규칙
- `.agents/skills/api-convention/references/url-design.md`: URL 설계 규칙 전체
- `.agents/skills/api-convention/references/http-methods.md`: HTTP 메서드 규칙, PUT vs PATCH, Action 엔드포인트
- `.agents/skills/api-convention/references/status-codes.md`: HTTP 상태 코드 규칙 및 201/204/202 패턴
- `.agents/skills/api-convention/references/resource-examples.md`: users/apps/boards 리소스 설계 예시
- `.agents/skills/api-convention/references/request-params.md`: 요청 파라미터 규칙, 네이밍, 페이징/정렬
- `.agents/skills/api-convention/references/response-format.md`: 성공 응답 포맷, ApiResponseFormat, Boolean 네이밍
- `.agents/skills/api-convention/references/error-handling.md`: 실패 응답, ControllerAdvice, BusinessException, ErrorResponse
- `.agents/skills/api-convention/references/dto.md`: Request/Response DTO 네이밍 및 금지 패턴
- `.agents/skills/api-convention/references/auth.md`: 인증/인가 규칙, Bearer Token, authChecker
- `.agents/skills/api-convention/references/data-types.md`: 운영/디버그 규칙, 날짜/Enum/금액/Null 표현 규칙
- `.agents/skills/api-convention/references/validation.md`: Validation 원칙, 어노테이션, 예시, 커스텀 Validator
- `.agents/skills/api-convention/references/checklist.md`: 신규 API/에러 처리/PR 리뷰 체크리스트
