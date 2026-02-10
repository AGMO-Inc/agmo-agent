# `@Schema`

## 적용 범위

- Controller의 Request/Response DTO에 적용한다.

## `@Schema` (클래스 레벨)

### 목적

DTO의 역할을 한 줄로 설명한다.

### 규칙

- 모든 Request/Response DTO 클래스에 `@Schema(description = "...")`를 붙인다.
- `description`은 “무슨 요청/응답인지”가 한 번에 보이게 작성한다.
- Kotlin에서는 DTO 클래스에 붙이는 `@Schema`는 기본적으로 클래스에 잘 적용되므로 `@field:`를 사용하지 않는다.

### 예제

```kotlin
@Schema(description = "회원 가입 요청")
data class SignupApiRequest(
  // ...
)
```

## `@Schema` (필드 레벨)

### 목적

필드 의미/예시/필수 여부를 명확히 한다.

### 규칙

- 모든 외부 노출 필드에 `description`은 필수로 작성한다.
- 가능하면 `example`을 작성한다.
- 필수 여부가 중요하면 `requiredMode`로 명시한다.
- Validation 어노테이션을 함께 사용한다. (런타임 검증과 문서가 일치하도록)
- Kotlin DTO에서는 Validation/Schema가 필드에 확실히 붙도록 `@field:`를 사용한다.

### 예제

```kotlin
@Schema(description = "회원 가입 요청")
data class SignupApiRequest(
  @field:Schema(
    description = "이메일",
    example = "user@example.com",
    requiredMode = Schema.RequiredMode.REQUIRED
  )
  @field:NotBlank
  @field:Email
  val email: String,
)
```
