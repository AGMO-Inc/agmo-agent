---
name: fdk-cloud-d2d
description: "(feature - Skill) NEVONEX FDK Cloud 업로드/다운로드, Device-to-Device(D2D) 통신, FileProvider 디스크 저장, Agri-Router 파일 API 가이드. Feature에서 클라우드로 데이터를 전송하거나, 장비 간 직접 통신하거나, 로컬 디스크에 파일을 저장/조회하거나, Agri-Router를 통해 농업 데이터를 교환할 때 사용한다. '클라우드 업로드', '클라우드 다운로드', 'D2D 통신', '장비간 통신', '파일 저장', 'saveToDisk', 'FileProvider', 'Agri-Router', '디스크 저장/읽기' 같은 요청에서 사용한다."
---

# FDK Cloud & D2D

## Overview

NEVONEX Feature는 네 가지 데이터 전송 경로를 지원한다: Cloud(서버 업로드/다운로드), D2D(장비 간 직접 통신), FileProvider(로컬 디스크 영속 저장), Agri-Router(농업 데이터 교환 플랫폼). 각 경로는 독립적으로 사용하거나 조합할 수 있다.

## Cloud API

### 데이터 업로드

```cpp
#include <nevonex/cloud/Cloud.h>

auto cloud = Cloud::getInstance();

// 문자열 데이터 업로드
std::string jsonData = "{\"temperature\": 25.3, \"humidity\": 60}";
cloud->uploadData(jsonData, 1, ConnectionTypeEnum::WIFI);

// 파일 업로드
cloud->uploadFile("/path/to/logfile.csv", 2, ConnectionTypeEnum::WIFI);
```

### 매개변수

| 매개변수 | 타입 | 설명 |
|----------|------|------|
| data/filePath | string | 전송할 데이터 또는 파일 경로 |
| priority | int | 우선순위 (1=높음, 숫자 클수록 낮음) |
| connectionType | ConnectionTypeEnum | `WIFI` 또는 `SATELLITE` |

### 데이터 다운로드

```cpp
cloud->downloadData([](const std::string& data) {
    NEVONEX_LOG(SeverityLevel::info) << "수신: " << data;
    processCloudData(data);
});
```

### 연결 타입

| 타입 | 용도 |
|------|------|
| `ConnectionTypeEnum::WIFI` | WiFi 환경 (빠르고 비용 없음) |
| `ConnectionTypeEnum::SATELLITE` | 셀룰러/위성 (느리지만 어디서든 가능) |

## Device-to-Device (D2D)

### 명령 전송

```cpp
#include <nevonex/d2d/Device2Device.h>

auto d2d = Device2Device::getInstance();

// 다른 장비로 명령 전송
d2d->sendCommand("target_device_id", "START_SYNC");

// 파일 전송
d2d->sendFile("target_device_id", "/path/to/config.json");
```

### 수신 리스너

```cpp
/*PROTECTED REGION ID(d2d_listener) ENABLED START*/
void D2DListenerImpl::onCommandReceived(const std::string& senderId,
                                         const std::string& command) {
    NEVONEX_LOG(SeverityLevel::info) << "D2D from " << senderId << ": " << command;
    if (command == "START_SYNC") {
        startSynchronization(senderId);
    }
}

void D2DListenerImpl::onFileReceived(const std::string& senderId,
                                      const std::string& filePath) {
    NEVONEX_LOG(SeverityLevel::info) << "File from " << senderId << ": " << filePath;
    processReceivedFile(filePath);
}
/*PROTECTED REGION END*/
```

## FileProvider (로컬 디스크)

CCU 로컬 디스크에 데이터를 영속적으로 저장/조회/삭제한다.

### 저장

```cpp
#include <nevonex/file/FileProvider.h>

auto& fileProvider = FileProvider::getInstance();

// 파일 저장
fileProvider.saveToDisk("config", "my_settings.json", configJsonString);
fileProvider.saveToDisk("logs", "session_001.csv", csvContent);
```

### 조회

```cpp
// 특정 카테고리의 모든 파일 조회
auto files = fileProvider.retrieveAllFilesFromDisk("config");
for (auto& file : files) {
    NEVONEX_LOG(SeverityLevel::info) << "File: " << file.name << ", size: " << file.size;
    std::string content = file.getContent();
}

// 특정 파일 조회
auto content = fileProvider.retrieveFromDisk("config", "my_settings.json");
```

### 삭제

```cpp
fileProvider.deleteFromDisk("logs", "session_001.csv");
```

### 매개변수

| 매개변수 | 설명 |
|----------|------|
| category | 저장 카테고리 (폴더와 유사) |
| fileName | 파일 이름 |
| content | 파일 내용 (문자열) |

## Agri-Router API

농업 데이터 교환 플랫폼(Agri-Router)을 통한 파일 전송.

### 파일 업로드

```cpp
#include <nevonex/agrirouter/AgriRouter.h>

// Agri-Router로 파일 업로드
uploadAgriRouterFile("/path/to/taskdata.xml", "application/xml");
```

### TMT (Task Management Transfer) 목록

```cpp
// 사용 가능한 TMT 파일 목록 조회
auto tmtList = getAgriRouterTMTList();
for (auto& tmt : tmtList) {
    NEVONEX_LOG(SeverityLevel::info) << "TMT: " << tmt.name << " (" << tmt.type << ")";
}
```

## 사용 패턴

### 정기 클라우드 업로드 (Process Timer)

```cpp
void Controller::init() {
    addProcessTimer("cloud_sync", 30000, [this]() {
        // 30초마다 센서 데이터 클라우드 업로드
        Json::Value data;
        data["position"] = getPositionJson();
        data["rate"] = currentRate;
        data["timestamp"] = getCurrentTimestamp();
        Cloud::getInstance()->uploadData(data.toStyledString(), 2, ConnectionTypeEnum::WIFI);
    });
}
```

### 오프라인 버퍼링

```cpp
void uploadOrBuffer(const std::string& data) {
    if (isCloudAvailable()) {
        Cloud::getInstance()->uploadData(data, 1, ConnectionTypeEnum::WIFI);
    } else {
        // 오프라인이면 디스크에 저장, 나중에 전송
        auto& fp = FileProvider::getInstance();
        fp.saveToDisk("pending_upload", generateFileName(), data);
    }
}
```

## Resources

### references/
- `cloud-d2d-api.md` — Cloud/D2D 전체 API 레퍼런스, 에러 처리, 재시도 전략, Java SDK 대응 API
- `file-storage-patterns.md` — FileProvider 고급 패턴, 용량 관리, Agri-Router 연동 상세
