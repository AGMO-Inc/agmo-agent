---
name: fdk-sensor-api
description: "(feature - Skill) NEVONEX FDK 센서 데이터 읽기/쓰기 API 가이드. Implement-Boom-Section-Channel-SubChannel 계층 구조와 BulkProcessor, Machine Connect/Disconnect, Feature Start/Stop, QR Scan, Invalid Value 처리를 다룬다. Feature에서 농기계 센서 데이터를 읽거나 제어값을 설정하는 코드를 작성할 때 사용한다. '센서 데이터 읽기', '센서값 쓰기', 'Channel 접근', 'Implement 구조', 'BulkProcessor', 'Machine Connect', 'Feature Start/Stop', 'QR 스캔', '유효성 검사', 'Invalid Value' 같은 요청에서 사용한다."
---

# FDK Sensor API

## Overview

NEVONEX Feature는 Implement(작업기) 계층 구조를 통해 센서 데이터를 읽고 제어값을 쓴다. 계층: **Implement → Boom → Section → Channel → SubChannel**. 이 스킬은 데이터 R/W, 일괄 처리(BulkProcessor), 라이프사이클 이벤트, 유효값 검증을 다룬다.

## 데이터 계층 구조

```
Implement (작업기 전체)
├── Boom[0..N] (작업기 붐/암)
│   ├── Section[0..N] (섹션)
│   │   └── Channel[0..N] (채널)
│   │       └── SubChannel[0..N] (하위 채널)
│   └── Channel[0..N] (붐 직속 채널)
└── Machine Data (기계 전체 데이터)
```

### 접근 패턴 (C++)

```cpp
// Implement 객체 (Controller 멤버로 제공됨)
auto boom = implementObj->getBoom(0);           // 0번 Boom
auto section = boom->getSection(0);             // 0번 Section
auto channel = boom->getChannel(0);             // Boom 직속 Channel
auto subChannel = channel->getSubChannel(0);    // SubChannel
```

## 데이터 읽기 (Read)

### 단일 값 읽기

```cpp
// Application Rate 읽기
auto rate = implement->getBoom(0)->getChannel(0)->getActualApplicationRate();
if (rate.is_Valid()) {
    double value = rate.getValue();
    uint64_t timestamp = rate.getValue_Timestamp();
    NEVONEX_LOG(SeverityLevel::info) << "Rate: " << value;
}

// Machine 데이터 읽기
auto speed = implement->getActualWorkingSpeed();
auto width = implement->getMaximumWorkingWidth();
auto fuel = implement->getFuelConsumption();
```

### 유효값 검증 (필수!)

**모든 센서 값은 반드시 유효성 검사 후 사용:**

```cpp
auto value = channel->getActualApplicationRate();

// 방법 1: is_Valid() 체크
if (value.is_Valid()) {
    double v = value.getValue();
}

// 방법 2: Timestamp 체크 (0이면 아직 갱신 안 됨)
if (value.getValue_Timestamp() > 0) {
    double v = value.getValue();
}
```

**주의:** `is_Valid() == false`인 값을 사용하면 의미 없는 기본값(0 또는 NaN)이 반환됨.

## 데이터 쓰기 (Write)

### 단일 값 쓰기

```cpp
// Setpoint (목표값) 설정
implement->getBoom(0)->getChannel(0)->setSetpointApplicationRate(25.5);

// Working Width 설정
implement->setMaximumWorkingWidth(6.0);
```

### BulkProcessor (일괄 쓰기)

여러 값을 **원자적으로** 한 번에 설정할 때 사용:

```cpp
// BulkProcessor 획득
auto bulkProcessor = implement->getBulkProcessor();

// 값 설정 (아직 적용 안 됨)
bulkProcessor->setSetpointApplicationRate(0, 0, 25.5);  // boom, channel, value
bulkProcessor->setSetpointApplicationRate(0, 1, 30.0);
bulkProcessor->setSetpointApplicationRate(1, 0, 20.0);

// 모든 값 한 번에 적용
bulkProcessor->executeBulkOperations();
```

**BulkProcessor 장점:**
- 모든 값이 동시에 적용 (채널 간 동기화)
- 부분 적용 방지 (원자성)
- 여러 채널을 개별 set하면 타이밍 불일치 발생 가능

## 라이프사이클 이벤트

### Machine Connect / Disconnect

```cpp
/*PROTECTED REGION ID(machine_connect) ENABLED START*/
void Controller::machineConnect() {
    NEVONEX_LOG(SeverityLevel::info) << "Machine connected";
    // 초기화: 기본값 설정, 상태 리셋 등
    isConnected = true;
}

void Controller::machineDisconnected() {
    NEVONEX_LOG(SeverityLevel::info) << "Machine disconnected";
    // 정리: 안전 상태로 전환
    isConnected = false;
}
/*PROTECTED REGION END*/
```

### Feature Start / Stop

```cpp
/*PROTECTED REGION ID(feature_lifecycle) ENABLED START*/
void FeatureManagerListenerImpl::handleFeatureStart() {
    NEVONEX_LOG(SeverityLevel::info) << "Feature started";
    // Feature 활성화 시 로직
}

void FeatureManagerListenerImpl::handleFeatureStop() {
    NEVONEX_LOG(SeverityLevel::info) << "Feature stopped";
    // Feature 비활성화 시 정리
}
/*PROTECTED REGION END*/
```

### QR Code 스캔

```cpp
/*PROTECTED REGION ID(qr_listener) ENABLED START*/
void QRCodeListenerImpl::onMessageRead(std::string message) {
    NEVONEX_LOG(SeverityLevel::info) << "QR: " << message;
    // QR 코드 내용 처리
    parseQRData(message);
}
/*PROTECTED REGION END*/
```

## Java SDK 대응

| C++ | Java |
|-----|------|
| `implementObj->getBoom(0)` | `implementProvider.getBoom(0)` |
| `channel->getActualApplicationRate()` | `channel.getActualApplicationRate()` |
| `channel->setSetpointApplicationRate(v)` | `channel.setSetpointApplicationRate(v)` |
| `bulkProcessor->executeBulkOperations()` | `bulkProcessor.executeBulkOperations()` |
| `NEVONEX_LOG(SeverityLevel::info)` | `FCALLogs.getInstance().log.info(...)` |

## Resources

### references/
- `data-hierarchy.md` — Implement 계층 전체 속성 목록, 데이터 타입별 R/W 가능 여부, Java 상세 API
- `lifecycle-events.md` — Machine Connect/Disconnect, Feature Start/Stop, QR Scan 상세 시나리오와 에러 처리 패턴
