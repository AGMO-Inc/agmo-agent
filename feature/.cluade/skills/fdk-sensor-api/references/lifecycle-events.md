# 라이프사이클 이벤트 상세

## 이벤트 순서

Feature의 전체 라이프사이클:

```
1. Feature 설치 (FIF → CCU)
2. Feature 초기화 → Controller::init()
3. Machine 연결 → machineConnect()
4. Feature 시작 → handleFeatureStart()
5. Controller::run() 루프 (10Hz)
6. Feature 중지 → handleFeatureStop()
7. Machine 연결 해제 → machineDisconnected()
8. Feature 종료 → Controller::shutdown()
```

## Machine Connect / Disconnect

### 발생 시점

- **Connect**: 농기계 ECU와 CAN 통신이 성공적으로 수립될 때
- **Disconnect**: CAN 통신이 끊어질 때 (전원 OFF, 케이블 분리, 통신 에러)

### 구현 패턴

```cpp
/*PROTECTED REGION ID(machine_connect) ENABLED START*/
void Controller::machineConnect() {
    NEVONEX_LOG(SeverityLevel::info) << "Machine connected";

    // 1. 상태 플래그 설정
    isConnected = true;

    // 2. 기본값 초기화
    currentRate = 0.0;
    totalVolume = 0.0;

    // 3. UI에 연결 상태 알림
    Json::Value msg;
    msg["type"] = "connection_status";
    msg["connected"] = true;
    wsEndpoint->publishMessage(msg);
}

void Controller::machineDisconnected() {
    NEVONEX_LOG(SeverityLevel::warning) << "Machine disconnected";

    // 1. 상태 플래그 해제
    isConnected = false;

    // 2. 안전 상태로 전환 (제어값 0으로)
    if (implement) {
        implement->getBoom(0)->getChannel(0)->setSetpointApplicationRate(0.0);
    }

    // 3. UI에 연결 해제 알림
    Json::Value msg;
    msg["type"] = "connection_status";
    msg["connected"] = false;
    wsEndpoint->publishMessage(msg);
}
/*PROTECTED REGION END*/
```

### run()에서의 연결 상태 체크

```cpp
void Controller::run() {
    if (!isConnected) {
        // 연결 안 된 상태에서는 센서 읽기 스킵
        return;
    }
    // 정상 로직...
}
```

## Feature Start / Stop

### 발생 시점

- **Start**: 사용자가 UI에서 Feature를 활성화하거나, 농기계 작업 시작 시
- **Stop**: 사용자가 Feature를 비활성화하거나, 작업 종료 시

### 구현 패턴

```cpp
/*PROTECTED REGION ID(feature_lifecycle) ENABLED START*/
void FeatureManagerListenerImpl::handleFeatureStart() {
    NEVONEX_LOG(SeverityLevel::info) << "Feature started";

    // 1. 작업 세션 시작
    sessionStartTime = std::chrono::system_clock::now();
    sessionActive = true;

    // 2. 데이터 로깅 시작
    startDataLogging();

    // 3. 클라우드에 시작 알림
    Cloud::getInstance()->uploadData("{\"event\": \"feature_start\"}", 1, ConnectionTypeEnum::WIFI);
}

void FeatureManagerListenerImpl::handleFeatureStop() {
    NEVONEX_LOG(SeverityLevel::info) << "Feature stopped";

    // 1. 작업 세션 종료
    sessionActive = false;

    // 2. 데이터 로깅 종료 + 저장
    stopDataLogging();
    saveSessionData();

    // 3. 클라우드에 종료 알림 + 세션 요약 업로드
    uploadSessionSummary();
}
/*PROTECTED REGION END*/
```

## QR Code 스캔

### 발생 시점

- 사용자가 CCU의 QR 스캔 기능으로 QR 코드를 읽을 때

### 활용 예시

```cpp
/*PROTECTED REGION ID(qr_listener) ENABLED START*/
void QRCodeListenerImpl::onMessageRead(std::string message) {
    NEVONEX_LOG(SeverityLevel::info) << "QR scanned: " << message;

    // QR 타입 판별
    if (message.find("CONFIG:") == 0) {
        // 설정 QR 코드
        std::string configData = message.substr(7);
        applyConfiguration(configData);
    } else if (message.find("FIELD:") == 0) {
        // 필드 식별 QR 코드
        std::string fieldId = message.substr(6);
        loadFieldData(fieldId);
    } else {
        // 일반 텍스트
        NEVONEX_LOG(SeverityLevel::info) << "Unknown QR format: " << message;
    }
}
/*PROTECTED REGION END*/
```

### QR 코드 활용 시나리오

| QR 내용 | 용도 |
|---------|------|
| 설정 JSON | 빠른 Feature 설정 적용 |
| 필드 ID | 농지 식별 및 데이터 연동 |
| 라이선스 키 | Feature 활성화 |
| 장비 ID | D2D 페어링 |

## 에러 처리 지침

### 라이프사이클 이벤트에서의 에러

- 라이프사이클 콜백에서 예외가 발생하면 Feature가 불안정해질 수 있음
- **반드시 try-catch로 감싸기**
- 에러 시에도 상태 플래그는 올바르게 설정

```cpp
void Controller::machineConnect() {
    try {
        // 초기화 로직...
        isConnected = true;
    } catch (const std::exception& e) {
        NEVONEX_LOG(SeverityLevel::error) << "Connect error: " << e.what();
        isConnected = false;  // 실패 시에도 상태 일관성 유지
    }
}
```
