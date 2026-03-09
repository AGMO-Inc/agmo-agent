# Obsidian CLI 레퍼런스

Obsidian 앱 실행 중이어야 동작한다.

## 검색

```bash
# 텍스트 검색 (JSON)
obsidian search query="{keyword}" format=json

# 매칭 라인 컨텍스트 포함
obsidian search:context query="{keyword}" format=json

# 폴더 범위 지정
obsidian search query="{keyword}" path="{folder}" format=json

# 결과 수 제한
obsidian search query="{keyword}" limit=10 format=json

# 대소문자 구분
obsidian search query="{keyword}" case format=json
```

## 읽기/쓰기

```bash
# 파일 읽기 (wikilink 방식)
obsidian read file="{노트명}"

# 경로로 읽기
obsidian read path="{폴더/파일명.md}"

# 파일 생성
obsidian create name="{이름}" path="{경로}" content="{내용}"

# 내용 추가
obsidian append file="{노트명}" content="{내용}"

# 내용 앞에 추가
obsidian prepend file="{노트명}" content="{내용}"
```

## 메타데이터

```bash
# 태그 검색
obsidian tag name="{태그}" verbose

# 태그 목록
obsidian tags counts sort=count

# 프로퍼티 읽기
obsidian property:read name="{속성}" file="{노트명}"

# 프로퍼티 설정
obsidian property:set name="{속성}" value="{값}" file="{노트명}"
```

## 탐색

```bash
# 백링크 조회
obsidian backlinks file="{노트명}" format=json

# 아웃링크 조회
obsidian links file="{노트명}"

# 폴더 내 파일 목록
obsidian files folder="{폴더명}"

# 파일 정보
obsidian file file="{노트명}"
```
