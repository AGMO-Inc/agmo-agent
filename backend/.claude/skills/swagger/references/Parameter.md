# `@Parameter`

## 목적

쿼리/패스/헤더 파라미터의 의미를 명확히 문서화한다.

## 규칙

- `@PathVariable`, `@RequestParam`에는 가능한 한 `@Parameter`를 붙인다.
- 최소 필드: `description`, 가능하면 `example`
- 필수 여부가 중요하면 `required = true`를 명시한다.

## 예제

```kotlin
fun getUsers(
  @Parameter(description = "이메일 필터(부분 일치)", example = "agmo@agmo.farm")
  email: String?,
  @Parameter(description = "사용자 ID 필터", example = "1")
  userId: Long?,
  @ParameterObject pageable: Pageable,
): ResponseEntity<ApiResponseFormat<List<UserResponse>>>
```
