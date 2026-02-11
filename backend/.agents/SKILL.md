---
name: skills-index
description: 프로젝트 작업 스킬 인덱스다. 각 스킬의 단일 기준 문서(Single Source of Truth)를 링크하고, 언제 어떤 스킬을 써야 하는지 빠르게 찾을 수 있게 한다.
---

## 스킬 인덱스
이 문서는 프로젝트 작업 스킬의 인덱스다.
(프로젝트 정책/규칙은 AGENTS.md를 따른다.)

상세 절차는 아래 스킬을 단일 기준으로 사용한다.

- `AGENT_ROOT/skills/issue-start/SKILL.md`
  - GitHub 이슈 조회, `TODO-Issue.md` 갱신, 이슈 기반 브랜치 생성
- `AGENT_ROOT/skills/git-commit/SKILL.md`
  - 변경사항 검토, 테스트, 이슈 번호 기반 한국어 커밋
- `AGENT_ROOT/skills/git-push-pr/SKILL.md`
  - 브랜치 푸시, develop 대상 PR 생성
- `AGENT_ROOT/skills/swagger/SKILL.md`
  - Swagger(springdoc-openapi) 문서화 컨벤션 및 어노테이션별 규칙/예제

## 스킬 작성
- 스킬은 `AGENT_ROOT/skills/스킬명/SKILL.md`로 정의된다.
- 새로운 스킬이 작성되면 스킬 인덱스에 설명과 함께 추가되어야 한다.
