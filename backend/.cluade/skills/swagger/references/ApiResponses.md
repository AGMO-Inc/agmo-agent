# `@ApiResponses` / `@ApiResponse`

## 목적

HTTP 상태 코드별 응답을 표준화하고, 실패 케이스를 명확히 한다.

## 규칙

- 모든 API는 성공 응답을 명시한다.
  - 200 / 201 / 204 중 실제 동작에 맞는 상태 코드를 사용한다.
  - 성공 응답은 `content`를 작성하지 않는다. (springdoc이 반환 타입을 기반으로 스키마를 자동 생성하도록 둔다.)
- 실패 응답은 실제로 발생 가능한 비즈니스 에러를 모두 확인하여 추가한다. (해당 콜이 호출하는 메서드 스택을 확인)
  - 401 에러(인증 실패)는 문서화에서 제외한다. (공통 인증 필터/가드에서 처리)
  - 403 에러는 원인이 "권한 부족(공통 인가)"인 경우 문서화에서 제외한다.
    - 단, 도메인 비즈니스 규칙으로 403을 반환하는 경우(예: 조직 미승인 등)는 문서화한다.
  - 실패 응답의 `content.schema`는 항상 `ErrorResponse`를 사용한다.
- 실패 응답의 `examples`는 해당 상태 코드에서 발생 가능한 에러를 모두 나열한다.
  - `ExampleObject.name`는 에러 코드(예: `USER_NOT_VERIFIED`)로 지정한다.
  - `ExampleObject.summary`는 사람이 이해하기 쉬운 짧은 설명을 적는다.
  - `ExampleObject.value`는 `ErrorResponse` 형태의 JSON으로 작성한다.

## ExampleObject.value 작성 규칙

- `data`: `Exception.ERROR_CODE`
- `message`: `Exception.MESSAGE`
- `status`: 해당 `responseCode`의 숫자값(예: 404)

## 예제

```kotlin
@ApiResponses(value =
  [
    ApiResponse(responseCode = "200", description = "성공"),
    ApiResponse(
      responseCode = "404",
      description = "리소스 없음",
      content = [
        Content(
          schema = Schema(implementation = ErrorResponse::class),
          examples = [
            ExampleObject(
              name = "USER_NOT_VERIFIED",
              summary = "인증 대상 불일치",
              value = """
          {
            \"data\": \"${NotVerifiedUserException.ERROR_CODE}\",
            \"status\": 404,
            \"message\": \"${NotVerifiedUserException.MESSAGE}\"
          }
          """
            ),
          ]
        )
      ]
    )
  ]
)
```
