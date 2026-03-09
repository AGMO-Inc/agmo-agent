---
name: save-impl
description: 구현 완료 후 작업 요약을 Obsidian vault/{프로젝트명}/implementations/에 저장한다. 관련 Plan에 양방향 wikilink 생성.
---

# 구현 요약 → Obsidian 저장

**전제:** Obsidian 앱 실행 중. Vault 경로는 `OBSIDIAN_VAULT` 환경변수로 설정.

**참조:** `_obsidian-common/ref/` 하위 파일
- `frontmatter-schema.md` — Impl 노트 frontmatter 정의
- `link-strategy.md` — wikilink/외부 링크 규칙
- `cli-reference.md` — Obsidian CLI 명령어

**스크립트:** `_obsidian-common/scripts/`
- `identify-project.sh` — REPO, OWNER, PROJECT 추출
- `ensure-project-index.sh` — 프로젝트 인덱스 확인/생성
- `collect-git-info.sh` — 변경 파일, 이슈/PR, 브랜치 정보 수집

## 워크플로우

1. **프로젝트 식별** — `identify-project.sh` 실행
2. **구현 정보 수집** — `collect-git-info.sh` 실행 + 대화 컨텍스트에서 요약
3. **Plan 노트 검색** — `obsidian search query="issue: \"${ISSUE_NUM}\"" format=json` 또는 프로젝트 plans 폴더 탐색
4. **프로젝트 인덱스 확인** — `ensure-project-index.sh ${PROJECT} ${OWNER}` 실행
5. **Impl 노트 생성** — `ref/impl-template.md` 참조하여 생성:
   - 경로: `${VAULT}/${PROJECT}/implementations/[Impl] {제목}.md`
   - CLI 불가 시 fallback: vault 경로에 직접 쓰기
6. **Plan 역링크** — Plan 노트에 Impl 링크 append + status를 `done`으로 변경
7. **결과 보고** — Impl 노트 경로, Plan 역링크 여부

## 안전 규칙

- 동일 제목 노트 존재 시 덮어쓰지 않고 사용자 확인
- Plan 없어도 Impl 생성 가능 (plan 링크만 비움)
- git 정보 불가 시 대화 컨텍스트만으로 생성
