---
name: git-push-pr
description: 모든 에이전트가 공통으로 사용하는 push/PR 스킬이다. 현재 브랜치를 점검하고 원격 푸시 후 develop 대상 PR을 생성한다. "브랜치 푸시해줘", "PR 올려줘", "develop으로 PR 만들어줘", "PR 제목/본문 이슈 번호 포함해서 작성해줘"처럼 push와 PR 생성을 함께 처리하거나 PR 메타데이터 작성이 필요한 요청에서 사용한다. GitHub 연동은 GitHub MCP를 사용한다.
---

# Git Push And PR Workflow

이 스킬로 푸시와 PR 생성을 수행한다.

## 1. 사전 점검

1. `TODO-Issue.md`에서 현재 이슈 번호와 제목을 확인한다.
2. `git status --short`로 커밋 누락 파일이 없는지 확인한다.
3. `git branch --show-current`로 현재 브랜치를 확인한다.

## 2. 푸시

1. 최초 푸시는 업스트림을 설정한다.
2. 이후 푸시는 동일 브랜치로 수행한다.

예시:

```bash
git push -u origin <branch-name>
git push
```

## 3. PR 생성 정보 준비

1. base 브랜치는 `develop`으로 고정한다.
2. PR 제목은 변경사항을 한글로 요약하고 이슈 번호를 포함한다.
3. PR 본문에는 변경 요약과 관련 이슈를 포함한다.

본문 템플릿:

```text
## 변경 내용
- 변경사항 1
- 변경사항 2

## 관련 이슈
- Related: #<이슈번호>
```

## 4. PR 생성

1. GitHub MCP로 현재 레포에 PR을 생성한다.
2. base=`develop`, head=`<branch-name>`, 제목/본문은 준비한 텍스트를 그대로 사용한다.
3. 생성 후 PR URL과 PR 번호를 반드시 공유한다.

## 5. 안전 규칙

1. 현재 브랜치가 `develop` 또는 `main`이면 푸시/PR 전에 사용자 확인을 요청한다.
2. 사용자가 지정하지 않은 원격 저장소로 푸시하지 않는다.
3. 실패 로그를 숨기지 말고 핵심 오류를 요약해 재시도 방법을 제시한다.
