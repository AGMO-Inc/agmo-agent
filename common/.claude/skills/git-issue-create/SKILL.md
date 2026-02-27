---
name: git-issue-create
description: GitHub Issue 생성 스킬. Feature/Task/Bug 이슈를 AGMO-Inc/.github 공용 ISSUE_TEMPLATE 형식에 맞춰 생성하고, 연결된 프로젝트가 있으면 자동으로 Project에 추가한다. 모든 이슈/코멘트/PR/커밋의 AI 작성 내용에는 `AI created` 표시를 포함한다.
---

# GitHub Issue 생성

팀 공용 템플릿(`AGMO-Inc/.github/.github/ISSUE_TEMPLATE`) 기준으로 이슈를 생성한다.

## 0. 레포 식별

`git remote -v`로 현재 레포의 `<owner>/<repo>`를 추출한다.

```bash
REPO=$(git remote get-url origin | sed -E 's#.+[:/]([^/]+/[^/.]+)(\.git)?$#\1#')
```

## 1. 이슈 유형 선택

사용자에게 이슈 유형을 확인한다. 명시되지 않으면 반드시 물어본다.

- **Feature**: 새로운 기능 개발
- **Task**: 상위 Feature의 하위 작업 단위
- **Bug**: 버그 리포트

## 2. 공통 규칙
1. 이슈 본문/코멘트/PR 본문/커밋 메시지에 AI가 작성한 텍스트가 있으면 반드시 `AI created` 표시를 넣는다.
2. 제목 형식은 공용 템플릿을 따른다.
3. 이슈 생성 후 연결된 프로젝트가 있으면 반드시 Project에 item-add 한다.
## 3. 템플릿 매핑
- Feature: `01-기능-개발.yml`
  - 제목: `[Feature] ...`
  - 본문 섹션: `1~5`
- Task: `02-기능-개발---하위-태스크.yml`
  - 제목: `[Task] ...`
  - 본문 섹션: `상위 Feature`, `1`, `2`, `3`
- Bug: `03-버그-리포트.yml`
  - 제목: `[Bug] ...`
  - 본문 섹션: `1~7`
## 4. 이슈 생성

### Feature 이슈 예시

```bash
issue_url="$(gh issue create \
  --repo "$REPO" \
  --title "[Feature] {이슈 한줄 요약}" \
  --body '> 🤖 **AI created**
## 1. 한 줄 요약
{요약}
## 2. 배경/문제
- 와 필요한가: {설명}
- 현재 불편/리스크/요구사항 변화: {설명}
- [ ] (필수) {요구사항1}
- [ ] (필수) {요구사항2}
- [ ] {작업1}
- [ ] {작업2}
- 관련 이슈/PR: {링크}
- 레퍼런스 문서/스펙: {링크}'
)"
```

### Task 이슈 예시

```bash
issue_url="$(gh issue create \
  --repo "$REPO" \
  --title "[Task] {상위 기능 제목} - {하위 태스크 요약}" \
  --body '> 🤖 **AI created**
## 상위 Feature
#{이슈번호}
## 1. 작업 요약
{작업 요약}
- [ ] API 개발...
- [ ] 테스트 케이스 작성 ...
- 링크/스크린샷/로그 등'
)"
```

### Bug 이슈 예시

```bash
issue_url="$(gh issue create \
  --repo "$REPO" \
  --title "[Bug] {문제가 요약된 제목}" \
  --body '> 🤖 **AI created**
## 1. 증상 한 줄 요약
{요약}
## 2. 기대 동작
{기대 동작}
{실제 동작}
1. {단계1}
2. {단계2}
{항상 | 가끔 | 특정 조건에서만 | 재현 불가}
{치명 | 높음 | 중간 | 낮음}
- 해결 방법 1: {설명}'
)"
```

## 5. 프로젝트 연결

`AGENTS.md`에서 프로젝트 URL을 확인하고, 있으면 생성된 이슈를 프로젝트에 추가한다.

```bash
project_url="$(grep -E '^- 프로젝트 url:' AGENTS.md | sed 's/^- 프로젝트 url:[[:space:]]*//')"
project_number="$(echo "$project_url" | grep -oE '/projects/[0-9]+' | cut -d/ -f3 || true)"
  gh project item-add "$project_number" --owner AGMO-Inc --url "$issue_url"
fi
```

## 6. TODO-Issue.md 갱신

이슈 생성 후 `TODO-Issue.md`를 해당 이슈 기준으로 갱신한다.
`git-issue-start` 스킬의 TODO-Issue.md 템플릿을 따른다.

```markdown
# TODO-Issue

- 레포: <owner>/<repo>
- 이슈: #<생성된 이슈번호>
- 제목: <이슈 제목>
- 링크: <이슈 URL>

## 이슈 요약

(생성한 이슈의 본문 요약)

## 실행 과제

- [ ] (이슈의 작업 항목에서 파생)
```

## 7. 결과 보고

1. 생성된 이슈 URL과 번호를 공유한다.
2. 프로젝트 추가 여부를 안내한다.
3. `TODO-Issue.md` 갱신 완료를 안내한다.
4. 다음 단계(`git-issue-start`로 브랜치 생성 또는 바로 구현 시작)를 제안한다.

## 8. 코멘트 작성 규칙

이슈 코멘트/PR 코멘트 작성 시 첫 줄에 아래를 반드시 포함한다.
```text
> 🤖 **AI created**
```

## 9. 안전 규칙

1. 이슈 유형이 명시되지 않으면 반드시 사용자에게 확인한다 (Feature/Task/Bug 중 선택).
2. AI가 작성한 모든 텍스트에 `AI created` 표시를 포함한다.
3. 프로젝트 연결 실패 시 오류를 보고하고 이슈 생성은 유지한다.