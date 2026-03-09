# Implementation 노트 템플릿

```markdown
---
type: impl
project: {PROJECT}
issue: "{ISSUE_NUM}"
pr: "{PR_NUMBER}"
plan: "[[{PROJECT}/plans/[Plan] {PLAN_TITLE}]]"
status: done
created: {YYYY-MM-DD}
tags:
  - impl
  - {PROJECT}
---

# {구현 제목}

> 프로젝트: [[{PROJECT}]]
> 플랜: [[{PROJECT}/plans/[Plan] {PLAN_TITLE}]]

## 이슈

- GitHub Issue: [#{ISSUE_NUM}](https://github.com/{OWNER}/{PROJECT}/issues/{ISSUE_NUM})
- PR: [PR #{PR_NUMBER}]({PR_URL})

## 구현 요약

{핵심 구현 내용}

## 변경 파일

{파일별 간단 설명}

## 기술 결정

{구현 중 내린 결정사항}

## 테스트 결과

{테스트 실행 결과}

## 참고

- 브랜치: `{BRANCH}`
- 커밋 범위: `{BASE}..{HEAD}`
```
