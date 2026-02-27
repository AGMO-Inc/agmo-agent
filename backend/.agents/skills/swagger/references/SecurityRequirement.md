# `@SecurityRequirement`

## 목적

“이 API는 인증이 필요하다”를 문서에 표시한다.

## 규칙

- `@PreAuthorize`가 메서드 또는 클래스 레벨에 정의되어 있다면 자동으로 `@SecurityScheme`가 추가되므로 인터페이스에는 명시하지 않는다.
- `@PreAuthorize`가 없는 컨트롤러(또는 메서드)에 인증이 필요하다면 `@SecurityRequirement(name = "Bearer Authentication")`를 붙인다.
- 인증이 섞여 있다면:
  - 기본은 컨트롤러 레벨
  - 예외(공개 API)는 메서드에서 별도 처리

## 예제

```kotlin
@SecurityRequirement(name = "Bearer Authentication")
fun getUsers(
  @Parameter(description = "사용자 ID 필터", example = "1") userId: Long?,
  @ParameterObject pageable: Pageable,
): ResponseEntity<ApiResponseFormat<List<UserResponse>>>
```
