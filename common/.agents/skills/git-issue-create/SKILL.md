---
name: git-issue-create
description: GitHub Issue 생성 스킬. `AGMO-Inc/.github/.github/ISSUE_TEMPLATE`을 단일 SSOT로 Feature/Task/Bug 이슈를 생성한다. 연결된 프로젝트가 있으면 Project에 추가하며, AI가 작성한 이슈/코멘트/PR/커밋 텍스트에는 `AI created`를 반드시 포함한다.
---

# GitHub Issue 생성

`AGMO-Inc/.github/.github/ISSUE_TEMPLATE`을 단일 SSOT로 사용한다.

`04-문서화.md`, `05-주간회의.md`는 본 스킬의 생성 대상이 아니다.

## 0. 레포 식별

`git remote -v`로 현재 레포의 `<owner>/<repo>`를 추출한다.

```bash
REPO=$(git remote get-url origin | sed -E 's#.+[:/]([^/]+/[^/.]+)(\.git)?$#\1#')
```

## 0-1. 템플릿 확인

이슈 생성 전에 공용 SSOT 템플릿 파일/필드명을 먼저 확인한다.

```bash
gh api "repos/AGMO-Inc/.github/contents/.github/ISSUE_TEMPLATE?ref=main"
```

공용 템플릿 접근이 불가하면 오류를 보고하고 이슈 생성을 중단한다.

## 1. 이슈 유형 선택

사용자 요청에 이슈 유형이 명시되지 않으면 반드시 확인한다.

- **Feature**: 새로운 기능 개발
- **Task**: 상위 Feature의 하위 작업 단위
- **Bug**: 버그 리포트

## 2. 공통 규칙
1. 이슈 본문/코멘트/PR 본문/커밋 메시지에 AI가 작성한 텍스트가 있으면 반드시 `AI created` 표시를 넣는다.
2. 제목 형식은 공용 템플릿을 따른다.
3. 이슈 생성 후 연결된 프로젝트가 있으면 반드시 Project에 item-add 한다.

코멘트/본문 첫 줄 권장 형식:

```text
> 🤖 **AI created**
```

## 3. 템플릿 매핑
- Feature: `01-기능-개발.yml`
  - 제목: `[Feature] ...`
  - 본문 섹션: `1. 한 줄 요약`, `2. 배경/문제`, `3. 요구 사항`, `4. 작업 항목`, `5. 참고`, `6. 수용 기준 (선택)`, `7. 상태 모델 (선택)`, `8. API/프로토콜 (선택)`, `9. 데이터 모델 (선택)`, `10. 비기능 요구사항 (선택)`
- Task: `02-기능-개발---하위-태스크.yml`
  - 제목: `[Task] ...`
  - 본문 섹션: `상위 Feature`, `1. 작업 요약`, `2. 체크리스트`, `3. 참고 (선택)`, `4. 상세 수용 기준 (선택)`, `5. 검증 로그/링크 (선택)`
- Bug: `03-버그-리포트.yml`
  - 제목: `[Bug] ...`
  - 본문 섹션: `1. 증상 한 줄 요약`, `2. 기대 동작`, `3. 실제 동작`, `4. 재현 방법 (Optional)`, `5. 빈도`, `6. 사용자 영향`, `7. 해결 방법`

## 4. 이슈 생성

GitHub Issue Form YAML은 `gh issue create`에서 필드를 자동 매핑하지 않으므로, 템플릿 섹션 제목을 그대로 Markdown 본문에 맞춰 작성해 생성한다.

필수 섹션은 항상 포함하고, 선택 섹션은 이슈 성격(비동기 상태 관리/계약 정의/데이터 변경/검증 로그 필요 여부)에 따라 포함한다.

### Feature 이슈 예시

```bash
issue_url="$(gh issue create \
  --repo "$REPO" \
  --title "[Feature] {이슈 한줄 요약}" \
  --body '> 🤖 **AI created**
## 1. 한 줄 요약
ex. 디바이스 소유권 변경 기능 추가
## 2. 배경/문제
- 왜 필요한가:
- 현재 불편/리스크/요구사항 변화:
## 3. 요구 사항
- [ ] (필수) 관리자는 디바이스 소유권을 변경할 수 있어야 한다.
- [ ] (필수) 관리자는 디바이스의 소유자를 알 수 있어야 한다.
- [ ] (선택) 탈퇴한 회원에게 디바이스 소유권이 이전되지 않아야 한다.
- [ ] 추가적인 요구사항...
- [ ] (선택) (성능/응답시간/캐싱/동시성 요구)
- [ ] (선택) (로깅/모니터링/알림)
- [ ] (선택) 호환성(버전/마이그레이션/하위호환)
- [ ] 등등..
## 4. 작업 항목
- [ ] 디바이스 소유권 변경 UI 개발
- [ ] 디바이스 소유권 변경 API 개발
- [ ] 유닛 테스트
## 5. 참고
- 관련 이슈/PR:
- 레퍼런스 문서/스펙:
- 스크린샷/로그:
## 6. 수용 기준 (선택)
- [ ] AC-01: Given ... When ... Then ...
- [ ] AC-02: Given 요청 생성, When 처리 시작, Then 상태가 `REQUESTED`로 기록된다.
- [ ] AC-03: Given 실패 조건, When 타임아웃/검증 실패, Then `reasonCode`/`reasonMessage`를 조회할 수 있다.
## 7. 상태 모델 (선택)
- REQUESTED -> COMMAND_SENT -> DOWNLOADING -> INSTALLING -> REBOOTING -> SUCCEEDED
- 실패 전이: FAILED_VALIDATION | FAILED_DELIVERY | FAILED_DOWNLOAD | FAILED_INSTALL | FAILED_HEALTHCHECK | FAILED_TIMEOUT
- 정책상 재시도 시: FAILED_* -> REQUESTED
- 운영 상태: CANCELLED | ROLLED_BACK
## 8. API/프로토콜 (선택)
- User API: GET /api/v1/... , POST /api/v1/...
- Admin API: POST /api/v1/admin/... (생성/중단/재개)
- Async channel: MQTT topic or webhook/event
- report payload: jobId, status, progress, reasonCode, reasonMessage, reportedAt
## 9. 데이터 모델 (선택)
- main entity/table: feature_job(job_id, status, attempt, requested_at, updated_at)
- history table: feature_job_history(job_id, from_status, to_status, reason_code, reason_message, changed_at)
- related artifact/config: version, target, checksum
- index/constraint/migration note:
## 10. 비기능 요구사항 (선택)
- latency: 상태 변경 이벤트 처리 P95 < 5s
- api performance: 상태 조회 API P95 < 300ms
- reliability: 성공률/실패율 메트릭 수집 가능
- alarm: 실패율 임계치/타임아웃/DLQ 알람 발송'
)"
```

