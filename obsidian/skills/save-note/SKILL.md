---
name: save-note
description: "대화 중 생성된 다양한 노트(설계, 리서치, 회의록, 메모 등)를 Obsidian vault/{프로젝트명}/{타입}s/에 저장한다. plan이나 impl이 아닌 모든 종류의 프로젝트 문서를 저장할 때 사용한다. '옵시디언에 저장', '노트 저장', '기록해줘', '정리해줘' 등의 요청에 트리거된다."
---

# 범용 노트 → Obsidian 저장

**전제:** Vault 경로는 `OBSIDIAN_VAULT` 환경변수로 설정.

**참조:** `_obsidian-common/ref/` 하위 파일, `ref/note-templates.md`

**스크립트:** `_obsidian-common/scripts/`
- `identify-project.sh`, `ensure-project-index.sh`

## 지원 노트 타입

| 타입 | 접두사 | 저장 경로 |
|------|--------|-----------|
| `design` | `[Design]` | `{PROJECT}/designs/` |
| `research` | `[Research]` | `{PROJECT}/research/` |
| `meeting` | `[Meeting]` | `{PROJECT}/meetings/` |
| `memo` | `[Memo]` | `{PROJECT}/memos/` |

## 워크플로우

1. **프로젝트 식별** — `identify-project.sh` 실행. git repo가 아니면 현재 디렉토리명 사용
2. **노트 타입 결정** — 대화 맥락에서 추론 (설계→design, 조사→research, 회의→meeting, 기타→memo)
3. **내용 수집** — 대화 컨텍스트에서 저장할 내용 수집
4. **프로젝트 인덱스 확인** — `ensure-project-index.sh ${PROJECT} ${OWNER}`
5. **노트 생성** — `ref/note-templates.md` 템플릿으로 생성. CLI 불가 시 vault 직접 쓰기
6. **프로젝트 인덱스 업데이트** — 새 노트 wikilink 추가

## 안전 규칙

- 동일 제목 노트 존재 시 덮어쓰지 않고 사용자 확인
- 저장할 내용 없으면 오류 보고
- 기존 인덱스 내용은 절대 삭제 안 함 (append만)
