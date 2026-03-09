# Obsidian Skills for Claude Code

Claude Code 에이전트가 Obsidian vault와 연동하여 프로젝트 문서를 자동 관리하는 스킬 패키지.

## 개요

이 패키지는 Claude Code 에이전트가 다음을 수행할 수 있게 한다:

- **Plan 저장** — OMC 플래닝 결과를 Obsidian vault에 자동 기록
- **Implementation 저장** — 구현 완료 후 작업 요약을 vault에 기록, Plan과 양방향 링크
- **범용 노트 저장** — 설계/리서치/회의록/메모를 vault에 기록
- **노트 → GitHub Issue** — vault 노트를 GitHub Issue로 변환, 역링크 자동 삽입
- **Vault 검색** — 키워드로 vault 내 노트 검색

## 스킬 목록

| 스킬 | 설명 | 트리거 키워드 |
|------|------|---------------|
| `save-plan` | `.omc/plans/` → vault plans 폴더 | "플랜 저장", "옵시디언에 플랜" |
| `save-impl` | 구현 요약 → vault implementations 폴더 | "구현 내용 저장", "작업 정리" |
| `save-note` | 범용 노트 → vault designs/research/meetings/memos | "옵시디언에 저장", "노트 저장", "기록해줘" |
| `obsidian-to-issue` | vault 노트 → GitHub Issue 변환 | "노트로 이슈 만들어", "이슈로 변환" |
| `obsidian-search` | vault 키워드 검색 | "옵시디언에서 찾아", "vault 검색" |

## 디렉토리 구조

```
obsidian/
├── README.md                          ← 이 파일
├── installation.md                    ← 설치 가이드 (에이전트 전용)
└── skills/
    ├── _obsidian-common/              ← 공통 리소스
    │   ├── ref/
    │   │   ├── cli-reference.md       ← Obsidian CLI 명령어
    │   │   ├── frontmatter-schema.md  ← YAML frontmatter 스키마
    │   │   └── link-strategy.md       ← wikilink/외부 링크 규칙
    │   └── scripts/
    │       ├── identify-project.sh    ← git remote → REPO/OWNER/PROJECT
    │       ├── ensure-project-index.sh← 프로젝트 인덱스 노트 생성
    │       └── collect-git-info.sh    ← 변경 파일/이슈/PR 정보 수집
    ├── save-plan/
    │   ├── SKILL.md
    │   └── ref/plan-template.md
    ├── save-impl/
    │   ├── SKILL.md
    │   └── ref/impl-template.md
    ├── save-note/
    │   ├── SKILL.md
    │   └── ref/note-templates.md
    ├── obsidian-to-issue/
    │   └── SKILL.md
    └── obsidian-search/
        └── SKILL.md
```

## Vault 자동 생성 구조

스킬이 처음 실행될 때 vault에 다음 구조를 자동 생성한다:

```
${OBSIDIAN_VAULT_ROOT}/
└── {프로젝트명}/
    ├── {프로젝트명}.md          ← 프로젝트 인덱스 (허브 노트)
    ├── plans/
    │   └── [Plan] 제목.md
    ├── implementations/
    │   └── [Impl] 제목.md
    ├── designs/
    │   └── [Design] 제목.md
    ├── research/
    │   └── [Research] 제목.md
    ├── meetings/
    │   └── [Meeting] 제목.md
    └── memos/
        └── [Memo] 제목.md
```

프로젝트 인덱스 노트는 backlink 패널을 통해 모든 Plan/Impl/노트를 한눈에 보여주는 허브 역할을 한다.

## 설치 방법

아래 프롬프트를 AI code agent에게 붙여넣는다. (Claude Code, Codex, Cursor 등)

```
Configure Obsidian skills for this project by following the instructions here:
curl -s https://raw.githubusercontent.com/AGMO-Inc/agmo-agent/refs/heads/main/obsidian/installation.md
```

이후 Agent의 지시사항을 따르면 된다. (vault 경로, 설치할 스킬 범위 등을 질문받는다)

## 의존성

| 항목 | 필수 여부 | 용도 |
|------|-----------|------|
| Obsidian 1.12+ | 필수 | CLI 지원 버전 |
| Obsidian CLI 활성화 | 필수 | 앱 설정 → 일반 → 명령줄 인터페이스 |
| gh CLI | `obsidian-to-issue` 사용 시 | GitHub Issue 연동 |
| Claude Code | 필수 | `.claude/skills/` 디렉토리 |

## 라이선스

AGMO-Inc 내부 사용.