### Task 이슈 예시

```bash
issue_url="$(gh issue create \
  --repo "$REPO" \
  --title "[Task] {상위 기능 제목} - {하위 태스크 요약}" \
  --body '> 🤖 **AI created**
## 상위 Feature
ex. #123
## 1. 작업 요약
ex. 디바이스 소유권 테이블 스키마 설계
## 2. 체크리스트
- [ ] API 개발...
- [ ] 테스트 케이스 작성 ...
## 3. 참고 (선택)
- 링크/스크린샷/로그 등
## 4. 상세 수용 기준 (선택)
- Given ...
- When ...
- Then ...
## 5. 검증 로그/링크 (선택)
- 테스트 결과:
- 스크린샷:
- 로그 링크:'
)"
```

### Bug 이슈 예시

```bash
issue_url="$(gh issue create \
  --repo "$REPO" \
  --title "[Bug] {문제가 요약된 제목}" \
  --body '> 🤖 **AI created**
## 1. 증상 한 줄 요약
{요약}
## 2. 기대 동작
{기대 동작}
## 3. 실제 동작
{실제 동작}
## 4. 재현 방법 (Optional)
1. {단계1}
2. {단계2}
## 5. 빈도
{항상 | 가끔 | 특정 조건에서만 | 재현 불가}
## 6. 사용자 영향
{치명 | 높음 | 중간 | 낮음}
## 7. 해결 방법
- 해결 방법 1: {설명}'
)"
```

## 5. 프로젝트 연결

`AGENTS.md`에서 프로젝트 URL을 확인하고, 있으면 생성된 이슈를 프로젝트에 추가한다.

```bash
project_url="$(grep -E '^- 프로젝트 url:' AGENTS.md | sed 's/^- 프로젝트 url:[[:space:]]*//')"
project_number="$(echo "$project_url" | grep -oE '/projects/[0-9]+' | cut -d/ -f3 || true)"
if [ -n "$project_number" ]; then
  gh project item-add "$project_number" --owner AGMO-Inc --url "$issue_url"
fi
```

## 6. TODO-Issue.md 갱신

이슈 생성 후 `TODO-Issue.md`를 해당 이슈 기준으로 갱신한다.
`git-issue-start` 스킬의 TODO-Issue.md 템플릿을 따른다.

```markdown
# TODO-Issue

- 레포: <owner>/<repo>
- 이슈: #<생성된 이슈번호>
- 제목: <이슈 제목>
- 링크: <이슈 URL>

## 이슈 요약

(생성한 이슈의 본문 요약)

## 실행 과제

- [ ] (이슈의 작업 항목에서 파생)
```

## 7. 결과 보고

1. 생성된 이슈 URL과 번호를 공유한다.
2. 프로젝트 추가 여부를 안내한다.
3. `TODO-Issue.md` 갱신 완료를 안내한다.
4. 다음 단계(`git-issue-start`로 브랜치 생성 또는 바로 구현 시작)를 제안한다.

## 8. 코멘트 작성 규칙

이슈 코멘트/PR 코멘트 작성 시 첫 줄에 아래를 반드시 포함한다.
```text
> 🤖 **AI created**
```

## 9. 안전 규칙

1. 이슈 유형이 명시되지 않으면 반드시 사용자에게 확인한다 (Feature/Task/Bug 중 선택).
2. AI가 작성한 모든 텍스트에 `AI created` 표시를 포함한다.
3. 프로젝트 연결 실패 시 오류를 보고하고 이슈 생성은 유지한다.
4. 템플릿 파일명/필드명이 바뀔 수 있으므로 생성 전 `AGMO-Inc/.github/.github/ISSUE_TEMPLATE`를 반드시 확인한다. 접근 불가 시 오류를 보고하고 이슈 생성을 중단한다.
