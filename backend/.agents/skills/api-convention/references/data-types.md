## 1.14. 기타 규칙

### 1.14.1. 운영/디버그 엔드포인트

- 운영용(헬스체크), 디버그용(테스트 webhook, 파일 업로드 등) 엔드포인트는 Swagger 문서에서 `@Hidden` 어노테이션으로 제외한다.
- 클라이언트 개발자에게 노출할 필요가 없는 내부 엔드포인트는 API 문서에 포함하지 않는다.

```kotlin
@Hidden  // Swagger 문서에서 제외
@RestController
class HealthCheckController {
    @GetMapping("/api/v1/health")
    fun health(): String = "ok"
}
```

### 1.14.2. Device ID 전달 방식

- Device ID는 쿼리 파라미터가 아닌 **요청 바디(Request Body)** 로 전달한다.

---

## 1.15. 데이터 표현 규칙

### 1.15.1. 날짜/시간

- 날짜/시간 포맷은 **ISO 8601** 형식을 사용한다.
- 예시: `2025-02-25T16:30:00+09:00`

### 1.15.2. Enum

- Enum 값은 **UPPER_SNAKE_CASE** 로 표현한다.
- 예시: `ACTIVE`, `IN_PROGRESS`, `PAYMENT_COMPLETED`

```kotlin
enum class AppStatus {
    ACTIVE,
    INACTIVE,
    UNDER_REVIEW,
    REJECTED
}
```

### 1.15.3. 통화/금액

- 통화 금액은 **BigDecimal** 타입을 사용한다. `double`/`float` 사용 금지.
- 부동소수점 오차로 인한 금액 계산 오류를 방지한다.
- 금액 표준 scale은 `2`를 사용한다.
- 반올림 규칙은 `RoundingMode.HALF_UP`을 사용한다.
- 통화 코드는 `ISO-4217` 표준(`KRW`, `USD` 등)을 사용한다.

```kotlin
data class PaymentApiResponse(
    val amount: BigDecimal,    // scale = 2
    val currencyCode: String,  // ISO-4217 (예: KRW)
    // val amount: Double,     // ❌
)
```

### 1.15.4. Null 처리

- 응답에서 값이 없는 필드는 `null`로 반환한다. 빈 문자열(`""`)로 대체하지 않는다.
- 선택 필드는 nullable로 선언한다.
