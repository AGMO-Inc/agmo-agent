## 1.11. DTO 규칙

### 1.11.1. Request DTO
- 네이밍: `{Domain}{Action}ApiRequest` (예: `AppCreateApiRequest`, `UserUpdateApiRequest`)
- 위치: `{domain}/controller/dto/request/`
- `toServiceRequest()` 메서드로 서비스 계층 DTO로 변환한다.
- Legacy 허용: 기존 API의 `{Action}{Domain}ApiRequest`는 점진적으로 정리한다.

### 1.11.2. Response DTO
- 네이밍: `{Domain}{Detail}ApiResponse` (예: `UserApiResponse`, `DeviceAdminApiResponse`)
- 위치: `{domain}/controller/dto/response/`
- `companion object { fun of(serviceDto): ApiResponse }` 팩토리 사용

### 1.11.3. 네이밍 금지 패턴

| ❌ 금지 | 이유 | ✅ 대안 |
|--------|------|--------|
| `*ApiV2Request` | 버전을 클래스명에 넣지 않음 | 별도 패키지/컨트롤러로 분리 |
| `*ForAdmin` | 권한을 클래스명에 넣지 않음 | `*AdminApiResponse` |
| `*ControllerDtos` | 묶음 파일 금지 | 클래스별 개별 파일 |

