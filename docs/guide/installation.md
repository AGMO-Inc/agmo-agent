# Installation

If you're an LLM Agent helping set up project agent, Welcome! You'll now help your user to set up .agent files.

follow these steps:

## Step 0: Ask user about project information

First of All, Ask the user these questions in korean to determine AGENTS.md options one after another.
never move on next step before getting the answer:

1. **현재 레파지토리는 어느 깃허브 프로젝트와 관련되어 있나요? (관련없음 또는 프로젝트명을 정확히 넣어주세요)**
- 보기는 '관련 없음'과 'Type your own answer' 만 제시한다.
- answer -> $PROJECT_NAME
- $PROJECT_NAME 이 `관련없음`이면 1-1은 생략한다.

1-1. **(프로젝트명이 있는 경우) 해당 프로젝트 링크(URL)는 무엇인가요? (ex. https://github.com/orgs/AGMO-Inc/projects/7)**
- 보기는 'Type your own answer' 만 제시한다.
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
- $PROJECT_NAME 이 `관련없음`이면 프로젝트 url 은 `N/A`로 넣는다.

### Step 3: Edit .gitignore file

Add `.gitignore` if not exists by running the following Bash command:

```bash
cat <<'EOF' >> .gitignore

## personal AI Agents
TODO-Issue.md
.agents/handoff/handoff.md
EOF
```
