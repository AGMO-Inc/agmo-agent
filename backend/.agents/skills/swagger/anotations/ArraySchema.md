# `@ArraySchema`

## 목적

배열/리스트의 스키마를 명확히 한다.

## 규칙

- 리스트 필드에서 item schema를 명확히 표현하고 싶을 때 사용한다.
- 배열에 관한 설정(최소/최대 개수 등)이 필요할 때 사용한다.
- 단순 리스트(설명만 필요한 경우)라면 `@Schema`만 사용해도 된다.

## 예제

```kotlin
data class BulkInviteReq(
  @field:ArraySchema(
    arraySchema = Schema(description = "초대할 이메일 목록", minItems = 1, maxItems = 50),
    schema = Schema(example = "user@example.com")
  )
  val emails: List<String>
)
```
