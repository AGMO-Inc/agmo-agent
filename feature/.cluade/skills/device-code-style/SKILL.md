---
name: device-code-style
description: "(feature - Skill) Device C++ 코딩 스타일, Protected Region 규칙, Controller 패턴, 프로젝트별 코딩 관행을 통합한 가이드. 코드 생성기(Feature Designer)가 생성한 파일의 Protected Region 안에서 안전하게 코드를 작성하고, Controller::run() 10Hz 루프와 Process Timer를 올바르게 구현하며, 프로젝트별 External API/JSON/로깅 규약을 따른다. Device C++ 코드를 수정/생성할 때 반드시 참조. 'C++ 코드 수정', 'Protected Region', 'ENABLED START', 'Controller run 구현', '타이머 추가', '로깅 추가', 'device 코드 작성' 같은 요청에서 사용한다. WebSocket 통신 패턴은 fdk-websocket 스킬을 참조."
---

# Device C++ Style

Device C++ 코드 수정 시 반드시 따르는 규칙을 정의한다. 생성 코드(Protected Region)와 커스텀 코드를 구분하고, 각각에 맞는 편집 규칙을 적용한다.

## 생성 코드 vs 커스텀 코드 구분

파일 상단에 `Copyright (c) Robert Bosch` 가 있는지로 구분한다.

| 구분 | 판별 기준 | Protected Region 적용 |
|------|-----------|----------------------|
| **생성 코드** | 파일 상단에 `Copyright (c) Robert Bosch` 존재 | ✅ 적용 — PR 안에서만 수정 |
| **커스텀 코드** | 해당 copyright 없음 | ❌ 미적용 — 자유롭게 수정 가능 |

생성 코드는 프로젝트 init 시 Feature Designer가 `.fpd` 모델에서 자동 생성한 파일이다. 재생성 시 Protected Region 외부는 100% 덮어써진다.

## 커스텀 코드 작성 규칙

완전히 새로 작성하는 파일(예: `MyHelper.cpp`, `utils.h`)은 Protected Region이 없으며 자유롭게 편집 가능하다. 단, 다음을 준수한다:

### 작성자 표기

커스텀 코드 파일 상단에 반드시 작성자를 명시한다:

```cpp
/**
 * @file MyHelper.cpp
 * @author <작성자명>
 * @brief <파일 설명>
 */
```

- 새 파일 생성 시 반드시 `@author` 포함
- AI가 생성한 파일이면 `@author AI generated` 표기
- 기존 커스텀 파일 수정 시 `@author`는 변경하지 않음

### 커스텀 코드에서 생성 코드 연결

- Controller에서 커스텀 파일을 사용하려면 생성 코드의 Protected Region 안에서 `#include` 추가
- CMake 등록이 필요하면 `CMakeLists.txt`의 Protected Region에 추가

## Protected Region 규칙 (생성 코드 전용)

`Copyright (c) Robert Bosch`가 있는 파일에만 적용된다.

### 식별 방법

Protected Region은 다음 주석 쌍으로 감싸진다:

```cpp
/*PROTECTED REGION ID(identifier_string) ENABLED START*/
// 여기에 사용자 코드 작성
/*PROTECTED REGION END*/
```

**핵심 규칙:**
- `ENABLED` 키워드가 있어야 코드가 보존됨
- `ENABLED`가 없으면 재생성 시 내용이 덮어써짐
- Protected Region **외부**의 수정은 재생성 시 100% 소실됨
- ID는 고유하며, Feature Designer가 자동 생성

### ENABLED START 변환 규칙

생성된 파일에서 Protected Region을 처음 활성화할 때 `START` → `ENABLED START` 변환이 필요하다:

```
변환 전: /*PROTECTED REGION ID(...) START*/
변환 후: /*PROTECTED REGION ID(...) ENABLED START*/
```

**변환 조건:**
- `Copyright (c) Robert Bosch`가 있는 파일 → `ENABLED START` 변환 필수
- 이미 `ENABLED START`인 블록 → 변환하지 않음

### 작업 지침

1. **파일 읽기 필수**: 수정 전 반드시 파일 전체를 읽고 기존 수동 변경 확인
2. **코드 수정 전**: 해당 위치가 Protected Region 안인지 확인
3. **새 로직 추가**: 가장 가까운 Protected Region을 찾아 그 안에 작성
4. **Protected Region 외부**: 절대 수정하지 않음 (재생성 시 소실)
5. **`ENABLED` 확인**: 반드시 `ENABLED` 키워드가 포함된 블록에만 작성

