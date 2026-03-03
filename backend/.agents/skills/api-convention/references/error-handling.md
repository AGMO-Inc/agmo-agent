## 1.10. 실패 응답 형식 규칙

### 1.10.1. 실패 응답 JSON 구조

**일반 실패 응답**
```json
{
  "data": "ERROR_CODE",
  "status": 404,
  "message": "user not found"
}
```

**Validation 실패 응답 (400)**
```json
{
  "data": ["name", "price"],
  "status": 400,
  "message": "VALIDATION_ERROR"
}
```

- `1.10`은 클라이언트가 따르는 **외부 응답 계약**을 정의한다. 내부 구현 가이드는 `1.13`을 따른다.
- 일반 실패 응답은 `ApiResponseFormat<String>` 형식을 사용한다.
- Validation 실패 응답은 `ApiResponseFormat<List<String>>` 형식을 사용하며, `data`에는 오류가 난 필드명만 문자열 배열로 반환한다.
- 일반 실패 응답에서 `data`에는 에러 코드(`UPPER_SNAKE_CASE`)를, `message`에는 클라이언트에 노출 가능한 최소 메시지를 담는다.
- 보안상 민감한 상세 원인(내부 예외 메시지, stacktrace, SQL 등)은 응답에 포함하지 않는다.

### 1.10.2. ControllerAdvice 사용 원칙

- 실패 응답 생성은 각 Controller에서 처리하지 않고 `@RestControllerAdvice`(`@ControllerAdvice`)로 일괄 처리한다.
- 검증 실패(`MethodArgumentNotValidException`, `ConstraintViolationException`)는 `400 Bad Request`로 통일한다.
- 도메인 예외(`BusinessException`)는 예외가 가진 `httpStatus`, `errorCode`, `message`를 그대로 사용한다.
- 미처리 예외는 `500 Internal Server Error`로 매핑하고, **반드시 Alert를 발송**한다.

### 1.10.3. ControllerAdvice 예외 매핑 (sdm-backend 기준)

| Exception | HTTP Status | Error Code | 비고 |
|-----------|-------------|------------|------|
| `BusinessException` | 예외 내부 `httpStatus` 사용 | 예외 내부 `errorCode` 사용 | 도메인 예외 공통 처리 (`400`, `401`, `403`, `404`, `406`, `409`, `410` 포함) |
| `MethodArgumentNotValidException` | `400 Bad Request` | `VALIDATION_ERROR` | `@RequestBody` 검증 실패 |
| `ConstraintViolationException` | `400 Bad Request` | `VALIDATION_ERROR` | `@PathVariable`, `@RequestParam` 검증 실패 |
| `HttpMessageNotReadableException` | `400 Bad Request` | `INVALID_REQUEST_BODY` | JSON 파싱 실패/타입 불일치 |
| `MethodArgumentTypeMismatchException` | `400 Bad Request` | `INVALID_PARAMETER_TYPE` | 파라미터 타입 변환 실패 |
| `AuthorizationDeniedException` | `403 Forbidden` | `FORBIDDEN` | 인가 실패 |
| `HttpRequestMethodNotSupportedException` | `405 Method Not Allowed` | `METHOD_NOT_ALLOWED` | HTTP 메서드 불일치 |
| `HttpMediaTypeNotSupportedException` | `415 Unsupported Media Type` | `UNSUPPORTED_MEDIA_TYPE` | 지원하지 않는 Content-Type |
| `WebClientResponseException`, `FeignException`, `SocketTimeoutException` | `502 Bad Gateway` | `UPSTREAM_SERVICE_ERROR` | 외부/업스트림 연동 실패 |
| `Exception` | `500 Internal Server Error` | `INTERNAL_SERVER_ERROR` | 미처리 예외. **반드시 Alert 발송** |

### 1.10.4. ControllerAdvice 예시

아래 코드는 핵심 흐름만 보여주는 축약 예시다. 전체 Exception 매핑은 위 표를 기준으로 구현한다.

```kotlin
@RestControllerAdvice
class ApiExceptionHandler(
    private val alertSender: AlertSender,
) {
    @ExceptionHandler(BusinessException::class)
    fun handleBusiness(ex: BusinessException): ResponseEntity<ErrorResponse> {
        return ResponseEntity.status(ex.httpStatus)
            .body(ErrorResponse.error(ex))
    }

    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleMethodArgument(ex: MethodArgumentNotValidException): ResponseEntity<ApiResponseFormat<List<String>>> {
        val invalidFields = ex.bindingResult.fieldErrors
            .map { it.field }
            .distinct()

        return ResponseEntity.badRequest()
            .body(ApiResponseFormat(data = invalidFields, status = 400, message = "VALIDATION_ERROR"))
    }

    @ExceptionHandler(Exception::class)
    fun handleUnknown(ex: Exception): ResponseEntity<ErrorResponse> {
        alertSender.send(ex) // 500 에러 Alert
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(ErrorResponse.error("INTERNAL_SERVER_ERROR", "internal server error"))
    }
}
```

---
## 1.13. 에러 처리 규칙

### 1.13.1. BusinessException 계층

```
RuntimeException
└── BusinessException (abstract)
    ├── message: String
    ├── errorCode: String
    └── httpStatus: HttpStatus
        ├── UserException
        │   ├── UserNotFoundException
        │   ├── NotVerifiedUserException
        │   └── ...
        ├── AppException
        │   ├── AppNotFoundException
        │   └── ...
        └── ...
```

### 1.13.2. 구체 예외 작성 규칙

```kotlin
class UserNotFoundException : UserException(
    MESSAGE, ERROR_CODE, STATUS_CODE
) {
    companion object {
        const val MESSAGE = "user not found"
        const val ERROR_CODE = "USER_NOT_FOUND"
        val STATUS_CODE = HttpStatus.NOT_FOUND
    }
}
```
- `companion object`에 `MESSAGE`, `ERROR_CODE`, `STATUS_CODE` 상수 정의
- `ERROR_CODE`는 `UPPER_SNAKE_CASE`
- `MESSAGE`는 영문 소문자
- stacktrace를 클라이언트에 노출하지 않는다.

### 1.13.3. GlobalExceptionHandler
- `BusinessException` → `ErrorResponse.error(exception)` → 각 예외의 HTTP 상태코드
- `MethodArgumentNotValidException` → `400 BAD_REQUEST` + 오류 필드명 배열 반환
- `ConstraintViolationException` → `400 BAD_REQUEST` + 오류 필드명 배열 반환
- `HttpRequestMethodNotSupportedException` → `405 METHOD_NOT_ALLOWED`
- `HttpMediaTypeNotSupportedException` → `415 UNSUPPORTED_MEDIA_TYPE`
- `AuthorizationDeniedException` → `403 FORBIDDEN`
- `WebClientResponseException`, `FeignException`, `SocketTimeoutException` → `502 BAD_GATEWAY`
- `Exception` (미처리) → `500 INTERNAL_SERVER_ERROR` + Alert 발송

### 1.13.4. ErrorResponse 구조

`ErrorResponse`는 일반 실패 응답에서 `ApiResponseFormat<String>`을 상속한다.

Validation 실패는 `ApiResponseFormat<List<String>>` 형식으로 오류 필드명 배열을 반환한다.

```json
{
  "data": "USER_NOT_FOUND",
  "status": 404,
  "message": "user not found"
}
```
