---
name: save-plan
description: .omc/plans/의 플랜을 Obsidian vault/{프로젝트명}/plans/에 저장한다. 프로젝트 인덱스 자동 생성, frontmatter/wikilink 포함. "플랜 저장", "옵시디언에 플랜", "플랜 기록", "save plan" 등의 요청에 사용한다. OMC plan/ralplan/autopilot 완료 후 .omc/plans/에 기록되면 자동 실행된다.
---

# 플랜 → Obsidian 저장

**전제:** Vault 경로는 `$OBSIDIAN_VAULT_ROOT` 환경변수로 설정. (설정 방법: `.claude/skills/_obsidian-common/ref/setup.md` 참조)

**참조:** `.claude/skills/_obsidian-common/ref/` 하위 파일 참조.
- `frontmatter-schema.md` — Plan 노트 frontmatter 정의
- `link-strategy.md` — wikilink 규칙

**스크립트:** `.claude/skills/_obsidian-common/scripts/`
- `identify-project.sh` — REPO, OWNER, PROJECT 추출
- `ensure-project-index.sh` — 프로젝트 인덱스 확인/생성

## 워크플로우

### 1. 프로젝트 식별 + 소스 읽기 (병렬)

동시에 실행:
- **프로젝트:** `identify-project.sh` 또는 `git remote get-url origin`에서 OWNER/PROJECT 추출
- **소스:** `.omc/plans/`에서 가장 최근 수정된 `.md` 파일 읽기. 없으면 대화 컨텍스트에서 수집

### 2. 프로젝트 인덱스 확인

`ensure-project-index.sh ${PROJECT} ${OWNER}` 실행

### 3. Plan 노트 생성

**Filesystem-first** (빠르고 안정적):
```
${OBSIDIAN_VAULT_ROOT}/${PROJECT}/plans/[Plan] {제목}.md
```
디렉토리 없으면 `mkdir -p`로 생성. Obsidian CLI는 보조 수단으로만 사용.

**템플릿:** `ref/plan-template.md` 참조

### 4. 이슈 연결

`TODO-Issue.md`에 이슈 있으면 frontmatter `issue` 필드에 `"#번호"` 설정

### 5. 결과 보고

노트 경로, 인덱스 생성 여부, 다음 단계 제안 (`obsidian-to-issue` 또는 구현 시작)

## 자동 호출

OMC `plan`/`ralplan`/`autopilot` 완료 후 `.omc/plans/`에 기록되면 CLAUDE.md 규칙에 의해 자동 실행된다.

## 중복 체크

저장 전 `${OBSIDIAN_VAULT_ROOT}/${PROJECT}/plans/` 내 동일 제목 파일 존재 여부를 filesystem으로 확인. 존재 시 덮어쓰지 않고 사용자 확인.

## 안전 규칙

- 동일 제목 노트 존재 시 덮어쓰지 않고 사용자 확인
- 소스(`.omc/plans/` + 대화) 모두 없으면 오류 보고
- Obsidian 앱 미실행이어도 vault 직접 쓰기로 정상 동작
