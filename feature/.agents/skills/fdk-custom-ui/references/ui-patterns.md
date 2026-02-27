# Custom UI 실전 패턴

## CCU 네트워크 환경

### 제약 사항

- **접속 방식**: CCU WiFi AP (SSID: NEVONEX_xxxxx)
- **기본 주소**: `192.168.32.1:1456`
- **대역폭**: WiFi 직접 연결이므로 비교적 양호하나, CCU 리소스 제한 있음
- **동시 접속**: 여러 클라이언트 동시 접속 가능 (WebSocket 브로드캐스트)
- **인터넷**: CCU WiFi 연결 시 인터넷 접근 불가 (로컬 네트워크만)

### 최적화 지침

- CDN 사용 불가 → 모든 라이브러리를 로컬에 번들
- 이미지/폰트 최소화 (CCU 저장 공간 16GB 공유)
- 불필요한 폴링 최소화 (WebSocket 우선, REST는 필요 시에만)

## 대시보드 레이아웃 패턴

### 기본 대시보드

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Feature Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/lib/jquery-3.7.1.min.js"></script>
</head>
<body>
    <header>
        <h1>My Feature</h1>
        <span id="connection-status" class="status-dot offline"></span>
    </header>

    <main>
        <div class="card">
            <h2>Application Rate</h2>
            <div class="value" id="rate-value">--</div>
            <div class="unit">L/ha</div>
        </div>

        <div class="card">
            <h2>Speed</h2>
            <div class="value" id="speed-value">--</div>
            <div class="unit">km/h</div>
        </div>

        <div class="card">
            <h2>Total Volume</h2>
            <div class="value" id="volume-value">--</div>
            <div class="unit">L</div>
        </div>

        <div class="controls">
            <label>Target Rate (L/ha)</label>
            <input type="number" id="target-rate" min="0" max="500" step="0.5">
            <button id="apply-btn">Apply</button>
        </div>
    </main>

    <script src="js/websocket.js"></script>
    <script src="js/app.js"></script>
</body>
</html>
```

### 기본 CSS

```css
* { box-sizing: border-box; margin: 0; padding: 0; }

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: #f5f5f5;
    color: #333;
}

header {
    background: #1a73e8;
    color: white;
    padding: 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.status-dot {
    width: 12px; height: 12px;
    border-radius: 50%;
    display: inline-block;
}
.status-dot.online { background: #4CAF50; }
.status-dot.offline { background: #f44336; }

main { padding: 16px; }

.card {
    background: white;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.12);
    text-align: center;
}

.card .value {
    font-size: 48px;
    font-weight: bold;
    color: #1a73e8;
}

.card .unit {
    font-size: 14px;
    color: #666;
    margin-top: 4px;
}

.controls {
    background: white;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.12);
}

.controls input {
    width: 100%;
    padding: 12px;
    font-size: 18px;
    border: 1px solid #ddd;
    border-radius: 4px;
    margin: 8px 0;
}

.controls button {
    width: 100%;
    padding: 14px;
    font-size: 16px;
    background: #1a73e8;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    min-height: 44px; /* 터치 친화적 */
}
```

## Canvas 필드 맵 패턴

```javascript
class FieldMap {
    constructor(canvasId) {
        this.canvas = document.getElementById(canvasId);
        this.ctx = this.canvas.getContext("2d");
        this.sections = [];
        this.machinePos = { x: 0, y: 0, heading: 0 };
        this.resize();
        window.addEventListener("resize", () => this.resize());
    }

    resize() {
        this.canvas.width = this.canvas.parentElement.clientWidth;
        this.canvas.height = 300;
        this.draw();
    }

    updateSections(sections) {
        this.sections = sections;
        this.draw();
    }

    updateMachinePosition(lat, lng, heading) {
        this.machinePos = { x: this.lngToX(lng), y: this.latToY(lat), heading: heading };
        this.draw();
    }

    draw() {
        const ctx = this.ctx;
        ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        // 섹션 그리기
        this.sections.forEach(s => {
            ctx.fillStyle = s.active ? "rgba(76, 175, 80, 0.5)" : "rgba(158, 158, 158, 0.3)";
            ctx.fillRect(s.x, s.y, s.w, s.h);
            ctx.strokeStyle = "#333";
            ctx.strokeRect(s.x, s.y, s.w, s.h);
        });

        // 기계 위치 (삼각형)
        ctx.save();
        ctx.translate(this.machinePos.x, this.machinePos.y);
        ctx.rotate(this.machinePos.heading * Math.PI / 180);
        ctx.fillStyle = "#f44336";
        ctx.beginPath();
        ctx.moveTo(0, -10);
        ctx.lineTo(-7, 7);
        ctx.lineTo(7, 7);
        ctx.closePath();
        ctx.fill();
        ctx.restore();
    }

    lngToX(lng) { /* 좌표 변환 구현 */ }
    latToY(lat) { /* 좌표 변환 구현 */ }
}
```

## Babylon.js 3D 시각화 패턴

### 기계 3D 모델 표시

```javascript
class Machine3DView {
    constructor(canvasId) {
        const canvas = document.getElementById(canvasId);
        this.engine = new BABYLON.Engine(canvas, true);
        this.scene = new BABYLON.Scene(this.engine);

        // 카메라
        this.camera = new BABYLON.ArcRotateCamera("cam",
            Math.PI / 4, Math.PI / 3, 15,
            BABYLON.Vector3.Zero(), this.scene);
        this.camera.attachControl(canvas, true);

        // 조명
        new BABYLON.HemisphericLight("light",
            new BABYLON.Vector3(0, 1, 0), this.scene);

        // 지면
        const ground = BABYLON.MeshBuilder.CreateGround("ground",
            { width: 50, height: 50 }, this.scene);
        ground.material = this.createGroundMaterial();

        // 렌더 루프
        this.engine.runRenderLoop(() => this.scene.render());
        window.addEventListener("resize", () => this.engine.resize());
    }

    loadModel(url) {
        BABYLON.SceneLoader.ImportMesh("", url, "", this.scene, (meshes) => {
            this.machineMesh = meshes[0];
        });
    }

    updateOrientation(roll, pitch, yaw) {
        if (this.machineMesh) {
            this.machineMesh.rotation.x = pitch * Math.PI / 180;
            this.machineMesh.rotation.y = yaw * Math.PI / 180;
            this.machineMesh.rotation.z = roll * Math.PI / 180;
        }
    }

    createGroundMaterial() {
        const mat = new BABYLON.StandardMaterial("ground", this.scene);
        mat.diffuseColor = new BABYLON.Color3(0.4, 0.6, 0.3);
        return mat;
    }
}
```

## 다국어 지원 패턴

```javascript
const i18n = {
    en: {
        rate: "Application Rate",
        speed: "Speed",
        apply: "Apply",
        connected: "Connected",
        disconnected: "Disconnected"
    },
    de: {
        rate: "Ausbringmenge",
        speed: "Geschwindigkeit",
        apply: "Anwenden",
        connected: "Verbunden",
        disconnected: "Getrennt"
    }
};

function t(key) {
    const lang = navigator.language.substring(0, 2);
    return (i18n[lang] || i18n.en)[key] || key;
}
```
