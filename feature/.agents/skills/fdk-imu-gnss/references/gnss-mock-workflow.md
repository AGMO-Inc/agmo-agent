# GnssMock 클래스 상세

## 클래스 구조

```cpp
class GnssMock {
public:
    GnssMock();
    ~GnssMock();

    // CSV 데이터 로드
    void loadFromCSV(const std::string& filePath);

    // 측정 시뮬레이션 (10Hz로 호출)
    void measure();

    // 연결 상태
    bool isConnected() const;

    // 현재 GNSS 데이터
    GnssData getGnssData() const;

    // 리셋 (처음부터 다시)
    void reset();

    // 현재 인덱스
    int getCurrentIndex() const;

    // 총 데이터 포인트 수
    int getTotalPoints() const;
};
```

## CSV 파일 준비

### 필수 컬럼

```csv
latitude,longitude,altitude,heading,speed
```

### 선택 컬럼 (지원 시)

```csv
latitude,longitude,altitude,heading,speed,hdop,satellites,fix_quality
```

### 좌표 형식

- **Latitude**: Decimal Degrees (-90 ~ 90)
- **Longitude**: Decimal Degrees (-180 ~ 180)
- **Altitude**: 미터 (해수면 기준)
- **Heading**: 도 (0-360, 북=0, 동=90)
- **Speed**: m/s

### 예시: 직선 경로

```csv
latitude,longitude,altitude,heading,speed
52.520000,13.404900,34.0,90.0,3.0
52.520000,13.405000,34.0,90.0,3.0
52.520000,13.405100,34.0,90.0,3.0
52.520000,13.405200,34.0,90.0,3.0
52.520000,13.405300,34.0,90.0,3.0
```

### 예시: 곡선 경로 (필드 끝 U턴)

```csv
latitude,longitude,altitude,heading,speed
52.520000,13.404900,34.0,90.0,3.0
52.520000,13.405500,34.0,90.0,3.0
52.520050,13.405600,34.0,135.0,2.0
52.520100,13.405600,34.0,180.0,2.0
52.520150,13.405600,34.0,225.0,2.0
52.520200,13.405500,34.0,270.0,3.0
52.520200,13.404900,34.0,270.0,3.0
```

## Controller에서의 사용

### 기본 통합

```cpp
// Controller.h - Protected Region 내 멤버 선언
/*PROTECTED REGION ID(controller_h_members) ENABLED START*/
#include "GnssMock.h"
GnssMock gnssMock;
bool useGnssMock = true;  // 테스트 모드 플래그
/*PROTECTED REGION END*/

// Controller.cpp - init()
/*PROTECTED REGION ID(controller_init) ENABLED START*/
void Controller::init() {
    if (useGnssMock) {
        gnssMock.loadFromCSV("test_route.csv");
        NEVONEX_LOG(SeverityLevel::info) << "GNSS Mock loaded: "
            << gnssMock.getTotalPoints() << " points";
    }
}
/*PROTECTED REGION END*/

// Controller.cpp - run()
/*PROTECTED REGION ID(controller_run) ENABLED START*/
void Controller::run() {
    GnssData data;

    if (useGnssMock) {
        gnssMock.measure();
        if (gnssMock.isConnected()) {
            data = gnssMock.getGnssData();
        }
    } else {
        // 실제 GNSS 하드웨어 사용
        auto gnss = ::nevonex::gnss::getGnssProvider()->getGnss();
        if (gnss->isConnected()) {
            data = gnss->getGnssData();
        }
    }

    // 위치 데이터 처리 (Mock/실제 동일한 로직)
    processPosition(data);
}
/*PROTECTED REGION END*/
```

### Mock/실제 전환

```cpp
// WebSocket으로 Mock 모드 전환
void Controller::onWebSocketJsonMessage(Json::Value& msg) {
    if (msg["type"].asString() == "set_mock_mode") {
        useGnssMock = msg["enabled"].asBool();
        if (useGnssMock) {
            gnssMock.reset();
            NEVONEX_LOG(SeverityLevel::info) << "GNSS Mock mode ON";
        } else {
            NEVONEX_LOG(SeverityLevel::info) << "GNSS Mock mode OFF (using hardware)";
        }
    }
}
```

## 테스트 시나리오 작성

### 시나리오 1: 직선 주행

CSV에서 latitude는 고정, longitude를 점진적으로 증가. heading=90 (동쪽).

### 시나리오 2: 필드 왕복

```
→ 동쪽 직선 → U턴 → 서쪽 직선 → U턴 → 반복
```

### 시나리오 3: 정지 상태

모든 행에 동일한 좌표, speed=0. 정지 시 동작 테스트용.

### 시나리오 4: 속도 변화

동일 경로에서 speed를 0→max→0으로 변화. 가감속 테스트용.

## 주의사항

- `measure()`는 반드시 10Hz로 호출 (run()에서 매번)
- CSV 끝에 도달하면 마지막 위치에서 정지 (반복하려면 `reset()` 호출)
- Mock 데이터의 좌표 간격이 speed와 일치하는지 확인 (10Hz 기준 100ms당 이동 거리)
- 배포 빌드에서는 Mock 코드를 비활성화하거나 컴파일 제외
