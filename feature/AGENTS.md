---
type: feature
---
# AGENTS.md

This file is the working agreement for humans and automation (CI, bots, AI agents).

## Project Overview and Description

- 이 레포 타입(feature)은 "디바이스 + UI"를 함께 개발하는 프로젝트를 의미한다.
- 예: 임베디드/디바이스 앱(C/C++) + 웹 UI(React 등) + 두 모듈 간 통신(WebSocket/IPC 등)

## Tools, Technologies, and Frameworks Used

- Device
  - (프로젝트에 따라 다름) C/C++ + CMake / SeamOS FDK (NEVONEX)
  - Protected Region(생성 코드)이 포함될 수 있음 — 반드시 `device-code-style` 스킬 참조
- UI
  - (프로젝트에 따라 다름) Node.js + React/Vite/Next.js + TypeScript

## How to Build and Run Tests

이 타입은 프로젝트별 편차가 커서, "레포 내 문서"를 SSOT로 삼는다.

- Device
  - (프로젝트 문서에 정의된 빌드/실행 방법을 따른다)
  - 생성 코드가 포함된 프로젝트라면 수정 가능한 영역 제한을 먼저 확인한다. → `device-code-style` 스킬 참조
  - CMake/Maven/FIF 패키징은 `fdk-build-config` 스킬 참조
- UI
  - Install: `npm install` (또는 `pnpm i`/`yarn`)
  - Dev: `npm run dev`
  - Build: `npm run build`
  - Test: 프로젝트의 테스트 러너(Vitest/Jest/Playwright 등)에 맞춰 실행
  - UI 빌드 후 Device 디렉토리 동기화가 필요하면 `ui-device-sync-build` 스킬 참조

## 기본 원칙

- **코드 수정 전 반드시 `device-code-style` 스킬을 참고한다.** Protected Region, Copyright 헤더, 코딩 컨벤션 규칙이 정의되어 있다.
- 모든 응답은 한국어로 작성한다.
- 작업 시작/진행/정리 과정에서 TODO-Issue.md 를 단일 진실원천(SSOT)으로 사용한다.
- TODO-Issue.md 에는 "현재 작업 중인 GitHub Issue"에 대한 실행 과제를 기록한다.
- device/ui는 변경 영향 범위가 넓으므로 작은 단위로 변경하고 바로 검증한다.
- 모든 Git 작업(브랜치 생성/커밋/푸시/PR/리베이스)은 기본적으로 `develop` 또는 `develop` 하위 브랜치에서 수행한다.
- `main`/`master`에서 Git 작업이 필요할 경우에는 사용자에게 명시적으로 허락을 받은 뒤에만 수행한다.

## 포함 스킬

| Name | 용도 |
|------|------|
| device-code-style | Device C++ 코딩 스타일, Protected Region, Controller 패턴 |
| fdk-websocket | Device-UI WebSocket JSON 통신 |
| fdk-sensor-api | 센서 데이터 읽기/쓰기, Machine lifecycle |
| fdk-custom-ui | Custom UI (Manifest, Poco HTTP, HTML/JS) |
| fdk-imu-gnss | IMU/GNSS 센서 + NMEA 파싱 + Mock 테스트 |
| fdk-cloud-d2d | Cloud 업/다운로드, D2D, FileProvider |
| fdk-build-config | CMake, Maven, FIF 패키지, CI/CD |
| fdk-external-api | Cloud 프록시 경유 외부 REST API 호출 |
| fdk-usb | USB 파일 전송, 디렉토리 관리, Mount/Unmount |
| fdk-property-listener | PropertyChangeListener 이벤트 감지 |
| ui-device-sync-build | UI 빌드 → Device 디렉토리 동기화 |

## 레포/프로젝트 정보

- 조직: AGMO-Inc
- 프로젝트명: (여기에 작성)
- 프로젝트 url: (여기에 작성; 관련없으면 N/A)
- 레포: (여기에 작성; `git remote get-url origin`)
