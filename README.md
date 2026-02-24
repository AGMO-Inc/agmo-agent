## Contents

- [1. 설정 방법](#1-설정-방법)
    - [1.1 전제 조건](#11-전제-조건)
    - [1.2 설정 프롬프트](#12-설정-프롬프트)
- [2. 업데이트 방법](#2-업데이트-방법)
    - [2.1 agmo-agent-update 커맨드](#21-agmo-agent-update-커맨드)
    - [2.2 설치 스크립트로 재설치](#22-설치-스크립트로-재설치)
- [3. 포함된 스킬/커맨드](#3-포함된-스킬커맨드)
    - [3.1 공용 스킬(common)](#31-공용-스킬common)
    - [3.2 백엔드 스킬(backend)](#32-백엔드-스킬backend)
    - [3.3 Feature 스킬(feature)](#33-feature-스킬feature)
    - [3.4 공용 커맨드(common)](#34-공용-커맨드common)


## 1. 설정 방법

### 1.1 전제 조건
- gh 설치 및 로그인

### 1.2 설정 프롬프트
- 아래 프롬프트를 복사하여 AI code agent 에게 붙여넣는다. (claude code, codex, Cursor 등등)

```
Configure agent settings by following the instructions here:
curl -s https://raw.githubusercontent.com/AGMO-Inc/agmo-agent/refs/heads/main/docs/guide/installation.md
```

- 이후 Agent 의 지시사항을 따르세요.

## 2. 업데이트 방법

`.agents`는 이 레포의 main 브랜치를 SSOT로 두고 배포된다.

### 2.1 agmo-agent-update 커맨드

`.agents`에 포함된 스킬/커맨드의 차이를 표로 보여주고, 사용자가 선택한 것만 업데이트한다.

- 기본(AGENTS.md의 `type:` 사용): `/agmo-agent-update`
- common만: `/agmo-agent-update common`
- 타입만: `/agmo-agent-update backend` (또는 `frontend`, `custom`)
- 특정 항목만: `/agmo-agent-update swagger` (skill/command 이름)

동작:

- canonical: `AGMO-Inc/agmo-agent`에서 `common/.agents/(skills|commands)` + `{type}/.agents/(skills|commands)`를 가져와 비교
- local: 현재 레포의 `./.agents/(skills|commands)`와 비교
- 출력: Diff Summary 표 + "전부/없음/선택" 중 택1을 강제
- 적용: 선택된 항목만 복사/덮어쓰기 + 백업 생성(`.agents/.backup/agmo-agent-update/...`)

### 2.2 설치 스크립트로 재설치

가장 단순한 업데이트 방법은 설치 가이드의 다운로드 단계를 다시 실행하는 것이다.

- 가이드: `docs/guide/installation.md`
- 핵심: TYPE에 맞는 `.agents`를 다시 내려받아 덮어쓴다(backend/frontend/custom + common 합치기).

## 3. 포함된 스킬/커맨드

이 레포에서 설치하면 대상 레포 기준 경로는 다음과 같다.

- skill: `./.agents/skills/<name>/`
- command: `./.agents/commands/<name>/`

### 3.1 공용 스킬(common)

| Name | Path | 용도 |
|------|------|------|
| git-issue-start | `common/.agents/skills/git-issue-start/` | GitHub 이슈 기반으로 TODO-Issue.md 갱신 + 브랜치 생성 |
| git-issue-list | `common/.agents/skills/git-issue-list/` | GitHub 이슈 목록 조회 및 표 형식 정리 |
| git-issue-move | `common/.agents/skills/git-issue-move/` | GitHub 프로젝트 보드 이슈 상태 변경 |
| git-commit | `common/.agents/skills/git-commit/` | 변경사항 점검/검증 후 커밋 생성 |
| git-push-pr | `common/.agents/skills/git-push-pr/` | 푸시 후 PR 생성 |
| git-pr-review-fix | `common/.agents/skills/git-pr-review-fix/` | PR AI 리뷰 확인/수정 후 커밋 |
| git-pr-merge | `common/.agents/skills/git-pr-merge/` | PR squash merge + 이슈 완료 코멘트 |
| skill-creator | `common/.agents/skills/skill-creator/` | 스킬 생성/검증/패키징 도구 및 가이드 |

### 3.2 백엔드 스킬(backend)

| Name | Path | 용도 |
|------|------|------|
| swagger | `backend/.agents/skills/swagger/` | Springdoc(OpenAPI) 기반 Swagger 어노테이션/문서화 패턴 |
| tdd | `backend/.agents/skills/tdd/` | Kotlin + Spring + Kotest 기반 TDD(유닛/통합/플로우) 가이드 |

### 3.3 Feature 스킬(feature)

| Name | Path | 용도 |
|------|------|------|
| device-code-style | `feature/.agents/skills/device-code-style/` | Device C++ 코딩 스타일, Protected Region, Controller 패턴 |
| fdk-websocket | `feature/.agents/skills/fdk-websocket/` | Device-UI WebSocket JSON 통신 |
| fdk-sensor-api | `feature/.agents/skills/fdk-sensor-api/` | 센서 데이터 읽기/쓰기, Machine lifecycle |
| fdk-custom-ui | `feature/.agents/skills/fdk-custom-ui/` | Custom UI (Manifest, Poco HTTP, HTML/JS) |
| fdk-imu-gnss | `feature/.agents/skills/fdk-imu-gnss/` | IMU/GNSS 센서 + NMEA 파싱 + Mock 테스트 |
| fdk-cloud-d2d | `feature/.agents/skills/fdk-cloud-d2d/` | Cloud 업/다운로드, D2D, FileProvider |
| fdk-build-config | `feature/.agents/skills/fdk-build-config/` | CMake, Maven, FIF 패키지, CI/CD |
| fdk-external-api | `feature/.agents/skills/fdk-external-api/` | Cloud 프록시 경유 외부 REST API 호출 |
| fdk-usb | `feature/.agents/skills/fdk-usb/` | USB 파일 전송, 디렉토리 관리, Mount/Unmount |
| fdk-property-listener | `feature/.agents/skills/fdk-property-listener/` | PropertyChangeListener 이벤트 감지 |
| ui-device-sync-build | `feature/.agents/skills/ui-device-sync-build/` | UI 빌드 → Device 디렉토리 동기화 |

### 3.4 공용 커맨드(common)

| Name | Path | 용도 |
|------|------|------|
| agmo-agent-update | `common/.agents/commands/agmo-agent-update/` | `.agents/(skills|commands)`를 canonical과 비교 후 선택 업데이트 |