---
name: obsidian-search
description: "Obsidian vault에서 키워드로 노트를 검색한다. 사용자가 이전 작업 기록, 설계 문서, 플랜, 구현 내역 등을 찾고 싶을 때 사용한다. '옵시디언에서 찾아줘', '이전에 작성한 X', '관련 노트 있어?', 'vault에서 검색', '기존 문서 확인', '예전에 정리한 거' 등의 요청에 트리거된다. 프로젝트명, 기능명, 키워드 등 어떤 검색어든 가능하다. 사용자가 경로를 직접 지정하지 않아도 vault 전체를 검색할 수 있다."
---

# Obsidian Vault 검색

**전제:** Vault 경로는 `$OBSIDIAN_VAULT_ROOT` 환경변수로 설정. (설정 방법: `.claude/skills/_obsidian-common/ref/setup.md` 참조)
**CLI 레퍼런스:** `.claude/skills/_obsidian-common/ref/cli-reference.md`

## 검색 전략 (우선순위)

### 1차: Obsidian CLI (앱 실행 중)

```bash
obsidian search:context query="{keyword}" format=json
```

- 결과 15건 초과 → `limit=10` 또는 `path=`로 범위 축소
- 현재 프로젝트 관련 검색이면 → `path="{프로젝트명}"` 자동 추가
  - 프로젝트명은 현재 작업 디렉토리의 레포명(예: `monitor-server`, `monitor-admin`)

### 2차: 직접 파일 검색 (CLI 실패 또는 앱 미실행)

Vault 경로에서 Grep/Glob 도구로 직접 검색:
```
Grep: pattern="{keyword}", path="$OBSIDIAN_VAULT_ROOT", glob="*.md"
```

### 빈 결과 재시도

| 순서 | 방법 | 예시 |
|------|------|------|
| 1 | 키워드 분리 | "제품주문 관리" → "제품주문", "관리" 각각 |
| 2 | 영한 변환 | "IAM" ↔ "권한", "order" ↔ "주문" |
| 3 | 노트 유형별 폴더 탐색 | `obsidian files folder="{프로젝트}/plans"` |
| 4 | 태그 검색 | `obsidian tag name="{태그}" verbose` |

## 연결 문서 탐색

사용자가 특정 노트의 관련 문서를 원하면:
```bash
obsidian backlinks file="{노트명}" format=json
obsidian links file="{노트명}"
```

## 결과 보고

파일 목록과 매칭 문맥만 간결하게 보고. 전체 내용을 미리 읽지 않는다.

```
### 검색 결과: "{keyword}" (N건)
- `프로젝트/타입/제목.md` — 매칭 문맥 요약
```

사용자가 특정 노트를 선택하면 `obsidian read file="{이름}"` 또는 직접 `Read` 도구로 읽기.
