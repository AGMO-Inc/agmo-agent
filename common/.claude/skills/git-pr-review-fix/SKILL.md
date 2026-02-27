---
name: git-pr-review-fix
description: PR의 AI 리뷰 결과를 확인하고 지적사항을 수정하는 스킬이다. PR 댓글에서 리뷰 봇의 점수/지적사항을 파싱해 표로 요약하고, 수정 계획을 세워 사용자 승인을 받은 뒤 코드를 수정하고 커밋한다. "리뷰 확인해줘", "PR 리뷰 수정해줘", "CI 리뷰 결과 봐줘", "리뷰 점수 확인하고 고쳐줘" 같은 요청에서 사용한다.
---

# PR Review Fix Workflow

이 스킬로 PR 리뷰 결과를 확인하고 지적사항을 수정한다.

## 0. 레포 식별

`git remote -v`로 현재 레포의 `<owner>/<repo>`를 추출한다. 이후 모든 gh 명령에서 사용한다.

## 1. PR 리뷰 조회

1. PR 번호를 확인한다. 명시되지 않으면 현재 브랜치의 열린 PR을 찾는다.
2. PR 댓글에서 `[REVIEW_START]` ~ `[REVIEW_END]` 블록을 찾는다.
3. CI 상태(테스트, 리뷰 통과 여부)를 함께 확인한다.

```bash
# 현재 레포 식별
REPO=$(git remote get-url origin | sed -E 's#.+[:/]([^/]+/[^/.]+)(\.git)?$#\1#')

# PR 상태 및 댓글 조회
gh pr view <PR번호> --repo "$REPO" --json state,statusCheckRollup,comments

# PR 리뷰 코멘트만 조회
gh api "repos/$REPO/pulls/<PR번호>/comments"
```

## 2. 리뷰 결과 요약

1. 리뷰 블록에서 TOTAL 점수와 VERDICT(PASS/FAIL)를 추출한다.
2. 카테고리별(Security, Code Quality, Architecture, Correctness, Performance) 점수와 지적사항을 표로 정리한다.
3. CI 상태(테스트 결과 포함)도 함께 표시한다.

출력 형식:

```text
| 카테고리 | 점수 | 핵심 지적 |
|---|---|---|
| Security | 16/20 | 필수값 검증 없음 |
| Code Quality | 13/20 | 저장 필드 불일치 |
```

## 3. 수정 계획 제시 및 승인 대기

1. 지적사항 중 실질적으로 대응이 필요한 항목만 추린다.
2. 각 항목에 대해 수정 방법을 간결하게 제시한다.
3. **반드시 사용자 승인을 받은 뒤에만 코드 수정을 시작한다.**

## 4. 코드 수정

1. 승인받은 항목만 수정한다.
2. 수정 후 빌드와 관련 테스트를 실행한다.
3. 검증 통과 후 `git-commit` 스킬 절차에 따라 커밋한다.

## 5. 안전 규칙

1. **사용자 승인 없이 코드를 수정하지 않는다.**
2. push는 이 스킬에서 수행하지 않는다. 커밋까지만 한다.
3. 리뷰 점수가 PASS이면 수정 없이 결과만 보고한다.
4. 리뷰 댓글이 없으면 CI가 아직 실행 중일 수 있으므로 안내한다.
