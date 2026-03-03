## 1.5. HTTP 메서드 규칙

### 1.5.1. 메서드별 용도
| 메서드 | 용도 | 멱등성 | Request Body | 비고 |
|--------|------|--------|-------------|------|
| `GET` | 리소스 조회 (단건, 목록) | ✅ | 없음 | |
| `POST` | 리소스 생성, 커맨드성 행위 | ❌ | 있음 | |
| `PUT` | 리소스 **전체** 수정 | ✅ | 있음 | 모든 필드 전송 |
| `PATCH` | 리소스 **부분** 수정 | ✅ | 있음 | 변경 필드만 전송 |
| `DELETE` | 리소스 삭제 | ✅ | **없음** | **body 사용 금지** |

- `DELETE` 요청에 `@RequestBody`를 사용하지 않는다. RFC 9110에서 DELETE body는 "no defined semantics"이며, 일부 프록시/CDN이 body를 무시하거나 제거할 수 있다.
- 삭제 시 추가 정보가 필요한 경우 `@RequestParam` 또는 `@PathVariable`을 사용한다.

### 1.5.2. PUT vs PATCH 구분 기준
| 구분 | PUT | PATCH |
|------|-----|-------|
| 전송 범위 | 전체 필드 (누락 시 null/기본값 처리) | 변경 필드만 (누락 시 기존값 유지) |
| 사용 시점 | 리소스 전체를 교체 | 일부 속성만 변경 (상태 변경 등) |
| 예시 | `PUT /api/v1/users/{id}` (이름, 이메일, 주소 등 전부) | `PATCH /api/v1/apps/{id}/status` (상태만 변경) |
### 1.5.3. Action 엔드포인트

CRUD로 표현하기 어려운 **커맨드성 행위**는 `POST`를 사용한다.

```
POST /api/v1/{resource}/{id}/{action}
```

예시: `/api/v1/boards/{id}/like`, `/api/v1/boards/{id}/pin`, `/api/v1/devices/{id}/sync`, `/api/v1/payments/apps/{id}/refund`

