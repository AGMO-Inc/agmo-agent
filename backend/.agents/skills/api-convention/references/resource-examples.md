## 1.7. 리소스 설계 예시

### 1.7.1. 사용자 리소스 (`/api/v1/users`)

| Method | URL | Status | 설명 |
|--------|-----|--------|------|
| `POST` | `/api/v1/users/signup` | `201` | 회원 가입 (`Location: /api/v1/users/{id}`) |
| `GET` | `/api/v1/admin/users` | `200` | 사용자 목록 조회 (관리자, 페이징) |
| `GET` | `/api/v1/admin/users/{userId}` | `200` | 사용자 단건 조회 (관리자) |
| `GET` | `/api/v1/users/me` | `200` | 내 정보 조회 |
| `PUT` | `/api/v1/users/me` | `200` | 내 정보 수정 |
| `PUT` | `/api/v1/admin/users/{userId}` | `200` | 사용자 정보 수정 (관리자) |
| `DELETE` | `/api/v1/admin/users/{userId}` | `204` | 사용자 삭제 (관리자) |
| `DELETE` | `/api/v1/users/me` | `204` | 내 계정 삭제 |

### 1.7.2. 앱 리소스 (`/api/v1/apps`)

| Method | URL | Status | 설명 |
|--------|-----|--------|------|
| `POST` | `/api/v1/apps` | `201` | 앱 생성 (`Location: /api/v1/apps/{id}`) |
| `GET` | `/api/v1/apps` | `200` | 앱 목록 조회 (페이징) |
| `GET` | `/api/v1/apps/{appId}` | `200` | 앱 단건 조회 |
| `PUT` | `/api/v1/apps/{appId}` | `200` | 앱 수정 |
| `DELETE` | `/api/v1/apps/{appId}` | `204` | 앱 삭제 |
| `POST` | `/api/v1/apps/{appId}/versions` | `201` | 앱 버전 생성 (하위 리소스) |
| `GET` | `/api/v1/apps/{appId}/versions` | `200` | 앱 버전 목록 조회 |
| `PUT` | `/api/v1/apps/{appId}/versions/{versionId}` | `200` | 앱 버전 수정 |
| `PATCH` | `/api/v1/apps/{appId}/status` | `200` | 앱 상태 변경 (부분 수정) |

### 1.7.3. 게시판 리소스 (`/api/v1/boards`) — 액션 포함

| Method | URL | Status | 설명 |
|--------|-----|--------|------|
| `POST` | `/api/v1/boards` | `201` | 게시글 작성 (`Location: /api/v1/boards/{id}`) |
| `GET` | `/api/v1/boards` | `200` | 게시글 목록 조회 |
| `GET` | `/api/v1/boards/{boardId}` | `200` | 게시글 상세 |
| `PUT` | `/api/v1/boards/{boardId}` | `200` | 게시글 수정 |
| `DELETE` | `/api/v1/boards/{boardId}` | `204` | 게시글 삭제 |
| `POST` | `/api/v1/boards/{boardId}/like` | `200` | 좋아요 토글 (액션) |
| `POST` | `/api/v1/boards/{boardId}/pin` | `200` | 상단 고정 토글 (액션) |
| `POST` | `/api/v1/boards/{boardId}/comments` | `201` | 댓글 작성 (하위 리소스) |

