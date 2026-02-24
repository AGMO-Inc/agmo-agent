---
name: fdk-websocket
description: "(feature - Skill) NEVONEX FDK WebSocket 통신 가이드. C++ WebSocketEndPoint와 Java UIWebsocketEndPoint를 사용한 Device-UI 간 양방향 JSON 메시지 교환 패턴을 다룬다. Feature에서 웹 UI로 데이터를 보내거나, UI에서 디바이스로 명령을 수신하는 WebSocket 코드를 작성할 때 사용한다. 'WebSocket 메시지 보내기', 'UI로 데이터 전송', 'WebSocket 핸들러 추가', 'Device-UI 통신', 'JSON 메시지 포맷', 'onMessage 구현' 같은 요청에서 사용한다."
---

# FDK WebSocket

## Overview

NEVONEX Feature는 CCU(Controller Computer Unit)에서 실행되며, 웹 UI와 WebSocket으로 통신한다. C++에서는 `WebSocketEndPoint`, Java에서는 `UIWebsocketEndPoint`를 사용하며, JSON 형식으로 메시지를 교환한다.

## C++ WebSocket API

### 발신: Device → UI

```cpp
// JSON 메시지 발신
Json::Value msg;
msg["type"] = "sensor_data";
msg["value"] = 42.5;
msg["timestamp"] = getCurrentTimestamp();
wsEndpoint->publishMessage(msg);

// 문자열 발신
wsEndpoint->publishMessage("simple string message");
```

### 수신: UI → Device

Controller에서 WebSocket 메시지 수신 콜백을 구현한다:

```cpp
/*PROTECTED REGION ID(ws_receive) ENABLED START*/
void Controller::onWebSocketJsonMessage(Json::Value& message) {
    std::string type = message["type"].asString();

    if (type == "set_rate") {
        double targetRate = message["value"].asDouble();
        implement->getBoom(0)->getChannel(0)->setSetpointApplicationRate(targetRate);
    } else if (type == "command") {
        std::string cmd = message["command"].asString();
        handleCommand(cmd);
    }
}
/*PROTECTED REGION END*/
```

### 엔드포인트 등록

WebSocket 엔드포인트는 `init()`에서 등록한다:

```cpp
/*PROTECTED REGION ID(controller_init) ENABLED START*/
void Controller::init() {
    wsEndpoint = new WebSocketEndPoint("/ws/myfeature");
    registerWebSocketEndPoint(wsEndpoint);
}
/*PROTECTED REGION END*/
```

## Java WebSocket API

### 발신: Device → UI

```java
// JSON 메시지 브로드캐스트 (연결된 모든 UI 클라이언트에게)
JSONObject msg = new JSONObject();
msg.put("type", "status");
msg.put("value", currentValue);
UIWebsocketEndPoint.broadcastMessage(msg.toString());
```

### 수신: UI → Device

```java
@Override
public void onWebSocketMessage(String message) {
    JSONObject json = new JSONObject(message);
    String type = json.getString("type");
    // 메시지 처리...
}
```

## UI 측 (JavaScript) 연결

```javascript
// CCU WiFi AP 기본 주소
const ws = new WebSocket("ws://192.168.32.1:1456/ws/myfeature");

ws.onopen = function() {
    console.log("Connected to Feature");
};

ws.onmessage = function(event) {
    const data = JSON.parse(event.data);
    updateUI(data);
};

// Device로 명령 전송
function sendCommand(cmd, value) {
    ws.send(JSON.stringify({
        type: "command",
        command: cmd,
        value: value
    }));
}
```

## 메시지 설계 패턴

### 권장 JSON 구조

```json
{
    "type": "message_type",
    "payload": { },
    "timestamp": 1234567890
}
```

### 일반적인 메시지 타입

| type | 방향 | 용도 |
|------|------|------|
| `sensor_data` | Device → UI | 센서 측정값 업데이트 |
| `status` | Device → UI | 장비 상태 정보 |
| `set_rate` | UI → Device | 목표값 설정 명령 |
| `command` | UI → Device | 제어 명령 |
| `config` | 양방향 | 설정 조회/변경 |

### 주의사항

- `Controller::run()`은 10Hz로 호출됨 → 매 호출마다 publish하면 초당 10개 메시지 발생
- UI에 필요한 빈도만큼만 전송 (변경 시에만, 또는 Process Timer로 주기 제어)
- 대용량 데이터는 REST endpoint 사용 권장 (WebSocket은 실시간 소량 데이터에 적합)


### 프로젝트별 응답 빌더

프로젝트에 따라 WebSocket 응답을 생성하는 공통 헬퍼 함수(e.g. `createResponse(type, success, payload)`)가 존재할 수 있다. 새로 응답 로직을 작성하기 전에 **기존 Controller 코드에서 응답 빌더 함수가 있는지 먼저 확인**하고, 있다면 동일한 함수를 사용해 응답 포맷을 통일한다.
## Resources

### references/
- `websocket-patterns.md` — 고급 패턴, 에러 처리, 재연결 전략, C++/Java 비교표
