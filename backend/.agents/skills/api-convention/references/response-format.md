## 1.9. 성공 응답 형식 규칙

### 1.9.1. 공통 래퍼

모든 성공 응답은 `ApiResponseFormat<T>`로 래핑한다. (`204 No Content` 제외)

```kotlin
data class ApiResponseFormat<T>(
    val data: T?,
    val status: Int,
    val message: String,
    @field:JsonInclude(Include.NON_NULL)
    val pageInfo: PageInfo? = null,
) {
    companion object {
        fun <T> ok(
            data: T,
            status: Int = 200,
            message: String = "ok",
            pageInfo: PageInfo? = null,
        ): ApiResponseFormat<T> = ApiResponseFormat(
            data = data,
            status = status,
            message = message,
            pageInfo = pageInfo,
        )
    }
}
```

```kotlin
// 성공 (200)
ResponseEntity.ok(ApiResponseFormat.ok(data))

// 생성 (201)
ResponseEntity.created(location).body(ApiResponseFormat.created(data))

// 비동기 작업 접수 (202)
ResponseEntity.accepted().body(ApiResponseFormat.accepted(data))

// 삭제 (204)
ResponseEntity.noContent().build()
```

- 삭제 응답은 `204 No Content`를 사용하며 응답 본문을 포함하지 않는다.
- HTTP status와 `ApiResponseFormat.status`는 반드시 동일하게 반환한다.
- 성공 응답 메시지는 `"ok"`로 통일한다. **한국어 메시지를 사용하지 않는다.**
  - 클라이언트에 보여줄 메시지는 클라이언트가 에러코드 기반으로 직접 처리한다.
- 페이징이 아닌 응답에서는 `pageInfo`를 내려주지 않는다 (null 필드 생략).

### 1.9.2. 성공 응답 JSON 구조

**성공 (200)**
```json
{
  "data": T,
  "status": 200,
  "message": "ok"
}
```

**생성/비동기 접수 (201/202)**
```json
{
  "data": T,
  "status": 201,
  "message": "ok"
}
```

**페이징 응답**
```json
{
  "data": [ ... ],
  "status": 200,
  "message": "ok",
  "pageInfo": {
    "page": 0,
    "size": 20,
    "totalPages": 5,
    "totalElements": 100,
    "first": true,
    "last": false,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

### 1.9.3. Boolean 필드 네이밍

응답/요청 필드에서 `is`, `can` 접두어를 **사용하지 않는다.** 형용사, 과거분사, 또는 상태를 나타내는 형태를 사용한다.

| ❌ 사용 금지 | ✅ 권장 |
|------------|--------|
| `isActive` | `active` |
| `isEnabled` | `enabled` |
| `isFirst` | `first` |
| `isLast` | `last` |
| `canEdit` | `editable` |
| `canDelete` | `deletable` |

- 이 규칙은 API DTO 필드뿐 아니라 `pageInfo` 등 프레임워크 제공 필드에도 동일하게 적용한다.
