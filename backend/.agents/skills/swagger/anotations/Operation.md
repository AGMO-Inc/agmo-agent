# `@Operation`

## 목적

엔드포인트의 “한 줄 요약 + 상세 설명”을 제공한다.

## 규칙

- 모든 API 메서드에 `@Operation`을 붙인다.
- `summary`: 짧고 검색이 잘 되게 작성한다. (예: “리뷰 목록 조회”, “리뷰 등록”)
- `description`: 아래 중 필요한 것만 불릿으로 작성한다.
  - 동작 설명(무엇을 반환/처리)
  - 페이징/정렬 규칙
  - 제약/예외 조건(길이 제한, 상태 조건 등)

## 예제

```kotlin
@Operation(
  summary = "회원 가입",
  description = """
  - 이메일 인증 후 회원가입을 합니다.
  """
)
fun signup(
  request: SignupApiRequest,
): ResponseEntity<ApiResponseFormat<UserResponse>>
```
