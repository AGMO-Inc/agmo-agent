# API 인터페이스 구조 예시

## ApiDocs 인터페이스 (예: UserApiDocs)

```kotlin
@Tag(name = "03-1. 사용자 - 회원 관리", description = "회원(User) 정보 생성/수정/조회/삭제 등 회원 관련 API")
interface UserApiDocs {
  @Operation(summary = "회원 가입", description = "이메일 인증 후 회원가입을 합니다.")
  @ApiResponses(
    value = [
      ApiResponse(responseCode = "200", description = "성공"),
      ApiResponse(
        responseCode = "400",
        description = "요청 값이 올바르지 않음",
        content = [
          Content(
            schema = Schema(implementation = ApiResponseFormat::class)
          )
        ]
      )
    ]
  )
  fun signup(
    request: SignupApiRequest,
  ): ResponseEntity<ApiResponseFormat<UserResponse>>
}
```

## Controller 구현체 (예: UserController)

```kotlin
@RestController
@RequestMapping("/users")
class UserController(
  private val userService: UserService,
  private val verificationService: VerificationService
) : UserApiDocs {

  @PostMapping("/signup")
  override fun signup(
    @RequestBody @Valid request: SignupApiRequest,
  ): ResponseEntity<ApiResponseFormat<UserResponse>> {
    val verifiedInfo = verificationService.getVerifiedInfo(request.verificationToken)
    // ...
  }
}
```
