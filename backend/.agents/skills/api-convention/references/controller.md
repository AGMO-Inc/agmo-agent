# 1\. API 컨벤션
## 1.1. 기본 원칙

API 계층(Controller)은 클라이언트 요청을 수신하고, 서비스를 호출한 뒤, 응답을 변환하여 반환하는 역할만 한다. 비즈니스 로직을 포함하지 않는다.

> 문서 작성일 이전에 구현된 API 에 대해서는 문서와 다른 점이 있더라도 클라이언트 측 호환성을 고려해 수정하지 않는다. 내부적인 동작은 수정할 수 있다.

### 1.1.1. RESTful API

본 프로젝트는 **Richardson Maturity Model Level 2** 를 기준으로 RESTful API를 설계한다.

- URI는 **리소스(명사)** 를 표현하고, **행위는 HTTP 메서드**로 표현한다.
- 참고 문서
  - [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines/blob/vNext/azure/Guidelines.md)
  - [REST API Tutorial](https://restfulapi.net/)
  - [Google API Design Guide](https://cloud.google.com/apis/design)

### 1.1.2. API-Service 계층 DTO 분리

- Controller의 Request/Response DTO와 Service의 DTO를 **반드시 분리한다.**
- Request DTO → `toServiceRequest()` 메서드로 서비스 DTO 변환
- Response DTO → `companion object { fun of(serviceDto) }` 팩토리로 서비스 DTO → API DTO 변환
- **모든 API 응답은 `*ApiResponse` 로 래핑하여 계층 분리 원칙을 준수한다.** 서비스 DTO를 직접 반환하지 않는다.

---

## 1.2. 프로젝트 구조

### 1.2.1. 패키지 구조

```
{domain}/
├── api/                          # Swagger 문서 인터페이스 (ApiDocs)
│   └── XxxApiDocs.kt
├── controller/
│   ├── XxxController.kt          # 구현체 (implements XxxApiDocs)
│   └── dto/
│       ├── request/              # 요청 DTO
│       │   └── XxxCreateApiRequest.kt
│       └── response/             # 응답 DTO
│           └── XxxApiResponse.kt
├── service/
│   ├── XxxService.kt
│   └── dto/                      # 서비스 계층 DTO (API DTO와 분리)
└── ...
```

- 모든 컨트롤러는 **ApiDocs 인터페이스 패턴**을 사용하여 Swagger 어노테이션을 분리한다.
- Controller 클래스에 직접 `@Tag`, `@Operation`을 사용하지 않는다.

---

## 1.3. Controller 클래스 규칙

### 1.3.1. 기본 구조

```kotlin
@RestController
@RequestMapping("/api/v1/{resources}")   // 복수형 명사, kebab-case
class XxxController(
    private val xxxService: XxxService,
) : XxxApiDocs {
    ...
}
```
- `@RestController` + `@RequestMapping` 클래스 레벨 필수
- `@RequestMapping`에 base path를 반드시 명시한다. 빈 `@RequestMapping` 사용 금지
- ApiDocs 인터페이스 구현
- 생성자 주입 (field injection 금지)
- `@Valid`는 `@RequestBody` 와 함께 반드시 사용한다.

