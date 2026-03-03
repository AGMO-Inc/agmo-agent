## 1.16. Validation 규칙

### 1.16.1. 기본 원칙

- 모든 `@RequestBody`에는 `@Valid`를 반드시 함께 사용한다.
- `@PathVariable`, `@RequestParam`도 검증 대상이며, 파라미터 Validation을 적용하려면 Controller에 `@Validated`를 선언한다.
- Request DTO의 각 필드에 적절한 Validation 어노테이션을 적용한다.
- Validation 실패 시 `400 Bad Request`를 반환한다.

### 1.16.2. 주요 Validation 어노테이션

| 어노테이션 | 용도 | 적용 타입 | 예시 |
|-----------|------|----------|------|
| `@NotNull` | null 불허 | 모든 타입 | `@NotNull val userId: Long` |
| `@NotBlank` | null, 빈 문자열, 공백 문자열 불허 | String | `@NotBlank val name: String` |
| `@NotEmpty` | null, 빈 컬렉션 불허 | Collection, String | `@NotEmpty val tags: List<String>` |
| `@Size` | 문자열/컬렉션 크기 제한 | String, Collection | `@Size(min = 1, max = 100) val title: String` |
| `@Min` / `@Max` | 숫자 최소/최대값 제한 | 숫자 타입 | `@Min(0) @Max(100) val quantity: Int` |
| `@Email` | 이메일 형식 검증 | String | `@Email val email: String` |
| `@Pattern` | 정규식 패턴 검증 | String | `@Pattern(regexp = "^[a-z0-9-]+$") val slug: String` |
| `@Positive` | 양수만 허용 | 숫자 타입 | `@Positive val price: BigDecimal` |
| `@PastOrPresent` | 현재 또는 과거 날짜만 허용 | 날짜 타입 | `@PastOrPresent val birthDate: LocalDate` |
| `@FutureOrPresent` | 현재 또는 미래 날짜만 허용 | 날짜 타입 | `@FutureOrPresent val expiryDate: LocalDateTime` |

### 1.16.3. 사용 예시

```kotlin
data class AppCreateApiRequest(
    @field:NotBlank
    @field:Size(min = 1, max = 100)
    val name: String,

    @field:NotBlank
    @field:Size(max = 500)
    val description: String,

    @field:NotNull
    @field:Positive
    val price: BigDecimal,

    @field:NotBlank
    @field:Pattern(regexp = "^[a-z0-9-]+$", message = "slug must be lowercase alphanumeric with hyphens")
    val slug: String,

    @field:Size(max = 10)
    val tags: List<String>? = null,
) {
    fun toServiceRequest(): AppCreateRequest = AppCreateRequest(
        name = name,
        description = description,
        price = price,
        slug = slug,
        tags = tags,
    )
}
```

> **주의**: Kotlin data class에서는 `@field:` 타겟을 명시해야 Validation 어노테이션이 올바르게 동작한다. `@NotBlank`이 아니라 `@field:NotBlank`로 사용한다.

### 1.16.4. 중첩 객체 Validation

중첩된 객체에도 Validation을 적용하려면 `@field:Valid`를 사용한다.

```kotlin
data class OrderCreateApiRequest(
    @field:NotNull
    @field:Valid
    val shippingAddress: AddressApiRequest,

    @field:NotEmpty
    @field:Valid
    val items: List<OrderItemApiRequest>,
)

data class AddressApiRequest(
    @field:NotBlank
    val street: String,
    @field:NotBlank
    val city: String,
)
```

### 1.16.5. 파라미터 Validation (`@PathVariable`, `@RequestParam`)

`@RequestBody` 외의 파라미터도 Validation 규칙을 적용한다.

```kotlin
@Validated
@RestController
@RequestMapping("/api/v1/users")
class UserController {
    @GetMapping("/{userId}")
    fun getUser(
        @PathVariable @Positive userId: Long,
        @RequestParam(required = false) @Size(min = 2, max = 20) keyword: String?,
        @RequestParam(required = false) @Pattern(regexp = "name|createdAt") sortBy: String?,
    ): ResponseEntity<ApiResponseFormat<UserApiResponse>> {
        TODO("...")
    }
}
```

- 파라미터 Validation 실패는 `ConstraintViolationException`으로 처리하며 `400 Bad Request`를 반환한다.
- 식별자 파라미터는 `@Positive`, 범위 파라미터는 `@Min/@Max`, 문자열 파라미터는 `@Size/@Pattern` 사용을 권장한다.

### 1.16.6. 커스텀 Validator

표준 어노테이션으로 표현할 수 없는 복합 검증 로직에는 커스텀 Validator를 작성한다.

```kotlin
// 1. 어노테이션 정의
@Target(AnnotationTarget.FIELD)
@Retention(AnnotationRetention.RUNTIME)
@Constraint(validatedBy = [PhoneNumberValidator::class])
annotation class ValidPhoneNumber(
    val message: String = "invalid phone number format",
    val groups: Array<KClass<*>> = [],
    val payload: Array<KClass<out Payload>> = [],
)

// 2. Validator 구현
class PhoneNumberValidator : ConstraintValidator<ValidPhoneNumber, String> {
    override fun isValid(value: String?, context: ConstraintValidatorContext): Boolean {
        if (value == null) return true  // @NotNull과 조합하여 사용
        return value.matches(Regex("^\\+?[0-9]{10,15}$"))
    }
}

// 3. DTO에서 사용
data class UserUpdateApiRequest(
    @field:ValidPhoneNumber
    val phoneNumber: String?,
)
```

### 1.16.7. Validation 에러 응답

Validation 실패 시 `GlobalExceptionHandler`에서 `MethodArgumentNotValidException`/`ConstraintViolationException`을 처리하여 `400 Bad Request`를 반환한다. 에러 응답 `data`에는 오류가 난 필드명만 문자열 배열로 반환한다.

```json
{
  "data": ["name", "price"],
  "status": 400,
  "message": "VALIDATION_ERROR"
}
```

### 1.16.8. Validation 적용 기준

| 구분 | Validation 필수 여부 |
|------|-------------------|
| `@RequestBody` (생성/수정) | ✅ 필수 (`@Valid` + 필드 어노테이션) |
| `@PathVariable` | ✅ 권장 (`@Positive`, `@Min` 등 제약 명시) |
| `@RequestParam` | ✅ 권장 (`@Validated` + `@Size`, `@Pattern`, `@Min/@Max`) |
| Query String (Pageable 등) | ⚠️ 기본값 설정으로 대응 (`@PageableDefault`) |