### 일반적인 Protected Region 위치

| 위치 | 용도 |
|------|------|
| `Controller.cpp` 상단 | `#include` 추가 |
| `Controller::init()` 내부 | 초기화 로직 |
| `Controller::run()` 내부 | 메인 제어 루프 로직 |
| `Controller::shutdown()` 내부 | 종료 정리 로직 |
| Listener 콜백 내부 | 이벤트 핸들러 로직 |

## Controller::run() 패턴

`Controller::run()`은 **10Hz (100ms 주기)**로 SEAMOS가 자동 호출하는 메인 루프다.

### 기본 구조

```cpp
/*PROTECTED REGION ID(controller_run) ENABLED START*/
void Controller::run() {
    // 센서 데이터 읽기
    auto rate = implement->getBoom(0)->getChannel(0)->getActualApplicationRate();

    // 비즈니스 로직
    if (rate.is_Valid()) {
        double value = rate.getValue();
        // 처리 로직...
    }

    // UI로 데이터 전송
    Json::Value msg;
    msg["rate"] = value;
    wsEndpoint->publishMessage(msg);
}
/*PROTECTED REGION END*/
```

### 주의사항

- `run()`은 100ms마다 호출 → **블로킹 연산 금지** (파일 I/O, 네트워크 등)
- 무거운 작업은 Process Timer로 분리
- 상태 변수는 클래스 멤버로 선언 (run() 내 static 변수 지양)

## Process Timer

10Hz보다 긴 주기의 작업이 필요할 때 사용한다.

### 등록 (init에서)

```cpp
/*PROTECTED REGION ID(controller_init) ENABLED START*/
void Controller::init() {
    // 5초마다 실행되는 타이머
    addProcessTimer("cloud_upload", 5000, [this]() {
        Cloud::getInstance()->uploadData(sensorData, 1, ConnectionTypeEnum::WIFI);
    });

    // 1초마다 실행되는 타이머
    addProcessTimer("status_check", 1000, [this]() {
        checkMachineStatus();
    });
}
/*PROTECTED REGION END*/
```

### 매개변수

| 매개변수 | 타입 | 설명 |
|----------|------|------|
| name | string | 타이머 고유 이름 |
| interval_ms | int | 실행 주기 (밀리초) |
| callback | function | 실행할 함수/람다 |

### 사용 지침

- `run()` 안에서 등록하지 않음 (10Hz마다 중복 등록됨)
- `init()`에서 한 번만 등록
- 타이머 이름은 고유해야 함
- 콜백 내에서도 블로킹 최소화

## 로깅

NEVONEX 로거 사용. severity 선택은 의도적이고 일관적으로:

```cpp
NEVONEX_LOG(SeverityLevel::info) << "Rate value: " << value;
NEVONEX_LOG(SeverityLevel::debug) << "Debug message";
NEVONEX_LOG(SeverityLevel::warning) << "Warning message";
NEVONEX_LOG(SeverityLevel::error) << "Error occurred: " << errorMsg;
```

## 프로젝트별 코딩 관행

### WebSocket 통신

WebSocket 코드 스타일과 메시지 패턴은 **fdk-websocket** 스킬을 참조한다.

### External API

Cloud 프록시 경유 외부 REST API 호출 패턴은 **fdk-external-api** 스킬을 참조한다.

## Device 수정 체크리스트

코드 수정 전 반드시 점검:

1. 대상 파일을 수정 전에 읽었는가?
2. `Copyright (c) Robert Bosch`가 있는 파일이면 Protected Region 안에서만 수정하는가?
3. `START`만 있는 블록을 `ENABLED START`로 변환했는가?
4. External API 호출이 필요하면 `fdk-external-api` 스킬 패턴을 따르는가?
6. 로깅 레벨 선택이 의도적이고 일관적인가?
7. 무관한 포맷팅이나 생성 코드 변경이 없는가?
8. 커스텀 코드 파일에 `@author` 표기가 있는가?

## Resources

### references/
- `code-generation-rules.md` — Protected Region 상세 규칙, 코드 재생성 안전 가이드, 파일별 PR 매핑, 안티패턴 목록
