HANDOFF CONTEXT
===============

USER REQUESTS (AS-IS)
---------------------
- UserApiDocs 의 swagger 어노테이션을 완성해줘
- `@PreAuthorize`가 메서드 또는 클래스 레벨에 정의되어 있다면 자동으로 `@SecurityScheme`가 추가되므로 인터페이스에는 명시하지 않는다. 라는 규칙을 보고 수정해
- UserController 에서 사용하는 응답값은 API 용으로 새로 만들어주고 (ex. UserApiResponse) ctroller/dto/response 에 넣어줘.
- UserApiDocs 를 API 및 스웨거 규칙을 참고해서 해당하는 DTO 에 모든 스웨거 어노테이션을 붙여줘
- 현재까지의 변경사항을 확인해서 커밋해줘
- 커밋이 너무 많아. swagger 관련과 .agents 관련으로 두 커밋으로 해줘.

GOAL
----
feature/swagger-#401 브랜치의 2개 커밋(.agents 관련, swagger 관련)을 유지한 채 원격 푸시/PR 및 #404 남은 구현 작업을 이어간다.

WORK COMPLETED
--------------
- 나는 User API 문서화를 컨트롤러 구현체에서 분리해 src/main/kotlin/com/agmo/sdmbackend/api/UserApiDocs.kt 인터페이스로 Swagger 어노테이션을 이동/보강했다.
- 나는 UserController 응답을 서비스 DTO(UserResponse) 직접 반환 대신 API 전용 DTO로 분리했고 src/main/kotlin/com/agmo/sdmbackend/user/controller/dto/response/UserApiResponse.kt 를 추가했다.
- 나는 .agents/docs/swagger.md 규칙에 맞춰 User 관련 Request/Response DTO들에 @Schema(클래스/필드) 어노테이션을 보강했다.
- 나는 @PreAuthorize가 붙은 엔드포인트에 대해 인터페이스(UserApiDocs)에서 @SecurityRequirement를 남발하지 않도록 조정했고, SwaggerConfig에서 @PreAuthorize를 읽어 security requirement/설명/extension을 자동 반영하도록 커스터마이징했다.
- 나는 에러 응답을 ErrorResponse 기반으로 통일하기 위해 src/main/kotlin/com/agmo/sdmbackend/common/apiresponse/ErrorResponse.kt 를 도입하고 GlobalExceptionHandler를 수정했다.
- 나는 커밋이 과도하다는 요청에 따라 히스토리를 2개 커밋으로 재작성했고, 원래 커밋들은 backup/feature-swagger-#401-pre-2commits 브랜치에 보관했다.
- 나는 TODO-Issue.md에서 Swagger 관련 체크 항목을 완료 처리했다.

CURRENT STATE
-------------
- 브랜치: feature/swagger-#401
- develop 대비 커밋 2개:
  - 057a001 chore: 작업 스킬 문서 .agents로 이동
  - 4438255 feat: swagger 문서 및 회원 API DTO 보강
- 워킹트리: git status --porcelain 결과 변경 없음(클린)
- 테스트: ./gradlew test 통과(세션 중간에는 통합테스트 실패가 있었지만 이후 수정 후 통과 확인함)
- 참고: git diff --stat HEAD~10..HEAD 는 develop의 최근 이력까지 포함되어 출력이 과다하므로(노이즈 큼), 실제 작업 범위는 develop..HEAD(2커밋) 기준으로 보는 게 정확함.

PENDING TASKS
-------------
- #404 실행 과제 중 Swagger 문서 보강은 완료했지만, 아래 항목은 TODO-Issue.md 기준 미완료:
  - userId로 구독 중인 Plan list 조회 (GET:/subscription/me 와 같은 기능)
  - userId, planId로 특정 사용자 플랜 업그레이드/다운그레이드 (POST:/{planId}/subscription/individual/update 와 같은 기능)
  - userId로 특정 사용자 플랜 연장 (POST: /subscription/individual/extend 와 같은 기능)
  - @PreAuthorize("@authChecker.can(authentication, 'USER', null, 'READ')") 또는 @PreAuthorize("@authChecker.can(authentication, 'APP', #appId, 'WRITE')") 추가
- todoread() 도구는 이 환경에 없어서, 진행상태 SSOT는 TODO-Issue.md로 계속 확인/갱신해야 함.

