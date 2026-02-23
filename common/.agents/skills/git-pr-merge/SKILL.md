---
name: git-pr-merge
description: PR을 squash merge하고 관련 이슈(Task/Feature)에 완료 코멘트를 작성하는 스킬이다. "머지해줘", "PR 머지하고 이슈 정리해줘", "머지 후 코멘트 남겨줘" 같은 요청에서 사용한다.
---

# PR Merge Workflow

이 스킬로 PR 머지와 이슈 정리를 수행한다.

## 0. 레포 식별

`git remote -v`로 현재 레포의 `<owner>/<repo>`를 추출한다. 이후 모든 gh 명령에서 사용한다.

## 1. 사전 점검

1. PR 번호를 확인한다. 명시되지 않으면 현재 브랜치의 열린 PR을 찾는다.
2. CI 상태와 리뷰 결과를 확인한다.
3. CI 실패 시 머지를 중단하고 사용자에게 알린다.

```bash
REPO=$(git remote get-url origin | sed -E 's#.+[:/]([^/]+/[^/.]+)(\.git)?$#\1#')

# PR 상태 및 CI 확인
gh pr view <PR번호> --repo "$REPO" --json state,statusCheckRollup,reviews
```

## 2. Squash Merge

```bash
gh pr merge <PR번호> --repo "$REPO" --squash
```

## 3. 이슈 코멘트 작성

1. `TODO-Issue.md`에서 현재 이슈 번호와 상위 Feature 이슈를 확인한다.
2. Task 이슈에 완료 코멘트를 작성한다.
3. 상위 Feature 이슈가 있으면 Feature에도 코멘트를 작성한다.

```bash
# Task 이슈에 코멘트
gh issue comment <이슈번호> --repo "$REPO" --body "<본문>"

# Feature 이슈에 코멘트
gh issue comment <상위이슈번호> --repo "$REPO" --body "<본문>"
```

### Task 코멘트 템플릿:

```text
> 🤖 **AI created**

## 완료 요약

PR #<PR번호> squash merge 완료.

### 구현 내용
- 변경사항 1
- 변경사항 2
```

### Feature 코멘트 템플릿:

```text
> 🤖 **AI created**

## Task #<이슈번호> 완료

<작업 요약> (PR #<PR번호> merged).
- 변경사항 bullet
```

## 4. 안전 규칙

1. CI 실패 상태에서는 머지하지 않고 사용자에게 확인을 요청한다.
2. AI가 작성한 코멘트에는 반드시 `AI created` 표시를 포함한다.
3. 머지 성공 후 PR URL과 머지 상태를 공유한다.
