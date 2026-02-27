# WebSocket 고급 패턴

## C++ vs Java API 비교

| 기능 | C++ | Java |
|------|-----|------|
| 엔드포인트 생성 | `new WebSocketEndPoint("/path")` | `UIWebsocketEndPoint` (싱글턴) |
| JSON 발신 | `wsEndpoint->publishMessage(Json::Value)` | `UIWebsocketEndPoint.broadcastMessage(String)` |
| 문자열 발신 | `wsEndpoint->publishMessage(string)` | `UIWebsocketEndPoint.broadcastMessage(String)` |
| JSON 수신 | `onWebSocketJsonMessage(Json::Value&)` | `onWebSocketMessage(String)` → 수동 파싱 |
| 등록 | `registerWebSocketEndPoint(wsEndpoint)` | 자동 등록 |

## 에러 처리

### C++ WebSocket 에러 핸들링

```cpp
void Controller::onWebSocketJsonMessage(Json::Value& message) {
    try {
        std::string type = message["type"].asString();
        if (type.empty()) {
            NEVONEX_LOG(SeverityLevel::warning) << "Missing message type";
            return;
        }

        if (type == "set_rate") {
            double value = message["value"].asDouble();
            if (std::isnan(value) || std::isinf(value)) {
                NEVONEX_LOG(SeverityLevel::error) << "Invalid rate value";
                sendErrorResponse("Invalid rate value");
                return;
            }
            setRate(value);
        }
    } catch (const std::exception& e) {
        NEVONEX_LOG(SeverityLevel::error) << "WS message error: " << e.what();
    }
}

void Controller::sendErrorResponse(const std::string& error) {
    Json::Value msg;
    msg["type"] = "error";
    msg["message"] = error;
    wsEndpoint->publishMessage(msg);
}
```

### Java WebSocket 에러 핸들링

```java
@Override
public void onWebSocketMessage(String message) {
    try {
        JSONObject json = new JSONObject(message);
        String type = json.optString("type", "");
        if (type.isEmpty()) {
            FCALLogs.getInstance().log.warning("Missing message type");
            return;
        }
        processMessage(type, json);
    } catch (JSONException e) {
        FCALLogs.getInstance().log.error("JSON parse error: " + e.getMessage());
    }
}
```

## 메시지 빈도 제어

### 변경 감지 방식 (권장)

```cpp
// run()에서 매번 보내지 않고, 값이 변경될 때만 전송
double lastSentRate = 0;
const double THRESHOLD = 0.1;  // 변경 임계값

void Controller::run() {
    double currentRate = getRate();
    if (std::abs(currentRate - lastSentRate) > THRESHOLD) {
        Json::Value msg;
        msg["type"] = "rate_update";
        msg["value"] = currentRate;
        wsEndpoint->publishMessage(msg);
        lastSentRate = currentRate;
    }
}
```

### Process Timer 방식

```cpp
// init()에서 500ms 주기로 UI 업데이트 설정
void Controller::init() {
    addProcessTimer("ui_update", 500, [this]() {
        Json::Value msg;
        msg["type"] = "dashboard";
        msg["rate"] = currentRate;
        msg["speed"] = currentSpeed;
        msg["position"] = getPositionJson();
        wsEndpoint->publishMessage(msg);
    });
}
```

## UI 측 재연결 전략

```javascript
class WSConnection {
    constructor(url) {
        this.url = url;
        this.reconnectDelay = 1000;
        this.maxDelay = 30000;
        this.connect();
    }

    connect() {
        this.ws = new WebSocket(this.url);

        this.ws.onopen = () => {
            console.log("Connected");
            this.reconnectDelay = 1000;  // 성공 시 딜레이 리셋
        };

        this.ws.onclose = () => {
            console.log("Disconnected, reconnecting in " + this.reconnectDelay + "ms");
            setTimeout(() => this.connect(), this.reconnectDelay);
            this.reconnectDelay = Math.min(this.reconnectDelay * 2, this.maxDelay);
        };

        this.ws.onerror = (error) => {
            console.error("WebSocket error:", error);
        };

        this.ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            this.handleMessage(data);
        };
    }

    send(data) {
        if (this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify(data));
        } else {
            console.warn("WebSocket not connected, message queued");
            // 선택: 메시지 큐에 저장하거나 버림
        }
    }

    handleMessage(data) {
        // 오버라이드하여 사용
    }
}

// 사용
const conn = new WSConnection("ws://192.168.32.1:1456/ws/myfeature");
```

## 대용량 데이터 전략

- WebSocket: 실시간 소량 데이터 (< 1KB per message)
- REST GET/POST: 대용량 데이터 (설정, 로그, 파일)
- FileProvider + REST: 파일 다운로드/업로드

```cpp
// 대용량 데이터는 REST로, 알림은 WebSocket으로
void Controller::onLargeDataReady(const std::string& fileId) {
    // WebSocket으로 알림만 전송
    Json::Value notify;
    notify["type"] = "data_ready";
    notify["fileId"] = fileId;
    wsEndpoint->publishMessage(notify);
    // UI가 REST /api/data/{fileId} 로 실제 데이터를 fetch
}
```
