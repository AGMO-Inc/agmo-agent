# `@Hidden` / `@Schema(accessMode = ...)`

## 목적

클라이언트에 보여주지 않거나, 읽기/쓰기 전용을 명확히 한다.

## 규칙

- 서버 내부용 필드는 `@Hidden`을 사용한다.
- 생성/수정 요청에서 입력받지 않는 필드(id 등)는 `READ_ONLY`를 사용한다.
- 민감 정보(토큰 등)는 `WRITE_ONLY` 또는 노출 자체를 금지한다.

## 예제

```kotlin
data class ExampleDto(
  @field:Schema(
    accessMode = Schema.AccessMode.READ_ONLY,
    description = "서버가 생성하는 ID",
    example = "10"
  )
  val id: Long? = null,

  @field:Hidden
  val internalDebug: String? = null,

  @field:Schema(
    accessMode = Schema.AccessMode.WRITE_ONLY,
    description = "액세스 토큰"
  )
  val accessToken: String? = null,
)
```
