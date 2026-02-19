---
name: tdd
description: Kotlin + Spring Boot 백엔드 레포에서 Kotest 기반 TDD를 수행하기 위한 백엔드 공용 스킬이다. 각 레포의 기존 테스트 스타일(BehaviorSpec, JUnit5, MockK/Mockito, Testcontainers)을 먼저 확인하고, 그 컨벤션을 그대로 따라 실패 테스트부터 추가한다. 단위/통합/MVC/Flow 테스트 선택 기준, 실행 명령, 코드 스타일, 흔한 함정을 제공한다.
---

# TDD (Kotlin + Spring + Kotest)

이 스킬은 "특정 서비스 레포" 전용이 아니다. 설치된 레포의 테스트 코드/헬퍼/스타일을 SSOT로 삼아 그대로 확장한다.

## When to Use

- 신규 기능/엔드포인트 추가
- 버그 수정(재현 테스트를 먼저 추가)
- 리팩터링(동작 보존용 테스트 보강)
- 인증/인가, 예외 매핑, 데이터 정합성처럼 회귀 위험이 큰 변경

## Core Principles

- 테스트는 빠르고 결정적이어야 한다(시간/네트워크/랜덤 의존성 최소화).
- 구현 디테일보다 "행동"을 검증한다.
- 실패 메시지가 곧 요구사항이 되도록 시나리오 문구를 구체적으로 쓴다.
- 먼저 실패하는 테스트를 만들고, 최소 구현으로 통과시킨 뒤, 리팩터링한다.

## Choose the Right Test Type

설치된 레포에서 이미 쓰는 방식을 우선한다.

- Unit test (fast): 서비스/유틸 로직을 mock으로 격리
- Integration test (medium): Spring Context + DB 등 실제 컴포넌트 조합 검증
- Web/MVC test (fast-medium): MockMvc/WebTestClient 등으로 컨트롤러/필터/예외 매핑 검증
- Flow/E2E-ish test (slow): 실제 HTTP 플로우(랜덤 포트)로 시나리오 검증
- Repository test (medium): JPA/쿼리/인덱스/락 등 영속 계층 검증

Rule of thumb:

- 버그 재현은 가장 빠른 레벨(Unit)에서 먼저 만들고, 필요할 때만 Integration/Flow로 승격한다.
- 컨트롤러의 request/response shape, 예외 status mapping 검증은 MVC 테스트가 보통 최적.

## Repo-First Convention Check (Do This First)

1. `src/test/kotlin`에서 테스트 스타일을 확인한다.
2. 공통 테스트 헬퍼/베이스 클래스가 있으면 반드시 상속해서 사용한다.
3. MockK/Mockito/AssertJ 등은 "주변 파일"과 동일하게 맞춘다(혼용을 새로 확장하지 않기).
4. 느린 테스트는 Testcontainers/DB cleaner/seed 로직 등 기존 인프라를 재사용한다.

## Unit Test (fast)

목표: 외부 의존성을 mock으로 대체하고, 서비스/도메인 로직을 빠르게 검증한다.

체크리스트:

- SUT(테스트 대상)만 진짜 인스턴스로 만들고 나머지는 mock
- 예외는 타입 + 메시지/에러코드(컨벤션)까지 검증
- 경계값(빈 값/최대값/중복/권한 없음)을 최소 1개씩 포함

Kotest `BehaviorSpec` 예시(요약):

```kotlin
import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.BehaviorSpec
import io.kotest.matchers.shouldBe

class FooServiceUnitTest : BehaviorSpec({
    Given("유효한 입력이 주어질 때") {
        When("처리를 요청하면") {
            Then("정상 결과가 반환된다") {
                // result shouldBe expected
            }
        }

        When("잘못된 입력이 주어지면") {
            Then("예외가 발생한다") {
                shouldThrow<IllegalArgumentException> {
                    // sut.call(...)
                }
            }
        }
    }
})
```

sdm-backend 참고(패턴 예시 - 레포에 맞게 경로/패키지 조정):

- Mockito 기반 단위 테스트: `src/test/kotlin/com/agmo/sdmbackend/auth/service/AuthServiceUnitTest.kt`
- BehaviorSpec 기반 공통 헬퍼: `src/test/kotlin/com/agmo/sdmbackend/testcommon/ServiceUnitTestHelper.kt`

## Integration Test (medium)

목표: Spring Context + DB + 트랜잭션에서 컴포넌트 조합을 검증한다.

체크리스트:

- `@SpringBootTest` + `@ActiveProfiles("test")`
- 테스트 전용 설정 파일(`src/test/resources/application-test.yml` 등)을 사용
- 외부 연동(메일/S3/NFL 등)은 test double로 대체(`@MockkBean(relaxed = true)` 같은 패턴)
- 테스트 데이터는 기존 seed/helper/factory가 있으면 재사용

