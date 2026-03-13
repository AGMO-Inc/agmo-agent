---
name: save-note
description: 대화 중 생성된 다양한 노트(설계, 리서치, 회의록, 메모 등)를 Obsidian vault/{프로젝트명}/{타입}s/에 저장한다. plan이나 impl이 아닌 모든 종류의 프로젝트 문서를 저장할 때 사용한다. "옵시디언에 저장", "노트 저장", "기록해줘", "정리해줘" 등의 요청 시 자동 트리거된다. 브레인스토밍, 요구사항 분석, 설계 문서, 리서치, 회의록 등 plan/impl에 해당하지 않는 문서라면 이 스킬을 사용한다.
---

# 범용 노트 → Obsidian 저장

**전제:** Vault 경로는 `$OBSIDIAN_VAULT_ROOT` 환경변수로 설정. (설정 방법: `.claude/skills/_obsidian-common/ref/setup.md` 참조)

**참조:**
- `.claude/skills/_obsidian-common/ref/frontmatter-schema.md` — 기존 frontmatter 정의
- `.claude/skills/_obsidian-common/ref/link-strategy.md` — wikilink 규칙
- `.claude/skills/save-note/ref/note-templates.md` — 노트 타입별 템플릿

**공용 스크립트:** `.claude/skills/_obsidian-common/scripts/`
- `identify-project.sh` — REPO, OWNER, PROJECT 추출
- `ensure-project-index.sh` — 프로젝트 인덱스 확인/생성

## 지원 노트 타입

| 타입 | 접두사 | 저장 경로 | 용도 |
|------|--------|-----------|------|
| `design` | `[Design]` | `{PROJECT}/designs/` | 설계 문서, 요구사항 분석, 브레인스토밍 결과 |
| `research` | `[Research]` | `{PROJECT}/research/` | 기술 조사, 비교 분석, PoC 결과 |
| `meeting` | `[Meeting]` | `{PROJECT}/meetings/` | 회의록, 의사결정 기록 |
| `memo` | `[Memo]` | `{PROJECT}/memos/` | 자유 메모, 아이디어, 참고사항 |

타입이 명확하지 않으면 대화 맥락에서 추론한다. 추론이 어려우면 사용자에게 확인한다.

## 워크플로우

1. **프로젝트 식별** — `identify-project.sh` 실행. git repo가 아니면 현재 디렉토리명을 PROJECT로 사용
2. **노트 타입 결정** — 대화 맥락에서 타입 추론 (설계→design, 조사→research, 회의→meeting, 기타→memo)
3. **내용 수집** — 대화 컨텍스트에서 저장할 내용 수집. 이미 생성된 파일이 있으면 해당 내용 활용
4. **프로젝트 인덱스 확인** — `ensure-project-index.sh ${PROJECT} ${OWNER}` 실행
5. **프로젝트 인덱스에 섹션 추가** — 해당 타입 섹션이 인덱스에 없으면 추가
6. **노트 생성** — `ref/note-templates.md`의 해당 타입 템플릿으로 노트 생성:
   - 경로: `${OBSIDIAN_VAULT_ROOT}/${PROJECT}/{type}s/[{Prefix}] {제목}.md`
   - Obsidian CLI 불가 시 fallback: vault 경로에 직접 파일 쓰기
7. **프로젝트 인덱스 업데이트** — 인덱스 노트에 새 노트 wikilink 추가
8. **결과 보고** — 노트 경로, 인덱스 업데이트 여부 안내

## 여러 노트 한 번에 저장

관련 문서가 여러 개일 때 (예: 요구사항 분석 + 설계 문서) 한 번에 모두 저장할 수 있다.
각 노트를 순차 생성하고, 노트 간 wikilink로 연결한다.

## 안전 규칙

- 동일 제목 노트 존재 시 덮어쓰지 않고 사용자 확인
- 저장할 내용이 대화에 없으면 오류 보고
- Obsidian CLI 불가 시 vault 직접 쓰기 fallback
- 기존 프로젝트 인덱스의 다른 내용은 절대 삭제하지 않음 (append만)
