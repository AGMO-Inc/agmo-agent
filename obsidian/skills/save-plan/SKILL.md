---
name: save-plan
description: .omc/plans/의 플랜을 Obsidian vault/{프로젝트명}/plans/에 저장한다. 프로젝트 인덱스 자동 생성, frontmatter/wikilink 포함.
---

# 플랜 → Obsidian 저장

**전제:** Obsidian 앱 실행 중. Vault 경로는 `OBSIDIAN_VAULT` 환경변수로 설정.

**참조:** `_obsidian-common/ref/` 하위 파일
- `frontmatter-schema.md` — Plan 노트 frontmatter 정의
- `link-strategy.md` — wikilink 규칙
- `cli-reference.md` — Obsidian CLI 명령어

**스크립트:** `_obsidian-common/scripts/`
- `identify-project.sh` — REPO, OWNER, PROJECT 추출
- `ensure-project-index.sh` — 프로젝트 인덱스 확인/생성

## 워크플로우

1. **프로젝트 식별** — `identify-project.sh` 실행
2. **소스 읽기** — `.omc/plans/`에서 최신 파일. 없으면 대화 컨텍스트에서 수집
3. **프로젝트 인덱스 확인** — `ensure-project-index.sh ${PROJECT} ${OWNER}` 실행
4. **Plan 노트 생성** — `ref/plan-template.md` 참조하여 생성:
   - 경로: `${VAULT}/${PROJECT}/plans/[Plan] {제목}.md`
   - Obsidian CLI: `obsidian create name="[Plan] {제목}" path="${PROJECT}/plans/" content="{내용}"`
   - CLI 불가 시 fallback: vault 경로에 직접 쓰기
5. **이슈 연결** — `TODO-Issue.md`에 이슈가 있으면 frontmatter `issue` 필드 업데이트
6. **결과 보고** — 노트 경로, 인덱스 생성 여부, 다음 단계 제안

## 안전 규칙

- 동일 제목 노트 존재 시 덮어쓰지 않고 사용자 확인
- 소스 모두 없으면 오류 보고
- Obsidian CLI 불가 시 vault 직접 쓰기 fallback
