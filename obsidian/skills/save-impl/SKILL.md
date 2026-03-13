---
name: save-impl
description: 구현 완료 후 작업 요약을 Obsidian vault/{프로젝트명}/implementations/에 저장한다. 관련 Plan에 양방향 wikilink 생성. "구현 내용 저장", "작업 정리", "옵시디언에 구현 기록", "impl 저장", "save impl", "구현 요약 저장" 등의 요청에 사용한다. 커밋/PR 완료 후 구현 내용을 Obsidian에 기록할 때 트리거된다.
---

# 구현 요약 → Obsidian 저장

**전제:** Vault 경로는 `$OBSIDIAN_VAULT_ROOT` 환경변수로 설정. (설정 방법: `.claude/skills/_obsidian-common/ref/setup.md` 참조)

**참조:** `.claude/skills/_obsidian-common/ref/` 하위 파일 참조.
- `frontmatter-schema.md` — Impl 노트 frontmatter 정의
- `link-strategy.md` — wikilink/외부 링크 규칙

**스크립트:** `.claude/skills/_obsidian-common/scripts/`
- `identify-project.sh` — REPO, OWNER, PROJECT 추출
- `ensure-project-index.sh` — 프로젝트 인덱스 확인/생성
- `collect-git-info.sh` — 변경 파일, 이슈/PR, 브랜치 정보 수집

## 워크플로우

1. **프로젝트 식별** — `identify-project.sh` 실행
2. **구현 정보 수집** — `collect-git-info.sh` 실행 + 대화 컨텍스트에서 요약
3. **Plan 노트 검색** — `obsidian search query="issue: \"${ISSUE_NUM}\""` 또는 `path:${PROJECT}/plans`
4. **프로젝트 인덱스 확인** — `ensure-project-index.sh ${PROJECT} ${OWNER}` 실행
5. **Impl 노트 생성** — `ref/impl-template.md` 참조하여 Obsidian에 생성:
   ```bash
   obsidian create name="[Impl] {제목}" path="${PROJECT}/implementations/" content="{내용}"
   ```
   Obsidian CLI 불가 시 fallback: `${OBSIDIAN_VAULT_ROOT}/${PROJECT}/implementations/[Impl] {제목}.md` 직접 쓰기
6. **프로젝트 인덱스 업데이트** — 인덱스 노트의 Implementations 섹션에 새 Impl wikilink 추가:
   ```bash
   obsidian append file="${PROJECT}" content="\n- [[${PROJECT}/implementations/[Impl] {제목}]]"
   ```
   CLI 불가 시 fallback: `${OBSIDIAN_VAULT_ROOT}/${PROJECT}/${PROJECT}.md`에 직접 append
7. **Plan 역링크** — Plan 노트에 Impl 링크 append + status를 `done`으로 변경:
   ```bash
   obsidian append file="{PLAN_NOTE}" content="\n- 구현: [[${PROJECT}/implementations/[Impl] {제목}]]"
   obsidian property:set file="{PLAN_NOTE}" name=status value="done"
   ```
8. **결과 보고** — Impl 노트 경로, 인덱스 업데이트 여부, Plan 역링크 여부 안내

## 안전 규칙

- 동일 제목 노트 존재 시 덮어쓰지 않고 사용자 확인
- Plan 없어도 Impl 생성 가능 (plan 링크만 비움)
- git 정보 불가 시 대화 컨텍스트만으로 생성
- Obsidian CLI 불가 시 vault 직접 쓰기 fallback
