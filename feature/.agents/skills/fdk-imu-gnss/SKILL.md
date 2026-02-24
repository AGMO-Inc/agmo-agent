---
name: fdk-imu-gnss
description: "(feature - Skill) NEVONEX FDK IMU/GNSS 센서 API 가이드. 6축 IMU(Roll/Pitch/Yaw, 가속도, 각속도) 읽기와 GNSS(위도/경도/고도/방위/속도) 데이터 처리, GnssMock 클래스를 이용한 NMEA-0183 파싱, CSV 기반 목 데이터 테스트 워크플로우를 다룬다. Feature에서 위치/자세 데이터를 활용하거나 GNSS 목 테스트를 구현할 때 사용한다. 'IMU 데이터 읽기', 'GNSS 좌표', 'GPS 위치', '자세 감지', 'Roll/Pitch/Yaw', 'NMEA 파싱', 'GNSS 목 테스트', 'CSV 목 데이터' 같은 요청에서 사용한다."
---

# FDK IMU/GNSS

## Overview

CCU는 내장 6축 IMU와 외부 GNSS 수신기를 지원한다. IMU는 자세(Roll/Pitch/Yaw)와 가속도/각속도를, GNSS는 위치/방위/속도 데이터를 제공한다. GnssMock 클래스로 NMEA 데이터를 시뮬레이션할 수 있다.

## IMU API

### 자세 (Angle)

```cpp
#include <nevonex/imu/IMUProvider.h>

auto imu = ::nevonex::imu::getIMUProvider()->getIMU();
auto angle = imu->getAngle();

double roll  = angle->getROLL();    // X축 회전 (도)
double pitch = angle->getPITCH();   // Y축 회전 (도)
double yaw   = angle->getYAW();     // Z축 회전 (도)
```

### 가속도 (Acceleration)

```cpp
auto accl = imu->getAccl();

double ax = accl->getX();    // X축 가속도 (m/s^2)
double ay = accl->getY();    // Y축 가속도 (m/s^2)
double az = accl->getZ();    // Z축 가속도 (m/s^2)
```

### 각속도 (Angular Rate)

```cpp
auto rate = imu->getRate();

double rx = rate->getX();    // X축 각속도 (deg/s)
double ry = rate->getY();    // Y축 각속도 (deg/s)
double rz = rate->getZ();    // Z축 각속도 (deg/s)
```

### 사용 패턴

```cpp
void Controller::run() {
    auto imu = ::nevonex::imu::getIMUProvider()->getIMU();

    // 경사 보정 예시
    double pitch = imu->getAngle()->getPITCH();
    if (std::abs(pitch) > 15.0) {
        NEVONEX_LOG(SeverityLevel::warning) << "경사 과대: " << pitch << "도";
        adjustForSlope(pitch);
    }

    // UI로 자세 데이터 전송
    Json::Value msg;
    msg["roll"] = imu->getAngle()->getROLL();
    msg["pitch"] = pitch;
    msg["yaw"] = imu->getAngle()->getYAW();
    wsEndpoint->publishMessage(msg);
}
```

## GNSS API

### GnssData 구조체

```cpp
struct GnssData {
    double latitude;     // 위도 (decimal degrees)
    double longitude;    // 경도 (decimal degrees)
    double altitude;     // 고도 (미터)
    double heading;      // 방위각 (도, 0-360)
    double speed;        // 속도 (m/s)
};
```

### 읽기 패턴

```cpp
#include <nevonex/gnss/GnssProvider.h>

auto gnss = ::nevonex::gnss::getGnssProvider()->getGnss();

if (gnss->isConnected()) {
    GnssData data = gnss->getGnssData();
    double lat = data.latitude;
    double lng = data.longitude;
    double alt = data.altitude;
    double hdg = data.heading;
    double spd = data.speed;
}
```

## GnssMock (테스트용)

### 개요

`GnssMock` 클래스는 실제 GNSS 하드웨어 없이 NMEA-0183 데이터를 시뮬레이션한다. CSV 파일에서 좌표를 읽어 순차적으로 공급한다.

### 기본 사용

```cpp
#include "GnssMock.h"

// CSV에서 경로 데이터 로드
GnssMock mock;
mock.loadFromCSV("test_route.csv");

// 측정 시뮬레이션 (10Hz로 호출)
void Controller::run() {
    mock.measure();  // 다음 지점으로 이동

    if (mock.isConnected()) {
        GnssData data = mock.getGnssData();
        processPosition(data.latitude, data.longitude);
    }
}
```

### CSV 형식

```csv
latitude,longitude,altitude,heading,speed
52.520008,13.404954,34.5,90.0,5.2
52.520100,13.405100,34.6,92.0,5.3
52.520200,13.405250,34.7,91.5,5.1
```

### NMEA-0183 파싱

GnssMock은 내부적으로 NMEA 문장을 생성/파싱한다:

| 문장 | 내용 |
|------|------|
| `$GPGGA` | 위치, 고도, 위성 수, 정밀도(HDOP) |
| `$GPGST` | 위치 오차 통계 (위도/경도 표준편차) |
| `$AGRICA` | Bosch 독자 프로토콜 (고정밀 자세/위치) |

### NMEA 체크섬

```cpp
// NMEA 체크섬 계산: $와 * 사이 모든 문자의 XOR
// 예: $GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,47.0,M,,*47
uint8_t checksum = 0;
for (char c : sentence_between_dollar_and_star) {
    checksum ^= c;
}
```

## 주의사항

- IMU 데이터는 10Hz (100ms)로 갱신됨
- GNSS 정밀도는 수신 환경에 따라 변동 (RTK 보정 시 cm급, 일반 GPS는 m급)
- GnssMock은 **테스트/개발 전용** — 실제 배포에서는 하드웨어 GNSS 사용
- CSV Mock 데이터의 10Hz 주기를 맞추려면 `measure()`를 `run()`에서 매번 호출

## Resources

### references/
- `nmea-protocol.md` — NMEA-0183 문장 상세 (GGA, GST, AGRICA), CRC 계산, 파싱 예제 코드
- `gnss-mock-workflow.md` — GnssMock 클래스 전체 API, CSV 준비 방법, 테스트 시나리오 작성 가이드
