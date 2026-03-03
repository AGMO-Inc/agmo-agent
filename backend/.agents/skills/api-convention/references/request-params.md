## 1.8. 요청 파라미터 규칙
| 어노테이션 | 용도 | 규칙 |
|-----------|------|------|
| `@RequestBody @Valid` | JSON 요청 바디 | 생성/수정 시 필수, `@Valid` 반드시 함께 사용 |
| `@PathVariable` | 리소스 식별자 | `/api/v1/{resource}/{id}` |
| `@RequestParam` | 필터/검색 조건 | 대부분 `required = false`, camelCase |
| `@PageableDefault` | 페이징 기본값 | `page = 0`, `size = 20` |
| `@AuthUser` | 인증된 사용자 정보 | 커스텀 어노테이션 (`@AuthenticationPrincipal` 래핑) |
| `@RequestPart` | Multipart 요청 | `consumes = [MediaType.MULTIPART_FORM_DATA_VALUE]` 명시 |

### 1.8.1. 네이밍 규칙

| 위치 | 케이스 | 예시 |
|------|--------|------|
| URL path | kebab-case | `/api/v1/push-tokens`, `/api/v1/developer-info` |
| Query parameter | camelCase | `/api/v1/apps?pageSize=20&sortBy=createdAt` |
| Request/Response body 필드 | camelCase | `userName`, `createdAt` |

### 1.8.2. 페이징/정렬 기본값

```kotlin
@GetMapping
fun getList(
    @PageableDefault(page = 0, size = 20) pageable: Pageable
): ResponseEntity<ApiResponseFormat<Page<XxxApiResponse>>>
```

- 페이징 기본값은 `page = 0`, `size = 20` 으로 통일한다.
- 정렬: `/api/v1/apps?sort=createdAt,desc` 형태를 사용한다.