KEY FILES
---------
- src/main/kotlin/com/agmo/sdmbackend/api/UserApiDocs.kt - User 도메인 Swagger 문서 인터페이스
- src/main/kotlin/com/agmo/sdmbackend/user/controller/UserController.kt - UserApiDocs 구현체(응답 DTO 매핑 포함)
- src/main/kotlin/com/agmo/sdmbackend/user/controller/dto/response/UserApiResponse.kt - User API 전용 응답 DTO(+Schema)
- src/main/kotlin/com/agmo/sdmbackend/user/controller/dto/SignupApiRequest.kt - 회원가입 요청 DTO Schema 보강
- src/main/kotlin/com/agmo/sdmbackend/user/controller/dto/UserUpdateApiRequest.kt - 내 정보 수정 요청 DTO Schema 보강
- src/main/kotlin/com/agmo/sdmbackend/common/config/SwaggerConfig.kt - PreAuthorize 기반 Swagger security/extension/description 자동화
- src/main/kotlin/com/agmo/sdmbackend/common/apiresponse/ErrorResponse.kt - 에러 응답 포맷(스키마 포함)
- src/main/kotlin/com/agmo/sdmbackend/common/exception/handler/GlobalExceptionHandler.kt - ErrorResponse 기반 예외 응답 통일
- .agents/docs/swagger.md - Swagger 어노테이션/문서 컨벤션(SSOT)
- TODO-Issue.md - 현재 작업 이슈(#404) 실행 과제 SSOT

IMPORTANT DECISIONS
-------------------
- Swagger 어노테이션은 컨트롤러 구현체를 오염시키지 않도록 ApiDocs 인터페이스(UserApiDocs)로 분리했다.
- @PreAuthorize가 존재하면 인터페이스에 @SecurityRequirement를 강제로 달지 않는 규칙을 따르되, SwaggerConfig에서 @PreAuthorize를 읽어 Operation에 security requirement와 사람/기계용 메타(extensions, description)를 자동 반영하도록 했다.
- UserController의 응답 DTO는 서비스 레이어 DTO를 그대로 노출하지 않고 controller/dto/response 하위의 API 전용 DTO(UserApiResponse)로 분리했다.
- 에러 응답 스키마/예시 일관성을 위해 ErrorResponse를 도입하고 GlobalExceptionHandler 반환 타입을 ErrorResponse로 변경했다.
- 커밋 수가 많다는 요구로, develop merge-base 기준으로 reset --soft 후 2개 커밋으로 재작성했으며 원본 히스토리는 backup 브랜치로 보존했다.

EXPLICIT CONSTRAINTS
--------------------
- 모든 응답은 한국어로 작성한다.
- 작업 시작/진행/정리 과정에서 TODO-Issue.md 를 단일 진실원천(SSOT)으로 사용한다.
- TODO-Issue.md 에는 "현재 작업 중인 GitHub Issue"에 대한 실행 과제를 기록한다.
- 실행 절차(이슈 시작, 커밋, 푸시/PR)는 `.agents/SKILL.md` 를 참고한다.
- 문서 중복을 피하기 위해 본 파일에는 절차 상세를 중복 기재하지 않는다.
- API 구현 시 (Contoller 클래스 등) .agents/docs/swagger.md 와 .agents/docs/api.md 를 참고한다.
- 코드 작성 시 .agents/docs/code.md 로 컨벤션을 참고한다.
- 비즈니스 예외 작성 시 swagger.md 를 참고하여 ErrorResponse 예시에 추가한다.
- 커밋이 너무 많아. swagger 관련과 .agents 관련으로 두 커밋으로 해줘.

CONTEXT FOR CONTINUATION
------------------------
- 현재 브랜치는 원격 upstream 설정이 없었고, 로컬에서만 히스토리를 2커밋으로 정리한 상태다(푸시/PR은 아직).
- backup/feature-swagger-#401-pre-2commits 브랜치에 원래(다수) 커밋 히스토리가 보관되어 있다(문제 발생 시 참고/복구용).
- AGENTS.md는 .agents/docs/api.md 를 참조하지만, 현재 워크스페이스에 해당 파일은 보이지 않았다(문서 경로/존재 여부 확인 필요).
- Kotlin LSP(kotlin-lsp)가 설치되어 있지 않아 lsp_diagnostics는 사용 불가였고, 검증은 Gradle compile/test로 수행했다.
