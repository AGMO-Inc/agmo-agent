# `@ParameterObject`

## 목적

`Pageable` 같은 객체형 쿼리 파라미터를 문서화한다(springdoc 기능).

## 규칙

- 페이징을 `Pageable`로 받는 경우 `@ParameterObject`를 사용한다.
- 팀 내에서 페이징/정렬 규칙을 고정한다면 `@Operation.description`에 규칙을 명시한다.

## 예제

```kotlin
fun getUsers(
  @ParameterObject pageable: Pageable,
): ResponseEntity<ApiResponseFormat<List<UserResponse>>>
```
