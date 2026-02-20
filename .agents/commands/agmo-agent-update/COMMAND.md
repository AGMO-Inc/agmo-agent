---
name: agmo-agent-update
description: 레포의 `.agents/skills/`와 `.agents/commands/`를 AGMO-Inc/agmo-agent의 최신 내용과 비교해 차이점을 표로 보고하고, 사용자가 선택한 범위만 안전하게 업데이트하는 커맨드다. `/agmo-agent-update [common|backend|frontend|custom|item-name]` 형태를 지원하며, 업데이트 적용 전 반드시 사용자 선택(전부/없음/부분)을 강제한다.
---

# AGMO Agent Update Command

이 커맨드는 "현재 레포"의 `.agents/`(skills + commands)를 기준으로, 원본 레포 `AGMO-Inc/agmo-agent`와의 차이점을 비교/정리하고 선택된 항목만 업데이트한다.

## Command Forms

- `/agmo-agent-update`
  - `AGENTS.md` frontmatter의 `type:`을 읽어 기본 타입을 결정한 뒤, `common + type`을 함께 비교한다.
- `/agmo-agent-update common`
  - `common/.agents/(skills|commands)`만 비교/업데이트 준비한다.
- `/agmo-agent-update backend|frontend|custom`
  - 해당 타입의 `{type}/.agents/(skills|commands)`만 비교/업데이트 준비한다.
- `/agmo-agent-update item-name`
  - 이름이 `item-name`인 skill/command만 비교/업데이트 준비한다.
  - 기본 타입이 있으면 `{type}`와 `common` 둘 다에서 해당 이름을 찾아 비교한다.

## Inputs

- Optional argument: `common`, `backend`, `frontend`, `custom`, or `item-name`
- Repo type: `AGENTS.md` YAML frontmatter의 `type: backend|frontend|custom`

## Workflow (MUST FOLLOW)

### 1) Determine scope

1. 사용자 입력에서 argument를 파싱한다.
2. argument가 없으면 `AGENTS.md`의 frontmatter에서 `type:`을 읽는다.
   - 없으면 사용자에게 type을 묻고(backend/frontend/custom), 그 답으로 진행한다.

### 2) Fetch canonical `.agents` from AGMO-Inc/agmo-agent

아래 방식 중 하나로 canonical repo를 임시 디렉토리에 받는다(둘 다 가능).

- Option A (curl zip):

```bash
tmp="$(mktemp -d)" \
&& curl -L -o "$tmp/repo.zip" "https://github.com/AGMO-Inc/agmo-agent/archive/refs/heads/main.zip" \
&& unzip -q "$tmp/repo.zip" -d "$tmp" \
&& root="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
```

- Option B (git clone):

```bash
tmp="$(mktemp -d)" \
&& git clone --depth 1 https://github.com/AGMO-Inc/agmo-agent.git "$tmp/agmo-agent" \
&& root="$tmp/agmo-agent"
```

Canonical paths:

- `common skills`: `$root/common/.agents/skills/`
- `common commands`: `$root/common/.agents/commands/`
- `type skills`: `$root/<type>/.agents/skills/`
- `type commands`: `$root/<type>/.agents/commands/`

Local paths:

- `./.agents/skills/`
- `./.agents/commands/`

### 3) Build comparison sets

scope에 따라 canonical source set을 만든다:

- scope=`common`: common only
- scope=`backend|frontend|custom`: type only
- scope=`default` (no arg): common + type
- scope=`item-name`: common + type에서 해당 이름만

중요:

- 동일 이름이 `common`과 `type`에 동시에 있으면, 표에서 source를 분리해 보여주고(2행), 업데이트 적용 시에도 사용자가 source를 선택할 수 있어야 한다.
- 동일 이름이 `skills`와 `commands`에 동시에 있을 수 있다. 이 경우에도 표에서 kind를 분리해 보여준다(2행).

### 4) Compute diffs

각 item(스킬/커맨드) 디렉토리 단위로 상태를 계산한다.

