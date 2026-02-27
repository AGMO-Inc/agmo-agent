---
type: backend
---
# AGENTS.md

This file is the working agreement for humans and automation (CI, bots, AI agents).

## Project Overview and Description
- `sdm-backend`는 AGMO SDM 서비스의 백엔드 API 서버다.
- Kotlin + Spring Boot 기반의 모놀리식 애플리케이션이며, 사용자/조직/플랜/커뮤니티/고객문의 등 도메인 기능을 제공한다.
- 주요 역할:
  - REST API 제공 및 인증/인가 처리
  - PostgreSQL 기반 데이터 영속화(JPA + QueryDSL)
  - Redis 캐시/데이터 처리
  - AWS 연동(S3, SQS, SES 등)
  - OpenAPI(Swagger) 문서 제공(`/api-docs`, `/api-docs.json`)

## Tools, Technologies, and Frameworks Used
- Language / Runtime
  - Kotlin 2.1.0
  - Java 17 (toolchain)
- Framework
  - Spring Boot 3.4.4
  - Spring Web, Validation, Security
  - Spring Data JPA, Spring Data Redis
- Database / Persistence
  - PostgreSQL
  - QueryDSL (kapt 기반 Q 클래스 생성)
  - Flyway (`src/main/resources/db/migration`)
- API Documentation
  - springdoc-openapi (`springdoc-openapi-starter-webmvc-ui:2.8.5`)
- Infra / Integration
  - AWS SDK v2 (S3, SQS, SES, Secrets Manager, STS, IoT)
  - Spring Cloud AWS SQS
- Observability
  - Spring Actuator
  - Micrometer Prometheus Registry
  - OpenTelemetry
  - Pyroscope Agent
- Test
  - JUnit5, Spring Boot Test, Spring Security Test
  - Kotest, MockK, SpringMockK
  - Testcontainers (PostgreSQL, Redis)

## How to Build and Run Tests
- 필수 환경
  - JDK 17
  - Docker 실행 환경(Testcontainers 기반 테스트에 필요)
- 빌드
  - `./gradlew clean build`
- 테스트
  - 전체 테스트: `./gradlew test`
  - 특정 테스트: `./gradlew test --tests "com.agmo.sdmbackend.user.service.UserServiceTest"`
- 애플리케이션 실행
  - `./gradlew bootRun`
- 실행/테스트 참고
  - 기본 설정은 `src/main/resources/application.yml`
  - 테스트 전용 설정은 `src/test/resources/application-test.yml`
  - QueryDSL 생성 코드는 `build/generated/source/kapt/main`에 생성됨

## 기본 원칙
- 모든 응답은 한국어로 작성한다.
- 작업 시작/진행/정리 과정에서 TODO-Issue.md 를 단일 진실원천(SSOT)으로 사용한다.
- TODO-Issue.md 에는 "현재 작업 중인 GitHub Issue"에 대한 실행 과제를 기록한다.
- 모든 Git 작업(브랜치 생성/커밋/푸시/PR/리베이스)은 기본적으로 `develop` 또는 `develop` 하위 브랜치에서 수행한다.
- `main`/`master`에서 Git 작업이 필요할 경우에는 사용자에게 명시적으로 허락을 받은 뒤에만 수행한다.

## 레포/프로젝트 정보
- 조직: AGMO-Inc
- 프로젝트명: AGMO SDM System 
- 프로젝트 url: https://github.com/orgs/AGMO-Inc/projects/7
- 레포: https://github.com/AGMO-Inc/sdm-backend

## 스킬
- 실행 절차(이슈 시작, 커밋, 푸시/PR, 코드 작성 방법 등)는 `./SKILL.md` 를 참고한다.
- 문서 중복을 피하기 위해 본 파일에는 절차 상세를 중복 기재하지 않는다.

## API 및 스웨거 규칙
- API 구현 시 (Contoller 클래스 등) `.cluade/skills/swagger/` 및 `.cluade/skills/api/` 를 참고한다.

## 코드 컨벤션
- 코드 작성 시 `.cluade/docs/code.md` 로 컨벤션을 참고한다.
- 비즈니스 예외 작성 시 swagger.md 를 참고하여 ErrorResponse 예시에 추가한다.

## hand-off
- 컨텍스트를 저장하고 다른 세션을 시작할 때 `.cluade/handoff/handoff.md` 에 저장한다.
- 새로운 세션을 시작할 때 handoff.md 가 있는지 확인 후 세션을 시작한다.
