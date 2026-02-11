# Installation

If you're an LLM Agent helping set up project agent, Welcome! You'll now help your user to set up .agent files.

follow these steps:

## Step 0: Ask user about project information

First of All, Ask the user these questions in korean to determine AGENTS.md options one after another.
never move on next step before getting the answer:

1. **현재 레파지토리는 어느 깃허브 프로젝트와 관련되어 있나요? (관련없음 또는 프로젝트명을 정확히 넣어주세요)**
- 보기는 '관련 없음' 1개의 옵션만 제시한다.
- answer -> $PROJECT_NAME
- $PROJECT_NAME 이 `관련없음`이면 1-1은 생략한다.

1-1. **(프로젝트명이 있는 경우) 해당 프로젝트 링크(URL)는 무엇인가요? (ex. https://github.com/orgs/AGMO-Inc/projects/7)**
- 보기는 제시하지 않고 타이핑만 받는다.
- answer -> $PROJECT_URL

2. **현재 레파지토리는 어떤 성격의 프로젝트인가요? (backend / frontend / custom)**
- answer -> $TYPE

## Step 1: Download AGENTS.md file

Based on $TYPE, run the CLI installer with appropriate flags:

```bash
curl -s https://raw.githubusercontent.com/hobeen-kim/agent/refs/heads/main/<backend|frontend|custom>/AGENTS.md
```

**Examples:**
- User's repository type is backend: `curl -s https://raw.githubusercontent.com/hobeen-kim/agent/refs/heads/main/backend/AGENTS.md`
- User's repository type is frontend: `curl -s https://raw.githubusercontent.com/hobeen-kim/agent/refs/heads/main/frontend/AGENTS.md`
- User's repository type is custom: `curl -s https://raw.githubusercontent.com/hobeen-kim/agent/refs/heads/main/custom/AGENTS.md`

## Step 2: Edit AGENTS.md file

### Step 2-1: project info
Read the project and update only the following sections in AGENTS.md (leave everything else unchanged):

`## Project Overview and Description`

`## Tools, Technologies, and Frameworks Used`

`## How to Build and Run Tests`

### Step 2-2: repository, project info

setting 레포 in `## 레포/프로젝트 정보` by next bash command:
```bash
git remote get-url origin
```
if git remote doesn't exist, set 레포 to NOT_CONNECTED

setting 프로젝트명 in `## 레포/프로젝트 정보` by $PROJECT_NAME from user's answer

setting 프로젝트 url in `## 레포/프로젝트 정보` by $PROJECT_URL from user's answer
- If $PROJECT_NAME is `관련없음`, set the project url to `N/A`.

### Step 2-3: agent directory info

Run the following command to update AGENTS.md so it references the AGENT_ROOT environment variable (instead of the literal text AGENT_ROOT).

```bash
export AGENT_ROOT=".opencode"
```

**Examples:**
- current ai agent is opencode: `export AGENT_ROOT=".opencode"`
- current ai agent is claudecode: `export AGENT_ROOT=".claude"`
- current ai agent is codex (openai): `export AGENT_ROOT=".codex"`


edit AGENT_ROOT by sed one-liner (macOS/Linux)

```bash
sed -i 's/AGENT_ROOT/\$AGENT_ROOT/g' ./AGENTS.md
```

## Step 3: Edit .gitignore file

Add `.gitignore` if not exists by running the following Bash command:

```bash
cat <<'EOF' >> .gitignore

## personal AI Agents
TODO-Issue.md
**/handoff.md
EOF
```

## Step 4: Download AGENT_ROOT files

First, set `TYPE` as an environment variable using the value you answered in Step 0 (`backend`, `frontend`, or `custom`).

```bash
export TYPE="backend"  # or: frontend / custom
export AGENT_ROOT=".agents"  # e.g. .agents / .opencode / .claude
```

Then run the script below to download the `.agents/` files.

```bash
curl -L -o repo.zip "https://github.com/AGMO-Inc/agmo-agent/archive/refs/heads/main.zip" \
&& tmp="$(mktemp -d)" \
&& unzip -q repo.zip -d "$tmp" \
&& root="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n 1)" \
&& if [ -z "${AGENT_ROOT:-}" ]; then echo "AGENT_ROOT is empty. do confirm AGENT_ROOT (e.g. .agents/.opencode/.claude)" >&2; exit 1; fi \
&& rm -rf "./${AGENT_ROOT}" \
&& mkdir -p "./${AGENT_ROOT}" \
&& cp -R "$root/$TYPE/.agents/." "./${AGENT_ROOT}/" \
&& rm -rf "$tmp" repo.zip
```

## Step 5: Replace `AGENT_ROOT` references under `$AGENT_ROOT/`

Run the following command to iterate over **all files** under `$AGENT_ROOT/` and replace every occurrence of `AGENT_ROOT` with `$AGENT_ROOT` in-place.

> ⚠️ This edits files in-place. It will skip `.git/`, `node_modules/`, and common binary files.

```bash
# Ensure AGENT_ROOT is set (example)
# export AGENT_ROOT=".opencode"

find "$AGENT_ROOT" \
  -type d \( -name .git -o -name node_modules -o -name dist -o -name build \) -prune -false \
  -o -type f \
  -print0 \
| while IFS= read -r -d '' f; do
    # skip likely-binary files
    if file -b --mime "$f" | grep -q 'charset=binary'; then
      continue
    fi

    # macOS vs Linux sed compatibility
    if sed --version >/dev/null 2>&1; then
      # GNU sed (Linux)
      sed -i 's/AGENT_ROOT/\$AGENT_ROOT/g' "$f"
    else
      # BSD sed (macOS)
      sed -i '' 's/AGENT_ROOT/\$AGENT_ROOT/g' "$f"
    fi
  done
```

### Verify (optional)

```bash
grep -R --line-number 'AGENT_ROOT' "$AGENT_ROOT" || echo "✅ No remaining 'AGENT_ROOT' literals under $AGENT_ROOT"
```