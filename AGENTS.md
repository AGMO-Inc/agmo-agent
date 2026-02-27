# AGENTS.md

Working agreement for humans, CI, bots, and agentic coding tools in this repository.

This repo is an internal, shared "agent kit" for AGMO: templates (AGENTS.md) + reusable skills under `.cluade/`.
It is NOT an application repo, so most commands here validate tooling/templates rather than build a product.

## Repo Map

- `backend/AGENTS.md`: AGENTS template for Kotlin/Spring backend repos (example: sdm-backend).
- `backend/.cluade/`: backend-specific skills (ex: Swagger).
- `common/.cluade/`: shared skills used across repos (issue start, git commit, PR, skill-creator, etc).
- `docs/guide/`: installer/how-to docs for setting up AGENTS + `.cluade/` in another repo.
- `.opencode/`: local OpenCode runtime files (ignored; do not commit).

## Build / Lint / Test Commands

### This Repository (templates + skills)

There is no single "build" for this repo.

- Python sanity check (byte-compile scripts):
  - `python3 -m compileall common/.cluade/skills/skill-creator/scripts`

- Validate ONE skill folder (fast correctness check; closest equivalent to "run single test"):
  - `python3 common/.cluade/skills/skill-creator/scripts/quick_validate.py <path/to/skill-dir>`
  - Example:
    - `python3 common/.cluade/skills/skill-creator/scripts/quick_validate.py common/.cluade/skills/git-commit`
  - Note: requires PyYAML (`import yaml`).

- Package ONE skill folder into a `.skill` zip:
  - `python3 common/.cluade/skills/skill-creator/scripts/package_skill.py <path/to/skill-dir> [output-dir]`
  - Packaging runs validation first.

- Create a new skill skeleton:
  - `python3 common/.cluade/skills/skill-creator/scripts/init_skill.py <skill-name> --path <skills-root>`

### Quick Checks (common workflows)

- Validate the Swagger skill template:
  - `python3 common/.cluade/skills/skill-creator/scripts/quick_validate.py backend/.cluade/skills/swagger`
- Validate the skill-creator skill itself:
  - `python3 common/.cluade/skills/skill-creator/scripts/quick_validate.py common/.cluade/skills/skill-creator`
- Validate all common skills (repeat per directory):
  - `ls common/.cluade/skills`
  - Run `quick_validate.py` on each folder under `common/.cluade/skills/`.

### Template: Kotlin/Spring Backend Repos (via `backend/AGENTS.md`)

For downstream backend repos that include Gradle wrapper and sources:

- Build: `./gradlew clean build`
- Test (all): `./gradlew test`
- Test (single): `./gradlew test --tests "com.example.FooTest"`
- Run: `./gradlew bootRun`

## Agent Rules (Repo-Specific)

- Do not commit personal agent runtime directories: `.opencode/`, `.claude/`, etc.
- Treat `docs/guide/installation.md` as the setup SSOT for installing this kit into another repo.
- Prefer small, reviewable diffs. This repo is copied/consumed by other repos.

## Local Environment

- Python: 3.11+ (this repo is tested with Python 3.12).
- Python deps: PyYAML is required for skill validation (`import yaml`).
- Node tooling: `.opencode/` contains local OpenCode runtime artifacts; do not depend on it for repo correctness.

## Code Style Guidelines

This repo is mostly Markdown + small Python utilities.

General:

- Keep diffs minimal; avoid drive-by refactors in templates.
- Preserve existing language per file (many templates/docs are Korean).
- Prefer ASCII unless the file is explicitly Korean-facing.

### Markdown

- Keep Markdown ASCII-first; avoid non-ASCII unless the doc is explicitly Korean-facing (many templates are).
- Use short headings, tight lists, and runnable code blocks.
- Avoid duplicating long procedures across multiple docs; link to the SSOT instead.

Formatting:

- Wrap CLI commands in fenced code blocks with `bash`.
- Use backticks for file paths and literal tokens (ex: `.cluade`).
- Keep lines reasonably short in lists; prefer one idea per bullet.

### Skill Authoring (`**/.cluade/skills/<skill-name>/SKILL.md`)

Follow the validator constraints in `common/.cluade/skills/skill-creator/scripts/quick_validate.py`:

- Frontmatter:
  - Must start with `---` YAML frontmatter.
  - Required keys: `name`, `description`.
  - Allowed keys: `name`, `description`, `license`, `allowed-tools`, `metadata`, `compatibility`.
- `name`:
  - kebab-case (`^[a-z0-9-]+$`), max 64 chars; no leading/trailing `-`, no `--`.
- `description`:
  - string, max 1024 chars; must not contain `<` or `>`.

Conventions:

- Keep SKILL.md concise; put large reference material under `references/`.
- Prefer imperative headings and checklists that are easy for agents to execute.
- When referencing the agent directory root in docs/templates, use `.cluade` (fixed location).

Bundled resources:

- `scripts/`: executable utilities; include a shebang when appropriate and keep CLI UX predictable.
- `references/`: long-form docs meant to be selectively loaded.
- `assets/`: binary/templates used in outputs; avoid loading into context.

### Python (skill-creator scripts)

- Use Python 3.11+ features freely (repo is currently used with Python 3.12).
- Style:
  - 4-space indents; f-strings; type hints only where they add clarity.
- Imports:
  - stdlib first, then third-party (`yaml`), then local.
- Error handling:
  - Prefer explicit, user-actionable error messages and non-zero exit codes.
  - Do not swallow exceptions; surface the root error.

CLI conventions:

- Print human-readable errors to stderr when failing.
- Exit codes: `0` on success, non-zero on failure.
- Avoid interactive prompts in scripts (they are often run by automation).

## Naming Conventions

- Skill directories and `name:` fields are kebab-case and must match exactly.
- Use descriptive, stable file names under `references/` (ex: `workflows.md`, `output-patterns.md`).
- Prefer explicit script names over generic ones (ex: `quick_validate.py`, `package_skill.py`).

## Git / Change Hygiene

- Never rewrite history on shared branches.
- Do not add secrets or tokens to this repo (PATs, keys, credentials).
- When updating templates, also update the corresponding docs that instruct usage (or link to them).
- Do not commit caches or local runtime dirs (ex: `.ruff_cache/`, `.opencode/`).
- 모든 Git 작업(브랜치 생성/커밋/푸시/PR/리베이스)은 기본적으로 `develop` 또는 `develop` 하위 브랜치에서 수행한다.
- `main`/`master`에서 Git 작업이 필요할 경우에는 사용자에게 명시적으로 허락을 받은 뒤에만 수행한다.
- AI가 작성한 이슈/코멘트/PR/커밋 메시지에는 `AI created` 식별 표기를 반드시 포함한다.

## Cursor / Copilot Rules

- No `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` found in this repo at the time of writing.
  - If added later, mirror the key constraints here so non-Cursor agents also follow them.
