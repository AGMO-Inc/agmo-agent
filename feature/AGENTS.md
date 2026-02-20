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
  - (프로젝트에 따라 다름) C/C++ + CMake/특수 IDE/생성 코드
- UI
  - (프로젝트에 따라 다름) Node.js + React/Vite/Next.js + TypeScript

## How to Build and Run Tests

이 타입은 프로젝트별 편차가 커서, "레포 내 문서"를 SSOT로 삼는다.

- Device
  - (프로젝트 문서에 정의된 빌드/실행 방법을 따른다)
  - 생성 코드가 포함된 프로젝트라면 "수정 가능한 영역" 제한을 먼저 확인한다.
- UI
  - Install: `npm install` (또는 `pnpm i`/`yarn`)
  - Dev: `npm run dev`
  - Build: `npm run build`
  - Test: 프로젝트의 테스트 러너(Vitest/Jest/Playwright 등)에 맞춰 실행

## 기본 원칙

- 모든 응답은 한국어로 작성한다.
- 작업 시작/진행/정리 과정에서 TODO-Issue.md 를 단일 진실원천(SSOT)으로 사용한다.
- TODO-Issue.md 에는 "현재 작업 중인 GitHub Issue"에 대한 실행 과제를 기록한다.
- device/ui는 변경 영향 범위가 넓으므로 작은 단위로 변경하고 바로 검증한다.
- 모든 Git 작업(브랜치 생성/커밋/푸시/PR/리베이스)은 기본적으로 `develop` 또는 `develop` 하위 브랜치에서 수행한다.
- `main`/`master`에서 Git 작업이 필요할 경우에는 사용자에게 명시적으로 허락을 받은 뒤에만 수행한다.

## 레포/프로젝트 정보

- 조직: AGMO-Inc
- 프로젝트명: (여기에 작성)
- 프로젝트 url: (여기에 작성; 관련없으면 N/A)
- 레포: (여기에 작성; `git remote get-url origin`)
