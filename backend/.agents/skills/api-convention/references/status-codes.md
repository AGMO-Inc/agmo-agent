## 1.6. HTTP 상태 코드 규칙

### 1.6.1. 성공 응답
| 상태 코드 | 용도 | 응답 본문 | 비고 |
|-----------|------|----------|------|
| `200 OK` | 조회, 수정 성공 | `ApiResponseFormat<T>` | 기본 성공 응답 |
| `201 Created` | 리소스 생성 성공 | `ApiResponseFormat<T>` | **`Location` 헤더 필수** |
| `202 Accepted` | 비동기 작업 접수 성공 | `ApiResponseFormat<T>` 또는 작업 식별자 | 처리 결과는 별도 조회 |
| `204 No Content` | 삭제 성공 | 없음 | 응답 본문 없음 |

- HTTP status와 `ApiResponseFormat.status` 값은 반드시 동일해야 한다.

### 1.6.2. 201 Created
- `POST`로 리소스를 **생성**한 경우 `201`을 반환한다.
- `Location` 헤더에 생성된 리소스의 URI를 포함한다.
```kotlin
// 예시
@PostMapping
fun createUser(@RequestBody @Valid request: ...): ResponseEntity<ApiResponseFormat<UserApiResponse>> {
    val user = userService.create(request.toServiceRequest())
    val location = URI.create("/api/v1/users/${user.userId}")
    return ResponseEntity.created(location).body(ApiResponseFormat.created(data = UserApiResponse.of(user)))
}
```

### 1.6.3. 204 No Content
- `DELETE` 성공 시 기본 응답으로 사용한다.
- 응답 본문(body)이 없다.
```kotlin
// 예시
@DeleteMapping("/{userId}")
fun deleteUser(@PathVariable userId: Long): ResponseEntity<Void> {
    userService.deleteUser(userId)
    return ResponseEntity.noContent().build()
}
```

### 1.6.4. 202 Accepted 후속 처리

- 장시간 처리 작업은 `202 + operationId` 패턴을 사용한다.
- `Location` 헤더는 상태 조회 엔드포인트(`/api/v1/operations/{operationId}`)를 가리킨다.
- 상태 조회 응답의 상태값은 `PENDING`, `RUNNING`, `SUCCEEDED`, `FAILED`를 사용한다.

```kotlin
@PostMapping("/api/v1/reports/export")
fun exportReport(@RequestBody @Valid request: ...): ResponseEntity<ApiResponseFormat<OperationAcceptedApiResponse>> {
    val operationId = reportService.startExport(request)
    val location = URI.create("/api/v1/operations/$operationId")

    return ResponseEntity.accepted()
        .location(location)
        .body(ApiResponseFormat.accepted(data = OperationAcceptedApiResponse(operationId))
}

data class OperationAcceptedApiResponse(
    val operationId: String,
)
```

### 1.6.5. 에러 응답

| 상태 코드 | 용도 |
|-----------|------|
| `400 Bad Request` | 요청 값 검증 실패, 타입 불일치, JSON 파싱 실패 |
| `401 Unauthorized` | 인증 실패 (토큰 없음/만료) |
| `403 Forbidden` | 인가 실패 (권한 없음) |
| `404 Not Found` | 리소스 없음 |
| `405 Method Not Allowed` | HTTP 메서드 불일치 |
| `406 Not Acceptable` | 비즈니스 규칙상 처리 불가 (예: 플러그인 uninstall 불가) |
| `409 Conflict` | 중복 리소스, 상태 충돌 |
| `410 Gone` | 만료된 리소스/토큰 (예: 인증 코드 만료) |
| `415 Unsupported Media Type` | 지원하지 않는 Content-Type |
| `500 Internal Server Error` | 서버 내부 오류 |
| `502 Bad Gateway` | 외부/업스트림 연동 실패 |

