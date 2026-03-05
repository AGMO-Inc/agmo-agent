---
name: rest-verifier
description: REST API 검증기 — 앱 빌드/기동 후 curl 테스트 실행 및 응답 검증
triggers:
  - verify
  - verifier
  - api test
  - api 검증
  - 검증
argument-hint: "help | <domain> | all"
aliases: [api-verify, rest-verify]
quality: high
model: sonnet
context: fork
agent: seamos-tester
---

# REST API Verifier

> **Agent 위임**: 이 스킬의 모든 작업은 Agent 도구를 사용하여 `seamos-tester` 에이전트에게 위임하여 실행할 것. Agent 호출 시 사용자의 요청 내용과 파싱된 인자를 프롬프트로 전달한다.

ApplicationMain.java를 빌드/기동하고, `.claude/test/{domain}.md`의 curl 테스트를 실행하여 API 응답을 검증하는 스킬.

## When to Activate

- 사용자가 REST API 검증을 요청할 때
- "verify", "verifier", "api test", "api 검증" 키워드 감지 시
- seamos-rest 스킬 완료 후 연쇄 트리거로 호출될 때

## Arguments Parsing

| 인자 패턴 | 동작 |
|-----------|------|
| `help` | 사용법 안내 출력 |
| `<domain>` | 특정 도메인만 검증 (예: `task`, `crop`, `machine`) |
| `all` 또는 인자 없음 | `.claude/test/*.md` 전체 검증 (`*-result.md` 제외) |

---

## help 명령어

`help`가 인자일 때 아래 내용을 사용자에게 출력:

```
REST API Verifier (/rest-verifier)

사용법:
  /rest-verifier help              - 이 도움말 표시
  /rest-verifier task              - task 도메인만 검증
  /rest-verifier all               - 모든 도메인 검증
  /rest-verifier                   - 모든 도메인 검증 (all과 동일)

동작: 포트 충돌 해소 → 빌드 → 기동 → curl 테스트 → JSON 검증 → 리포트 → 앱 종료

검증 규칙:
  - 고정 값 (status, deletedCount, message): 정확한 일치 비교
  - 동적 값 (id, createdAt): 존재 여부만 확인
  - 배열 (contents): 배열 여부 + 내부 객체 키 존재 확인
```

---

## 실행 절차

### Step 0: allowedTools 안내

서브에이전트가 Bash 명령(포트 kill, mvn 빌드, java 기동, curl 테스트 등)을 **승인 프롬프트 없이** 자동 실행하려면 사전에 Bash 도구가 허용되어야 한다.

허용되지 않은 경우 사용자에게 아래 안내를 출력하고 종료:

```
⚠️ REST API Verifier는 Bash 명령을 자동 실행합니다.
매 스텝마다 승인 프롬프트 없이 진행하려면 아래 중 하나를 설정하세요:

1. (권장) /allowed-tools 에서 Bash 도구를 허용 목록에 추가
   → 실행 후 "Bash(run build and test commands)" 등을 추가

2. 세션 시작 시 --dangerously-skip-permissions 플래그 사용
   → claude --dangerously-skip-permissions

현재 설정에서는 각 Bash 명령마다 수동 승인이 필요합니다.
```

### Step 1: Pre-checks

1. 대상 테스트 파일 확인 (`.claude/test/{domain}.md`, `*-result.md` 제외)
2. 테스트 파일이 없으면 "rest-test 스킬을 먼저 실행하세요" 안내 후 종료

### Step 2: 서브에이전트 프롬프트 구성 및 소환

**대상 테스트 파일 목록**과 함께 `Task(subagent_type="general-purpose", model="sonnet")` 서브에이전트를 소환한다. 모델은 반드시 `"sonnet"` (claude-sonnet-4-6)을 명시적으로 지정한다.


프롬프트의 `{테스트 파일 경로 목록}`을 실제 파일 경로로 치환하여 전달한다.

### Step 3: 결과 요약 출력

서브에이전트 반환 후, 결과를 사용자에게 간결하게 요약 출력:

```
## API 검증 완료

| 도메인 | 총 테스트 | PASS | FAIL | 결과 파일 |
|--------|----------|------|------|----------|
| task | 3 | 3 | 0 | .claude/test/task-result.md |
```

---

## 주요 참조 파일

| 파일 | 역할 |
|------|------|
| `{projName}/src/com/bosch/nevonex/main/impl/ApplicationMain.java` | 앱 엔트리포인트 |
| `{projName}/pom.xml` | Maven 빌드 설정 |
| `.claude/test/{domain}.md` | curl 테스트 소스 |
| `.claude/test/{domain}-result.md` | 검증 결과 출력 |

## Notes

- 서브에이전트는 `general-purpose` 타입으로 OMC 비의존
- **무질의 자동 실행**: 서브에이전트는 사용자에게 어떠한 질의도 하지 않음. 포트 충돌 자동 해소, 테스트 자동 실행, 서버 자동 종료
- 빌드/기동 실패 시 조기 중단하여 무한 대기 방지
- 테스트 순서: POST → GET → DELETE (데이터 의존성 해결)
