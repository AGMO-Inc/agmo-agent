---
name: obsidian-search
description: "Obsidian vault에서 키워드로 노트를 검색한다. 사용자가 이전 작업 기록, 설계 문서, 플랜, 구현 내역 등을 찾고 싶을 때 사용한다. '옵시디언에서 찾아줘', '이전에 작성한 X', '관련 노트 있어?', 'vault에서 검색' 등의 요청에 트리거된다."
---

# Obsidian Vault 검색

Obsidian CLI로 vault를 검색한다. 앱 실행 필수.

**CLI 레퍼런스:** `_obsidian-common/ref/cli-reference.md`

## 워크플로우

1. `obsidian search:context query="{keyword}" format=json` 실행
2. 결과 15건 이상이면 `limit=10` 또는 `path=`로 범위 축소
3. 결과 없으면 키워드 분리/유사어로 재검색
4. 사용자가 선택한 노트만 `obsidian read file="{이름}"`으로 읽기
5. 연결 문서 필요 시 `obsidian backlinks file="{이름}" format=json`

## 결과 보고

파일 목록과 매칭 문맥만 간결하게 보고. 전체 내용을 미리 읽지 않는다.

```
### 검색 결과: "{keyword}" (N건)
- `프로젝트/타입/제목.md` — 매칭 문맥 요약
```

## 범위 좁히기

| 사용자 표현 | 방법 |
|-------------|------|
| "{프로젝트명}에서" | `path="{프로젝트명}"` |
| "태그로" | `obsidian tag name="{태그}" verbose` |
| "플랜/설계/구현 중에서" | 결과에서 경로 필터 |
