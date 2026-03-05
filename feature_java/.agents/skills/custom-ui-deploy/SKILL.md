---
name: custom-ui-deploy
description: Custom UI 빌드 및 앱 배포. "deploy ui", "ui 배포", "ui 빌드", "build deploy" 키워드 시 발동.
context: fork
agent: seamos-builder
---

# Custom UI Build & Deploy

> **Agent 위임**: 이 스킬의 모든 작업은 Agent 도구를 사용하여 `seamos-builder` 에이전트에게 위임하여 실행할 것. Agent 호출 시 사용자의 요청 내용과 파싱된 인자를 프롬프트로 전달한다.

Custom UI 프로젝트를 빌드하고 결과물을 앱의 `ui/` 디렉토리로 배포한다.

**즉시 스크립트를 실행하라. 설명을 출력하지 말 것.**

## 실행

```bash
bash <skill-path>/scripts/deploy-ui.sh <ui-project-path> <project-root>
```

- `<ui-project-path>`: UI 프로젝트 경로 (인자 없으면 스크립트가 사용법 안내 후 중단)
- `<project-root>`: 프로젝트 루트 (기본값: 현재 디렉토리)

## 후속 작업

스킬 완료 후 반드시 아래 안내를 출력에 포함할 것:

```
후속 작업: /build-fif 로 FIF 배포 빌드를 실행할 수 있습니다.
```

## 참고

- 상세 가이드 및 트러블슈팅: [references/deploy-guide.md](references/deploy-guide.md)
