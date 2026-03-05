---
name: custom-ui-clone
description: Custom UI React 프리셋 템플릿 클론
triggers:
  - custom-ui
  - custom ui
  - react template
argument-hint: "[target-directory]"
aliases: [custom-ui, clone-template]
quality: high
model: haiku
context: fork
agent: seamos-builder
---

# Custom UI React Template Clone

> **Agent 위임**: 이 스킬의 모든 작업은 Agent 도구를 사용하여 `seamos-builder` 에이전트에게 위임하여 실행할 것. Agent 호출 시 사용자의 요청 내용과 파싱된 인자를 프롬프트로 전달한다.

AGMO Custom UI React 프리셋 템플릿을 클론한다.

**IMPORTANT: 이 스킬이 로드되면 즉시 클론 스크립트를 실행하라. 문서를 출력하지 말고 바로 실행할 것.**

## 실행

```bash
SKILL_DIR="<skill-directory-path>"
bash "$SKILL_DIR/scripts/clone-template.sh" [target-directory]
```

인자 없으면 기본값 `custom-ui-react-template/`으로 클론.

## 참조

- [사용 가이드](references/usage.md) - 인자 패턴, 저장소 정보, 트러블슈팅
