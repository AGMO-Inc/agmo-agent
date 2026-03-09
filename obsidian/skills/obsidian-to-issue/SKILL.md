---
name: obsidian-to-issue
description: Obsidian 노트를 GitHub Issue로 변환한다. frontmatter에서 이슈 유형을 읽고 gh issue create 실행 후 원본 노트에 이슈 링크를 역삽입한다.
---

# Obsidian 노트 → GitHub Issue 변환

**전제:** Obsidian 앱 실행 중. `gh` CLI 인증 완료.

**참조:** `_obsidian-common/ref/` 하위 파일
- `frontmatter-schema.md` — frontmatter 필드 정의
- `link-strategy.md` — wikilink/외부 링크 규칙
- `cli-reference.md` — Obsidian CLI 명령어

## 워크플로우

1. **대상 노트 읽기** — 사용자 지정 또는 `obsidian search`로 검색
2. **frontmatter 파싱** — `type`, `project`, `issue-type` 추출. `issue`에 값이 있으면 중복 경고
3. **repo 매핑** — 프로젝트 인덱스 노트의 `repo` 필드 사용. 없으면 `identify-project.sh` 실행
4. **이슈 생성** — `gh issue create --repo "$REPO" --title "{제목}" --body "{본문}"`. 본문 첫 줄: `> AI created — Obsidian 노트에서 변환됨`
5. **프로젝트 보드 연결** — 인덱스의 `project-url`에서 번호 추출 → `gh project item-add`
6. **원본 노트 업데이트**:
   - `obsidian property:set file="{노트명}" name=issue value="\"#${N}\""`
   - `obsidian property:set file="{노트명}" name=status value="issued"`
   - `obsidian append file="{노트명}" content="\n\n---\n> GitHub Issue: [#${N}](${url})"`
7. **결과 보고** — 이슈 URL, 프로젝트 연결 여부, 노트 업데이트 완료 안내

## 안전 규칙

- `issue` 값이 이미 있으면 중복 경고
- `issue-type` 없으면 사용자에게 확인 (feature/task/bug)
- AI 작성 텍스트에 `AI created` 표시 필수
