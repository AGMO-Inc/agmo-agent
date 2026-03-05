---
name: cloud-upload
description: Cloud uploadData 호출 REST 엔드포인트 생성기
triggers:
  - cloud upload
  - uploadData
  - cloud api
  - 클라우드 업로드
  - cloud 업로드
argument-hint: "help | <Name>"
aliases: [cloud-gen, seamos-cloud]
quality: high
model: sonnet
context: fork
agent: seamos-dev
---

# Cloud Upload REST Endpoint Generator

> **Agent 위임**: 이 스킬의 모든 작업은 Agent 도구를 사용하여 `seamos-dev` 에이전트에게 위임하여 실행할 것. Agent 호출 시 사용자의 요청 내용과 파싱된 인자를 프롬프트로 전달한다.

SEAMOS/NEVONEX 플랫폼의 Cloud 플러그인 `uploadData`를 호출하여 외부 API 서버에 요청을 보내는 REST 엔드포인트 코드를 자동 생성하는 스킬.

Custom UI에서 POST 요청으로 `externalUrl`, `method`, `header`, `msg`를 보내면, `correlation-id`를 자동 생성하여 JSON으로 조합한 뒤 `Cloud.getInstance().uploadData(data, priority)`로 외부 API 서버에 전달하는 서비스 클래스를 생성한다.

## When to Activate

- 사용자가 Cloud 업로드 엔드포인트 추가를 요청할 때
- "cloud upload", "uploadData", "클라우드 업로드" 등의 키워드 감지 시
- **키워드 "cloud upload" 또는 "uploadData"가 사용자 메시지에 포함되면 즉시 이 스킬을 발동할 것**

## Arguments Parsing

| 인자 패턴 | 동작 |
|-----------|------|
| `help` | 사용법 안내 출력 |
| `<Name>` | Cloud 업로드 POST 엔드포인트 생성 |

`<Name>`은 PascalCase(예: `GpsData`, `SensorReading`, `WorkLog`)로 전달됨.

---

## help 명령어

`help`가 인자일 때 아래 내용을 사용자에게 출력:

```
Cloud Upload Skill (/cloud-upload)

사용법:
  /cloud-upload help                       - 이 도움말 표시
  /cloud-upload <Name>                     - Cloud 업로드 POST 엔드포인트 생성

예시:
  /cloud-upload GpsData                    - GPS 데이터를 클라우드에 업로드하는 엔드포인트 생성
  /cloud-upload SensorReading              - 센서 데이터를 클라우드에 업로드하는 엔드포인트 생성

생성되는 파일:
  Service: {projName}/src/com/bosch/nevonex/main/rest/{domain}/{Name}CloudUploadService.java
  등록:    ApplicationMain.java → addCustomUISupport() 메소드에 추가

요청 body 형식:
  {
    "externalUrl": "https://api.example.com/data",  // 필수, 외부 API URL
    "method": "POST",                                // 필수, POST 또는 GET
    "header": {"Authorization": "Bearer ..."},       // 선택, 요청 헤더
    "msg": "{\"key\": \"value\"}",                   // 선택, 요청 본문
    "priority": 2,                                   // 선택, 1=High 2=Medium 3=Low (기본: 2)
    "connectionType": "WIFI"                         // 선택, WIFI 또는 SATELLITE (기본: WIFI)
  }

  Cloud로 전송되는 data (자동 생성):
  {
    "correlation-id": "<UUID>",
    "externalUrl": "https://api.example.com/data",
    "method": "POST",
    "header": {"Authorization": "Bearer ..."},
    "msg": "{\"key\": \"value\"}"
  }
```

---

## Cloud Upload Endpoint Generation

### `<Name>` 실행 시 수행할 작업

**2개의 작업을 순서대로 수행:**


#### 작업 1: Service 클래스 파일 생성

> 서비스 템플릿은 `.claude/skills/cloud-upload/ref/service-template.md` 를 Read하여 참조할 것

- 파일 위치: `{projName}/src/com/bosch/nevonex/main/rest/{domain}/{Name}CloudUploadService.java`
- `{domain}`은 `<Name>`을 lowercase로 변환 (예: `GpsData` → `gpsdata`)
- `BaseRestService`를 상속
- `processService()`에서 `externalUrl`, `method`, `header`, `msg`를 파싱
- `correlation-id`(UUID)를 자동 생성하여 JSON 조합 후 `Cloud.getInstance().uploadData()` 호출
- Cloud 예외 개별 catch + 범용 Exception catch

#### 작업 2: ApplicationMain에 등록 코드 추가

> 등록 코드 패턴은 `.claude/skills/cloud-upload/ref/registration-template.md` 를 Read하여 참조할 것

- `ApplicationMain.java`의 `addCustomUISupport()` 메서드에 POST 엔드포인트 등록
- 라우트: `cloud-upload/{route-path}`

---

## Notes

- Cloud 싱글톤은 `ApplicationMain.startProviders()`에서 `initPlatformService()` 호출 후 사용 가능. `addCustomUISupport()`에서 서비스를 등록하는 시점에는 이미 초기화 완료 상태.
- `uploadData`는 내부적으로 `WebserviceUtil.executeDataService()`를 호출하여 HTTP multipart POST를 수행. featureID, timestamp는 자동 첨부됨.
- `correlation-id`는 UUID v4 랜덤 문자열로 생성되는 요청 고유키. CloudDownloadListener에서 응답 수신 시 이 값으로 요청-응답을 식별한다.
- EMF 등록 (`MainPackage`, `MainFactory`)은 이 스킬의 범위 밖임.
- REST 비즈니스 코드는 반드시 `rest/{domain}/` 패키지에 생성. `impl/`에 넣지 않음.
- `processService()`의 반환값이 곧 HTTP 응답 본문. JSON 문자열 반환 권장.
