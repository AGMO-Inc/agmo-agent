---
name: h2-console
description: H2 DB 웹 콘솔 실행/종료. "h2", "db console", "database" 키워드 시 발동. 인자: open(기본) | stop | help
---

# H2 Database Web Console

H2 파일 DB를 브라우저에서 조회하기 위한 웹 콘솔 기동/종료 스킬.

## 실행

| 인자 | 동작 |
|------|------|
| `open` / (없음) | `bash scripts/h2-open.sh` 실행 |
| `stop` | `bash scripts/h2-stop.sh` 실행 |
| `help` | `references/connection-info.md` 읽어서 접속 정보 출력 |

스크립트는 프로젝트 루트에서 실행할 것.

## 주의

- 앱(port 1456)과 H2 Console은 동시 실행 불가 (파일 DB 잠금)
- `open` 시 앱이 자동 종료됨
