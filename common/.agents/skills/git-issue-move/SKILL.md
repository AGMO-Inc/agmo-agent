---
name: git-issue-move
description: GitHub 프로젝트 보드에서 이슈의 상태를 변경하는 스킬이다. 이슈 번호를 명시하지 않으면 TODO-Issue.md의 현재 이슈를 대상으로 하고, 상태를 명시하지 않으면 Weekly Done으로 이동한다. "이슈 weekly done으로 옮겨줘", "이슈 상태 변경해줘", "#424 Done으로", "이슈 정리해줘" 같은 요청에서 사용한다.
---

# Issue Move Workflow

이 스킬로 GitHub 프로젝트 보드의 이슈 상태를 변경한다.

## 0. 레포 및 프로젝트 식별

1. `git remote -v`로 현재 레포의 `<owner>/<repo>`를 추출한다.
2. `AGENTS.md` 또는 프로젝트 설정에서 프로젝트 번호를 확인한다.
3. owner가 조직이면 `organization`, 개인이면 `user`로 GraphQL 쿼리한다.

## 1. 대상 이슈 확인

1. 이슈 번호가 명시되면 해당 이슈를 대상으로 한다.
2. 명시되지 않으면 `TODO-Issue.md`에서 현재 이슈 번호를 가져온다.
3. 복수 이슈가 지정되면 모두 처리한다.

## 2. 목표 상태 결정

상태가 명시되지 않으면 `Weekly Done`을 기본값으로 사용한다.

## 3. 프로젝트 메타데이터 조회

프로젝트 ID, Status 필드 ID, 상태 옵션 목록을 동적으로 조회한다.

```bash
gh api graphql -f query='{
  organization(login: "<owner>") {
    projectV2(number: <프로젝트번호>) {
      id
      fields(first: 30) {
        nodes {
          ... on ProjectV2SingleSelectField {
            id
            name
            options { id name }
          }
        }
      }
    }
  }
}'
```

응답에서 추출:
- `projectV2.id` → Project ID
- `fields.nodes`에서 `name == "Status"` → Status Field ID
- `options` → 각 상태의 Option ID

## 4. 프로젝트 보드에서 Item ID 조회

```bash
gh api graphql -f query='{
  organization(login: "<owner>") {
    projectV2(number: <프로젝트번호>) {
      items(first: 100) {
        nodes {
          id
          content {
            ... on Issue { number title }
          }
        }
      }
    }
  }
}'
```

조회 결과에서 대상 이슈의 `id`(프로젝트 item ID)를 추출한다.

## 5. 상태 변경

```bash
gh api graphql -f query='
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "<project_id>"
    itemId: "<item_id>"
    fieldId: "<status_field_id>"
    value: { singleSelectOptionId: "<option_id>" }
  }) { projectV2Item { id } }
}'
```

복수 이슈는 하나의 mutation에 alias로 묶어 한 번에 처리한다.

```bash
gh api graphql -f query='
mutation {
  issue1: updateProjectV2ItemFieldValue(input: {
    projectId: "<project_id>"
    itemId: "<item_id_1>"
    fieldId: "<status_field_id>"
    value: { singleSelectOptionId: "<option_id>" }
  }) { projectV2Item { id } }
  issue2: updateProjectV2ItemFieldValue(input: {
    projectId: "<project_id>"
    itemId: "<item_id_2>"
    fieldId: "<status_field_id>"
    value: { singleSelectOptionId: "<option_id>" }
  }) { projectV2Item { id } }
}'
```

## 6. 결과 보고

변경된 이슈 번호와 상태를 표로 출력한다.

```text
| 이슈 | 변경 상태 |
|---|---|
| #123 | → Weekly Done |
| #456 | → Weekly Done |
```

## 7. 안전 규칙

1. 이 스킬은 상태 변경만 수행한다. 이슈 본문/제목을 수정하지 않는다.
2. 존재하지 않는 이슈 번호는 오류를 보고한다.
3. 프로젝트 보드에 없는 이슈는 오류를 보고한다.
