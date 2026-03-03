## 1.4. URL 설계 규칙

### 1.4.1. 리소스 네이밍
| 규칙 | 설명 | 예시 |
|------|------|------|
| **복수형 명사** | 리소스는 항상 복수형 | `/api/v1/users`, `/api/v1/apps`, `/api/v1/devices` |
| **kebab-case** | 2단어 이상은 하이픈 연결 | `/api/v1/push-tokens`, `/api/v1/developer-info`, `/api/v1/feu-types` |
| **소문자** | 대문자 사용 금지 | `/api/v1/organizations` (O), `/api/v1/Organizations` (X) |
| **명사만** | URI에 동사/행위 금지 | `GET /api/v1/devices` (O), `GET /api/v1/device/list` (X) |

- CRUD 동사(`/list`, `/update`, `/delete`)는 URI에 사용하지 않는다. HTTP 메서드로 표현한다.
- 비즈니스 고유 행위(`/extend`, `/sync`, `/refund`)는 `POST /api/v1/{resource}/{id}/{action}` 형태로 허용한다. (→ 1.5.3. Action 엔드포인트 참고)

### 1.4.2. 리소스 중첩

```
/api/v1/{resource}/{id}/{sub-resource}
/api/v1/{resource}/{id}/{sub-resource}/{subId}
```
- 중첩 깊이는 **최대 2단계**를 권장한다.
- 예시: `/api/v1/apps/{appId}/versions/{appVersionId}/status`

### 1.4.3. URL 평면화

ID의 유일성이 보장되는 경우, 상위 리소스를 생략하여 URL을 평면화할 수 있다.

```
# 원본 (중첩)
GET /api/v1/apps/{appId}/reviews/{reviewId}

# 평면화 (ID 유일성 보장 시)
GET /api/v1/reviews/{reviewId}
```

- 하위 리소스의 ID만으로 유일하게 식별 가능한 경우 적용한다.
- 3단계 이상 중첩이 발생하면 평면화를 적극 고려한다.

### 1.4.4. `/me` 패턴

인증된 사용자 **본인**의 리소스에 접근할 때 사용한다. 도메인별 컨트롤러에서 각 도메인의 `/me` 엔드포인트를 제공한다.

```
GET  /api/v1/{resource}/me           # 내 리소스 조회
PUT  /api/v1/{resource}/me           # 내 리소스 수정
GET  /api/v1/{resource}/me/{sub}     # 내 하위 리소스 조회
```

- `/me`는 리소스 바로 다음에 위치한다.
- 예시: `/api/v1/devices/me` (내 디바이스 목록), `/api/v1/users/me` (내 정보)

### 1.4.5. 관리자 엔드포인트

관리자 전용 API는 `/api/v1/admin` 접두사를 사용하여 분리한다.

```
# 관리자 API
GET    /api/v1/admin/users              # 사용자 목록 조회 (관리자)
GET    /api/v1/admin/users/{userId}     # 사용자 단건 조회 (관리자)
DELETE /api/v1/admin/devices/{deviceId} # 디바이스 삭제 (관리자)
```

- 관리자 컨트롤러는 일반 컨트롤러와 **별도 클래스로 분리**한다.
- 관리자/사용자 공용 조회가 필요한 경우, 사용자 API를 관리자가 직접 사용한다. 별도 관리자 엔드포인트를 중복 생성하지 않는다.
- 보안 필터에서 `/api/v1/admin/**` 패턴으로 일괄 제어할 수 있어 보안 관리가 용이하다.

### 1.4.6. API 버전 관리

- 경로 접두사 방식: `/api/v1/users`, `/api/v2/apps`
- 모든 신규 API는 `/api/v1` 형태로 시작하는 것을 원칙으로 한다.
- 버전 없음 = v1으로 간주
- 새로운 버전이 필요한 경우 별도 컨트롤러로 분리를 권장한다.

### 1.4.7. 버전 폐기(Deprecation) 정책

기존 버전을 폐기할 때는 아래 절차를 따른다.

1. Swagger 문서에 `@Deprecated`를 명시한다.
2. 응답 헤더에 `Deprecation`, `Sunset` 헤더를 추가한다.
   ```
   Deprecation: true
   Sunset: Sat, 01 Mar 2026 00:00:00 GMT
   ```
3. 최소 **90일**의 공지 기간을 둔다.
4. 공지 기간 동안 기존 버전과 신규 버전을 병행 운영한다.
5. 공지 기간 종료 후 기존 버전을 제거한다.

### 1.4.8. 브레이킹 변경 기준

아래 변경은 **원칙적으로 브레이킹 변경**으로 본다. 브레이킹 시 API 버전을 업그레이드한다. (v1 -> v2) 단, 호환 계층(구 필드/구 경로 병행, 기본값 보정, 충분한 공지)을 제공하면 같은 버전에서 점진 전환할 수 있다.

| 구분 | 기본 분류 | 완화 조건 (같은 버전 유지 가능) |
|------|----------|--------------------------------|
| 필드 삭제 | 브레이킹 | 구 필드를 deprecated로 남기고 최소 1개 릴리즈 주기 병행 |
| 필드명 변경 | 브레이킹 권장 | 구/신 필드를 동시 제공하고 구 필드 제거 일정을 명시 |
| 필수값 변경 (`optional -> required`) | 브레이킹 | 서버 기본값 대체 또는 구 버전 입력 포맷 허용 |
| 타입 변경 | 브레이킹 | wire format 호환 유지 시 (예: `Int` -> `Long`) 점진 전환 가능 |
| 의미/동작 변경 | 브레이킹 | 기존 의미를 유지하는 별도 필드/엔드포인트를 병행 제공 |
| URL 경로 변경 | 브레이킹 권장 | 구/신 경로를 최소 90일 병행 운영 |
| 성공 상태 코드 변경 | 브레이킹 가능 | 응답 바디/클라이언트 계약 영향 없음을 검증하고 사전 공지 |
| Enum 값 변경/삭제 | 브레이킹 권장 | 새로운 ENUM 값 추가 후 변경 |
| Enum 값 추가 | 논브레이킹 | 클라이언트가 unknown value를 안전하게 처리해야 함 |

