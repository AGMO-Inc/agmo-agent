## 1.12. 인증/인가 규칙

### 1.12.1. 기본 원칙

| 어노테이션 | 용도 |
|-----------|------|
| `@PreAuthorize("@authChecker.can(...)")` | **모든 권한 체크에 사용** (리소스 소유권 + 역할 기반) |
| `@AuthUser user: AuthenticationUser` | 현재 로그인 사용자 정보 주입 |
| 인증 불필요 | `@PreAuthorize` 생략 (회원가입, 로그인, 공개 조회) |

- 모든 권한 체크는 `@authChecker.can()`으로 통일한다. `hasRole('ADMIN')` 등 Spring Security 기본 표현식을 직접 사용하지 않는다.

### 1.12.2. 인증 프로토콜

- 인증 방식: **Bearer Token** (Authorization 헤더)
  ```
  Authorization: Bearer {access_token}
  ```
- `401 Unauthorized`: 토큰이 없거나, 만료되었거나, 유효하지 않은 경우
- `403 Forbidden`: 토큰은 유효하지만 해당 리소스/행위에 대한 권한이 없는 경우

| 상태 코드 | 의미 | 클라이언트 대응 |
|-----------|------|---------------|
| `401` | 인증 실패 (누구인지 모름) | 재로그인 유도 |
| `403` | 인가 실패 (권한 부족) | 접근 불가 안내 |
