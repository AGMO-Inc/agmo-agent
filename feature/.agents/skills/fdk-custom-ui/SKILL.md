---
name: fdk-custom-ui
description: "(feature - Skill) NEVONEX FDK Custom UI 개발 가이드. Manifest.xml GUI 타입 설정, REST/WebSocket 엔드포인트 등록(Poco HTTP), HTML/CSS/JS+jQuery+Canvas+Babylon.js 웹 UI 구현, CCU WiFi 연결(192.168.32.1:1456)을 다룬다. Feature 웹 인터페이스를 새로 만들거나 수정할 때 사용한다. 'Custom UI 만들기', 'Manifest GUI 설정', 'REST 엔드포인트 추가', 'Poco HTTP 핸들러', 'UI 페이지 추가', 'CCU 웹 접속', 'HTML/JS UI 구현' 같은 요청에서 사용한다."
---

# FDK Custom UI

## Overview

NEVONEX Feature의 UI는 CCU에서 호스팅되는 웹 페이지로, 모바일/태블릿 브라우저에서 접근한다. UI 타입은 Manifest.xml에서 설정하며, Custom UI는 HTML/CSS/JS를 자유롭게 작성할 수 있다. CCU와 통신은 REST API와 WebSocket을 사용한다.

## Manifest.xml GUI 설정

```xml
<!-- Custom UI 모드 -->
<gui type="custom_with_hmi_gui">
    <page name="main" src="index.html"/>
    <page name="settings" src="settings.html"/>
</gui>

<!-- 또는 HMI 전용 (custom 없이) -->
<gui type="hmi_gui_only"/>
```

### GUI 타입

| 타입 | 설명 |
|------|------|
| `custom_with_hmi_gui` | Custom HTML UI + HMI 통합 |
| `hmi_gui_only` | HMI 시스템 UI만 사용 |
| `custom_gui_only` | Custom HTML UI만 사용 |

## REST 엔드포인트 등록

### C++ (Poco HTTP)

```cpp
/*PROTECTED REGION ID(rest_init) ENABLED START*/
void Controller::init() {
    // GET 엔드포인트
    registerGetService("/api/status", [this](Poco::Net::HTTPServerRequest& req,
                                              Poco::Net::HTTPServerResponse& resp) {
        Json::Value result;
        result["status"] = "running";
        result["rate"] = currentRate;
        resp.setContentType("application/json");
        resp.send() << result.toStyledString();
    });

    // POST 엔드포인트
    registerPostService("/api/config", [this](Poco::Net::HTTPServerRequest& req,
                                               Poco::Net::HTTPServerResponse& resp) {
        std::istream& body = req.stream();
        Json::Value json;
        body >> json;
        applyConfig(json);
        resp.setStatus(Poco::Net::HTTPResponse::HTTP_OK);
        resp.send() << "{\"success\": true}";
    });
}
/*PROTECTED REGION END*/
```

### Java

```java
// GET 서비스 등록
UIWebServiceProvider.registerGetService("/api/status", (request, response) -> {
    JSONObject result = new JSONObject();
    result.put("status", "running");
    return result.toString();
});

// POST 서비스 등록
UIWebServiceProvider.registerPostService("/api/config", (request, response) -> {
    String body = request.getBody();
    JSONObject json = new JSONObject(body);
    applyConfig(json);
    return "{\"success\": true}";
});
```

## WebSocket 엔드포인트 등록

WebSocket 통신 상세는 `fdk-websocket` 스킬 참조. 여기서는 UI 등록만 다룬다:

```cpp
// init()에서 등록
wsEndpoint = new WebSocketEndPoint("/ws/myfeature");
registerWebSocketEndPoint(wsEndpoint);
```

## HTML/CSS/JS 구현

### 프로젝트 구조

```
feature/
├── webapp/
│   ├── index.html          # 메인 UI 페이지
│   ├── settings.html       # 설정 페이지
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   ├── app.js          # 메인 로직
│   │   ├── websocket.js    # WebSocket 연결 관리
│   │   └── lib/
│   │       ├── jquery-3.x.min.js
│   │       └── babylon.js  # (3D 필요 시)
│   └── img/
│       └── icons/
└── Manifest.xml
```

### CCU 연결

```javascript
// CCU WiFi AP 접속 시 기본 주소
const BASE_URL = "http://192.168.32.1:1456";
const WS_URL = "ws://192.168.32.1:1456";

// REST API 호출
async function getStatus() {
    const response = await fetch(`${BASE_URL}/api/status`);
    return response.json();
}

// WebSocket 연결
const ws = new WebSocket(`${WS_URL}/ws/myfeature`);
```

### jQuery 사용 패턴

```javascript
$(document).ready(function() {
    // 주기적 상태 업데이트
    setInterval(function() {
        $.getJSON("/api/status", function(data) {
            $("#rate-display").text(data.rate.toFixed(1));
            $("#status-indicator").toggleClass("active", data.status === "running");
        });
    }, 1000);

    // 사용자 입력 전송
    $("#apply-btn").click(function() {
        const config = {
            targetRate: parseFloat($("#target-rate").val()),
            mode: $("#mode-select").val()
        };
        $.post("/api/config", JSON.stringify(config));
    });
});
```

### Canvas 2D 시각화

```javascript
const canvas = document.getElementById("fieldCanvas");
const ctx = canvas.getContext("2d");

function drawField(data) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    // 필드 맵 그리기
    data.sections.forEach(function(section) {
        ctx.fillStyle = section.active ? "#4CAF50" : "#9E9E9E";
        ctx.fillRect(section.x, section.y, section.width, section.height);
    });
}
```

### Babylon.js 3D (필요 시)

```javascript
const engine = new BABYLON.Engine(canvas, true);
const scene = new BABYLON.Scene(engine);
const camera = new BABYLON.ArcRotateCamera("cam", 0, 0, 10, BABYLON.Vector3.Zero(), scene);
const light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);

// 3D 모델 로드
BABYLON.SceneLoader.ImportMesh("", "/assets/", "machine.glb", scene, function(meshes) {
    // 메시 조작
});

engine.runRenderLoop(function() { scene.render(); });
```

## 모바일 최적화

- CCU UI는 주로 모바일/태블릿에서 사용됨
- 반응형 디자인 필수: `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
- 터치 친화적 버튼 크기 (최소 44px)
- WiFi 환경이므로 대용량 에셋 로딩 시 주의 (CCU 리소스 제한)

## Resources

### references/
- `ui-patterns.md` — 실전 UI 레이아웃 예제, jQuery/Canvas/Babylon.js 고급 패턴, CCU 네트워크 제약 사항
