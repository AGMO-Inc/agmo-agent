---
name: obsidian-to-issue
description: Obsidian 노트를 GitHub Issue로 변환한다. frontmatter에서 이슈 유형을 읽고 gh issue create 실행 후 원본 노트에 이슈 링크를 역삽입한다. 사용자가 '노트로 이슈 만들어', '이슈로 변환', '이슈 생성', '이거 이슈로', '깃허브 이슈', 'obsidian issue', '노트 이슈화' 등 Obsidian 노트를 GitHub Issue로 만들고 싶다는 의도를 보이면 반드시 이 스킬을 사용한다. 단순히 gh issue create만 하는 게 아니라, 프로젝트 보드 등록, Status 설정, Parent 연결, 원본 노트 역삽입까지 전체 워크플로우를 자동화한다.
---

# Obsidian 노트 → GitHub Issue 변환

**전제:** Vault 경로는 `$OBSIDIAN_VAULT_ROOT` 환경변수로 설정. (설정 방법: `.claude/skills/_obsidian-common/ref/setup.md` 참조)

**참조:** `.claude/skills/_obsidian-common/ref/` 하위 파일 참조.
- `frontmatter-schema.md` — frontmatter 필드 정의
- `link-strategy.md` — wikilink/외부 링크 규칙
- `issue-template-mapping.md` — 이슈 유형별 템플릿 매핑 (SSOT)
- `cli-reference.md` — Obsidian CLI 명령어 레퍼런스

## 워크플로우

### Phase 1: 정보 수집 (병렬 처리)

아래 3가지를 동시에 수집한다:

**A) 프로젝트 정보** — 현재 프로젝트 경로의 `AGENTS.md` 파일에서 `## 레포/프로젝트 정보` 섹션을 파싱하여 추출:
  - `조직` → OWNER (예: `AGMO-Inc`)
  - `프로젝트명` → PROJECT_NAME
  - `프로젝트 url` → PROJECT_URL
  - `레포` → REPO (git URL에서 `{OWNER}/{REPO_NAME}` 추출)
  - AGENTS.md가 없거나 해당 섹션이 없으면 `.claude/skills/_obsidian-common/scripts/identify-project.sh` → 사용자 질문 순서로 fallback

**B) 실행자 확인** — `gh api user --jq '.login'`으로 ASSIGNEE 확보

**C) 대상 노트 읽기** — 사용자 지정 경로 또는 `obsidian search`로 검색

### Phase 2: 노트 분석 및 사용자 확인 (1회 질의로 통합)

1. **frontmatter 파싱** — `type`, `project`, `issue-type`, `issue` 추출. `issue`에 값이 이미 있으면 중복 경고 후 진행 여부 확인.
2. **사용자 확인 — 필요한 항목을 한 번에 질의한다:**
   - `issue-type` 없으면 → 유형 질의 (feature / task / bug)
   - `issue-type: task`이면 → 상위 Feature 이슈 번호 질의
   - Status 미지정이면 → Status 질의 (Todo / In Progress / Weekly Done)

   이 질의들을 개별로 하지 않고, 필요한 항목을 모아서 한 번에 묻는다.

### Phase 3: 이슈 생성

3. **템플릿 매핑** — `_obsidian-common/ref/issue-template-mapping.md` 참조하여 노트 본문을 이슈 섹션에 매핑
4. **이슈 생성** — Assignee 포함:
   ```bash
   gh issue create --repo "$REPO" \
     --title "{매핑된 제목}" \
     --body "{매핑된 본문}" \
     --assignee "$ASSIGNEE"
   ```
   본문 첫 줄: `> 🤖 **AI created** — Obsidian 노트에서 변환됨`

### Phase 4: 프로젝트 연동 (순차 실행)

5. **프로젝트 등록** — PROJECT_URL에서 프로젝트 번호를 추출:
   ```bash
   gh project item-add {PROJECT_NUMBER} --owner "{OWNER}" --url "{ISSUE_URL}"
   ```

6. **프로젝트 Status 설정** — 등록된 아이템의 Status 필드를 Phase 2에서 확인한 값으로 설정:
   ```bash
   # 아이템 ID 조회
   ITEM_ID=$(gh project item-list {PROJECT_NUMBER} --owner "{OWNER}" --format json \
     --jq ".items[] | select(.content.url == \"{ISSUE_URL}\") | .id")

   # Status 필드 ID 및 옵션 ID 조회
   gh project field-list {PROJECT_NUMBER} --owner "{OWNER}" --format json \
     --jq '.fields[] | select(.name == "Status")'

   # Status 값 설정
   gh project item-edit \
     --project-id "{PROJECT_NODE_ID}" \
     --id "$ITEM_ID" \
     --field-id "$FIELD_ID" \
     --single-select-option-id "$OPTION_ID"
   ```

7. **Task Parent 등록** — 상위 Feature 이슈 번호가 있는 경우에만:
   ```bash
   gh issue edit {NEW_ISSUE_NUMBER} --repo "$REPO" --add-parent "{PARENT_ISSUE_NUMBER}"
   ```
   `--add-parent` 미지원 gh 버전이면 GraphQL fallback:
   ```bash
   gh api graphql -f query='mutation { addSubIssue(input: { issueId: "{PARENT_NODE_ID}", subIssueId: "{CHILD_NODE_ID}" }) { issue { id } } }'
   ```

### Phase 5: 원본 노트 업데이트

8. **Obsidian CLI로 노트 업데이트** (앱 실행 중일 때):
   ```bash
   obsidian property:set file="{노트명}" name=issue value="\"#${N}\""
   obsidian property:set file="{노트명}" name=status value="issued"
   obsidian append file="{노트명}" content="\n\n---\n> GitHub Issue: [#${N}](${url})"
   ```
   Obsidian 앱이 미실행이면 `$OBSIDIAN_VAULT_ROOT` 경로에서 직접 파일을 편집하여 frontmatter의 `issue`, `status` 값을 수정하고 본문 끝에 이슈 링크를 추가한다.

### Phase 6: 결과 보고

9. **완료 보고** — 아래 항목을 요약:
   - 이슈 URL
   - 프로젝트 등록 여부 + Status 설정값
   - Assignee
   - Parent 연결 여부 (task인 경우)
   - 노트 업데이트 완료 여부

## 안전 규칙

- `issue` 값이 이미 있으면 중복 경고 후 사용자 확인 없이 진행하지 않는다
- `issue-type` 없으면 사용자에게 확인 (feature / task / bug)
- AI 작성 텍스트에 `AI created` 표시 필수
- Obsidian CLI 실패 시 직접 파일 편집으로 fallback
