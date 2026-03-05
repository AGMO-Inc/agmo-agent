# Feature Java — SEAMOS/NEVONEX 플랫폼 스킬 패키지

SEAMOS/NEVONEX IoT 플랫폼(Spark Java + Gson + H2 DB) 기반 프로젝트를 위한 AI 에이전트 및 스킬 모음.

REST API 코드 생성, WebSocket 통신, Cloud 업로드, FIF 빌드, Custom UI, 테스트 자동화, OpenAPI 문서화까지 SEAMOS 개발 워크플로우 전체를 커버한다.

## 설치 방법

아래 프롬프트를 AI code agent에게 붙여넣는다. (Claude Code, Codex, Cursor 등)

```
Configure SEAMOS Java agent settings by following the instructions here:
curl -s https://raw.githubusercontent.com/AGMO-Inc/agmo-agent/refs/heads/main/feature_java/installation.md
```

이후 Agent의 지시사항을 따르면 된다.

## 에이전트 (3종)

| 에이전트 | 모델 | 역할 |
|----------|------|------|
| **seamos-builder** | Sonnet | FIF 빌드, Custom UI 클론/배포. Docker 기반 빌드 파이프라인, Maven 의존성, React+Vite 배포 처리 |
| **seamos-dev** | Sonnet | REST 엔드포인트, WebSocket 핸들러, Cloud 업로드 서비스 코드 생성. Repository-Service-Entity 패턴 준수 |
| **seamos-tester** | Sonnet | curl 테스트 생성, 앱 빌드/기동 후 API 자동 검증, OpenAPI 3.0 문서 생성 |

## 스킬 (10종)

### 개발 스킬

| 스킬 | 트리거 키워드 | 에이전트 | 설명 |
|------|---------------|----------|------|
| **seamos-rest** | `rest`, `api`, `rest endpoint` | seamos-dev | REST API CRUD 코드 생성 (Repository + Service + Entity + 등록) |
| **seamos-ws** | `websocket`, `ws`, `broadcastMessage` | seamos-dev | WebSocket send/receive/handler 코드 생성 |
| **cloud-upload** | `cloud upload`, `uploadData` | seamos-dev | Cloud uploadData 호출 REST 엔드포인트 생성 |

### 빌드/배포 스킬

| 스킬 | 트리거 키워드 | 에이전트 | 설명 |
|------|---------------|----------|------|
| **build-fif** | `build fif`, `fif 빌드`, `배포 빌드` | seamos-builder | Docker 기반 FIF 배포 파일 자동 빌드 (7단계 자동화) |
| **custom-ui-clone** | `custom-ui`, `react template` | seamos-builder | AGMO Custom UI React 프리셋 템플릿 클론 |
| **custom-ui-deploy** | `deploy ui`, `ui 배포`, `ui 빌드` | seamos-builder | Custom UI npm 빌드 → 앱 ui/ 디렉토리 배포 |

### 테스트/문서 스킬

| 스킬 | 트리거 키워드 | 에이전트 | 설명 |
|------|---------------|----------|------|
| **rest-test** | `테스트`, `test`, `curl 테스트` | seamos-tester | REST API curl 테스트 마크다운 자동 생성 |
| **rest-verifier** | `verify`, `검증`, `api 검증` | seamos-tester | 앱 빌드/기동 → curl 실행 → 응답 검증 → 리포트 |
| **rest-docs** | `swagger`, `docs`, `문서` | seamos-tester | REST 엔드포인트 분석 후 OpenAPI 3.0 JSON 자동 생성 |

### 유틸리티 스킬

| 스킬 | 트리거 키워드 | 에이전트 | 설명 |
|------|---------------|----------|------|
| **h2-console** | `h2`, `db console`, `database` | — | H2 DB 웹 콘솔 실행/종료 (브라우저에서 DB 조회) |

## 워크플로우

```
개발 흐름:
  /seamos-rest POST GpsData     → REST API 코드 생성
  /seamos-ws send gpsLocation   → WebSocket 전송 코드 추가
  /cloud-upload GpsData         → Cloud 업로드 엔드포인트 추가

테스트 흐름:
  /rest-test all                → curl 테스트 문서 생성
  /rest-verifier all            → 빌드 → 기동 → 테스트 → 검증 → 리포트

문서화:
  /rest-docs all                → OpenAPI 3.0 JSON 생성

빌드/배포 흐름:
  /custom-ui                    → React 템플릿 클론
  /deploy-ui custom-ui-react-template → UI 빌드 및 앱 배포
  /build-fif                    → FIF 배포 파일 빌드

디버깅:
  /h2-console                   → H2 DB 웹 콘솔로 데이터 확인
```

## 기술 스택

| 영역 | 기술 |
|------|------|
| HTTP 프레임워크 | Spark Java |
| JSON | Gson |
| 데이터베이스 | H2 (임베디드 파일 DB) |
| 빌드 | Maven (jar-with-dependencies) |
| 배포 | Docker + FIF |
| Custom UI | React + Vite + TanStack Router |
| WebSocket | Jetty WebSocket (`@WebSocket`) |
| Cloud | SEAMOS Cloud Plugin (`uploadData`) |

## 프로젝트 구조 요구사항

스킬이 정상 작동하려면 SEAMOS 표준 프로젝트 구조를 따라야 한다:

```
<FEATURE_NAME>/
├── com.bosch.fsp.<name>/        ← FSP
├── com.bosch.fsp.<name>.gen/    ← gen (Generated code)
├── {projName}/                  ← 앱 디렉토리 (pom.xml 포함)
│   ├── pom.xml
│   ├── src/com/bosch/nevonex/main/
│   │   ├── impl/               ← ApplicationMain, Agnote, UIWebsocketEndPoint
│   │   └── rest/               ← REST 도메인 코드
│   ├── disk/                   ← H2 DB 파일
│   └── feature.config          ← CustomUIPort 등 설정
└── output/fif_output/           ← FIF 빌드 결과물
```

`{projName}`은 프로젝트마다 다르며, 스킬이 `pom.xml` 기반으로 자동 감지한다.