- `ADD`: canonical에만 있고 local에 없음
- `MODIFY`: 둘 다 있으나 내용이 다름
- `SAME`: 둘 다 있고 내용이 동일
- `LOCAL_ONLY`: local에만 있고 canonical에 없음

비교는 다음 중 하나를 사용한다:

- 빠른 비교: `diff -qr <canonical-dir> <local-dir>`
- 사람이 읽기 좋은 diff: `git diff --no-index -- <canonical-dir> <local-dir>`

### 5) Present results (MUST use table)

반드시 아래 출력 템플릿을 그대로 사용한다.

```text
## Diff Summary

| # | Kind | Name | Source | Status | Local Path | Canonical Path | Notes |
|---|------|------|--------|--------|------------|----------------|-------|
| 1 | skill | swagger | type=backend | MODIFY | .agents/skills/swagger | <tmp>/backend/.agents/skills/swagger | 3 files changed |
| 2 | command | agmo-agent-update | common | ADD | .agents/commands/agmo-agent-update | <tmp>/common/.agents/commands/agmo-agent-update | new |

## Per-Item Notes (optional)
- [1] skill swagger: show 5-15 lines of the most important diff or file list

## Choose Update Action (REQUIRED)
Pick exactly one:
1) Update ALL rows with status ADD or MODIFY
2) Update NONE (stop)
3) Select specific rows to update (reply with row numbers, comma-separated)

Reply with: 1 / 2 / 3
If 3, also reply with row numbers: e.g. 3: 1,4,7
```

규칙:

- 표에는 scope에 포함된 canonical item과 local-only item을 모두 포함한다.
- `SAME`은 rows가 너무 많으면 생략하고 count만 별도로 표기해도 된다.
- 어떤 경우에도 업데이트를 바로 적용하지 않는다. 반드시 사용자 선택을 먼저 받는다.

### 6) Force user choice

사용자가 1/2/3 중 하나를 명확히 선택할 때까지 다음 단계를 진행하지 않는다.

### 7) Apply updates (only after user selection)

선택된 rows에 대해서만 업데이트한다.

안전 절차:

1. 백업 생성(선택된 item별로 디렉토리 단위 백업):
   - `.agents/.backup/agmo-agent-update/<timestamp>/<kind>/<name>/`
   - 여기서 `kind`는 `skills` 또는 `commands` 디렉토리를 의미한다.
2. 업데이트 적용:
   - `ADD`:
     - kind=skill -> canonical dir을 local `.agents/skills/<name>`로 복사
     - kind=command -> canonical dir을 local `.agents/commands/<name>`로 복사
   - `MODIFY`:
     - 기존 local dir을 백업 후, canonical dir로 덮어쓰기
3. 삭제 정책:
   - `LOCAL_ONLY`는 기본값으로 삭제하지 않는다.
   - 삭제는 별도 명시 옵션으로만 수행하며, 삭제 리스트를 먼저 보여주고 사용자 확인을 추가로 받는다.
4. 적용 후 재검증:
   - 선택된 item에 대해 다시 diff를 실행해서 `SAME`이 되었는지 확인한다.

### 8) Report result

- 적용한 item 목록
- 백업 경로
- 재검증 결과(모두 SAME인지)

## Type Detection

`AGENTS.md` 앞부분 YAML frontmatter에서 `type:`을 읽는다.

예:

```yaml
---
type: backend
---
```

fallback:

- frontmatter가 없거나 `type:`이 없으면 사용자에게 type을 물어본다.

## Safety Rules

- 사용자 선택 없이 `.agents/(skills|commands)/`를 변경하지 않는다.
- 삭제는 기본 금지(추가 확인 필수).
- `.env`, credentials, secret류 파일을 복사/덮어쓰지 않는다(해당 파일이 감지되면 표에서 경고하고 업데이트 제외).
- 커밋/푸시는 사용자가 명시적으로 요청할 때만 한다.
