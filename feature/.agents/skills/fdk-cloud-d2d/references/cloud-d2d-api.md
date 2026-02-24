# Cloud & D2D API 레퍼런스

## Cloud API 전체

### C++ API

```cpp
#include <nevonex/cloud/Cloud.h>

auto cloud = Cloud::getInstance();

// 데이터 업로드
cloud->uploadData(const std::string& data, int priority, ConnectionTypeEnum connectionType);

// 파일 업로드
cloud->uploadFile(const std::string& filePath, int priority, ConnectionTypeEnum connectionType);

// 데이터 다운로드 (비동기 콜백)
cloud->downloadData(std::function<void(const std::string&)> callback);

// 연결 상태 확인
bool connected = cloud->isConnected();
```

### Java API

```java
import com.bosch.seamos.cloud.CloudService;

CloudService cloudService = CloudService.getInstance();

// 데이터 업로드
cloudService.uploadData(String data, int priority, ConnectionType connectionType);

// 파일 업로드
cloudService.uploadFile(String filePath, int priority, ConnectionType connectionType);

// 다운로드
cloudService.downloadData(new CloudCallback() {
    @Override
    public void onDataReceived(String data) {
        // 처리
    }
});
```

### ConnectionTypeEnum

```cpp
enum class ConnectionTypeEnum {
    WIFI,       // WiFi 연결 (빠름, 비용 없음)
    SATELLITE   // 셀룰러/위성 (느림, 비용 발생 가능)
};
```

### 우선순위

| 값 | 의미 | 사용 시기 |
|----|------|----------|
| 1 | 최우선 | 긴급 알림, 에러 리포트 |
| 2 | 높음 | 실시간 센서 데이터 |
| 3 | 보통 | 정기 리포트, 로그 |
| 4+ | 낮음 | 배치 데이터, 대용량 파일 |

## Device-to-Device API 전체

### C++ API

```cpp
#include <nevonex/d2d/Device2Device.h>

auto d2d = Device2Device::getInstance();

// 명령 전송
d2d->sendCommand(const std::string& targetDeviceId, const std::string& command);

// 파일 전송
d2d->sendFile(const std::string& targetDeviceId, const std::string& filePath);

// 브로드캐스트 (모든 인근 장비에게)
d2d->broadcastCommand(const std::string& command);

// 수신 리스너 등록
d2d->registerListener(D2DListener* listener);
```

### 수신 리스너 인터페이스

```cpp
class D2DListener {
public:
    virtual void onCommandReceived(const std::string& senderId,
                                    const std::string& command) = 0;
    virtual void onFileReceived(const std::string& senderId,
                                 const std::string& filePath) = 0;
    virtual void onDeviceDiscovered(const std::string& deviceId,
                                     const std::string& deviceInfo) = 0;
    virtual void onDeviceLost(const std::string& deviceId) = 0;
};
```

### D2D 통신 범위

- WiFi Direct 기반: ~100m (개활지)
- 실내/장애물 있을 시: 거리 감소
- 동일 NEVONEX 네트워크 내 장비만 탐색 가능

## 에러 처리

### Cloud 업로드 실패

```cpp
// 재시도 패턴
void uploadWithRetry(const std::string& data, int maxRetries = 3) {
    for (int i = 0; i < maxRetries; i++) {
        try {
            Cloud::getInstance()->uploadData(data, 2, ConnectionTypeEnum::WIFI);
            NEVONEX_LOG(SeverityLevel::info) << "Upload success on attempt " << (i + 1);
            return;
        } catch (const std::exception& e) {
            NEVONEX_LOG(SeverityLevel::warning) << "Upload failed (attempt " << (i + 1)
                << "): " << e.what();
            if (i == maxRetries - 1) {
                // 최종 실패 시 로컬 저장
                FileProvider::getInstance().saveToDisk("failed_uploads",
                    generateFileName(), data);
            }
        }
    }
}
```

### D2D 전송 실패

```cpp
void sendD2DWithFallback(const std::string& targetId, const std::string& command) {
    try {
        Device2Device::getInstance()->sendCommand(targetId, command);
    } catch (const std::exception& e) {
        NEVONEX_LOG(SeverityLevel::warning) << "D2D failed, trying broadcast: " << e.what();
        try {
            Device2Device::getInstance()->broadcastCommand(command);
        } catch (const std::exception& e2) {
            NEVONEX_LOG(SeverityLevel::error) << "Broadcast also failed: " << e2.what();
        }
    }
}
```

## USB API (보조)

CCU의 USB 포트를 통한 파일 접근:

```cpp
// USB 장치 감지
bool hasUSB = USBProvider::getInstance()->isDeviceConnected();

// USB에서 파일 읽기
auto files = USBProvider::getInstance()->listFiles("/");
auto content = USBProvider::getInstance()->readFile("/config.json");

// USB에 파일 쓰기
USBProvider::getInstance()->writeFile("/export/data.csv", csvContent);
```

USB는 주로 오프라인 데이터 내보내기/가져오기에 사용한다.