sdm-backend 참고(패턴 예시 - 레포에 맞게 경로/패키지 조정):

- SpringBootTest + 트랜잭션 + @MockkBean: `src/test/kotlin/com/agmo/sdmbackend/testcommon/ServiceIntegrationTestHelper.kt`
- 실제 서비스 통합 테스트 예시: `src/test/kotlin/com/agmo/sdmbackend/user/service/UserServiceTest.kt`

## Flow Test (slow, high confidence)

목표: API 사용자의 관점에서 "실제 HTTP 플로우"를 시나리오로 검증한다.

체크리스트:

- 랜덤 포트로 실제 서버를 띄우고(TestRestTemplate/WebTestClient 등) HTTP 요청을 보낸다.
- 응답은 공통 응답 포맷이 있으면 그 포맷으로 파싱 후 `status`, `data`를 검증한다.
- 테스트 종료 시 DB 정리를 수행한다(기존 cleaner/transaction 전략을 우선 사용).
- Flow 테스트는 느리기 때문에, 단위/통합 테스트로 먼저 최소 재현을 만든 뒤 필요할 때만 추가한다.

sdm-backend 참고(패턴 예시 - 레포에 맞게 경로/패키지 조정):

- Flow 베이스 헬퍼: `src/test/kotlin/com/agmo/sdmbackend/testcommon/FlowIntegrationHelper.kt`
- Flow 테스트 예시: `src/test/kotlin/com/agmo/sdmbackend/integration/UserSignupFlowTest.kt`

## Kotest Default Style

많은 Kotlin/Spring 레포에서 Kotest `BehaviorSpec` + `Given/When/Then/And`를 표준으로 쓴다.
레포가 BehaviorSpec을 쓰고 있다면, 새 테스트도 동일 스타일을 사용한다.

권장 예시(요약):

```kotlin
import io.kotest.core.spec.style.BehaviorSpec
import io.kotest.matchers.shouldBe

class FooServiceTest : BehaviorSpec({
    Given("유효한 입력이 주어질 때") {
        When("처리를 요청하면") {
            Then("정상 결과가 반환된다") {
                1 + 1 shouldBe 2
            }
        }
    }
})
```

## Mocking and Assertions

레포의 선택을 따른다.

- MockK:
  - `mockk()`, `every { ... } returns ...`, `verify { ... }`
  - Spring 통합 테스트에서는 `@MockkBean(relaxed = true)` 패턴이 흔하다.
- Mockito:
  - `mock(Class::class.java)`, `given(...)`, `verify(...)`
- Assertions:
  - Kotest matcher: `shouldBe`, `shouldNotBe`, `shouldThrow`, `assertSoftly`
  - 이미 AssertJ를 쓰는 레포라면 유지(새 규칙 강제 금지).

## Error/Exception Testing

- 예외 타입 + 메시지/에러코드/HTTP status를 함께 검증한다(레포 컨벤션에 맞게).
- 예외 검증은 Kotest `shouldThrow<T> { ... }`를 우선 고려한다.

## Test Data and Builders

- 테스트 데이터 생성 함수/픽스처/빌더가 이미 있으면 재사용한다.
- 새로 만든다면 "도메인 언어"로 읽히는 팩토리 함수를 만든다.
- 랜덤 데이터는 디버깅을 어렵게 한다. 필요한 경우 seed 고정 또는 명시 값 사용.

## Running Tests (Gradle)

Kotlin/Spring 레포 대부분은 Gradle(JUnit Platform)로 Kotest를 실행한다.

- 전체 테스트:
  - `./gradlew test`
- 특정 테스트 클래스만:
  - `./gradlew test --tests "com.example.FooServiceTest"`
- 패키지/패턴으로 좁히기:
  - `./gradlew test --tests "com.example.foo.*"`

주의:

- Kotest도 JUnit Platform 위에서 실행되므로 `--tests`가 대부분 동작한다.
- 레포에 별도 task(예: `integrationTest`)가 있으면 그 task를 사용한다.

## Code Style (Tests)

- 들여쓰기: 4 spaces
- 테스트 클래스 네이밍: `*Test`
- 시나리오 텍스트는 팀/레포 스타일에 맞춘다(한국어/영어 혼용 금지까지 강제하지 않음)
- Arrange/Act/Assert 대신 BehaviorSpec의 Given/When/Then을 쓰는 레포라면 그대로 따른다.

## Anti-Patterns (Do Not)

- 테스트가 이미 있는 영역에서 다른 Spec 스타일로 새로 시작(FunSpec 등)하면서 컨벤션 분열
- 동일 파일/패키지 내에서 목킹 프레임워크를 무작정 교체
- 테스트 통과를 위해 실제 로직을 테스트 코드로 복사
- 버그픽스 중에 불필요한 대규모 리팩터링
