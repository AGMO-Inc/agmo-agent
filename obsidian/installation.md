# Obsidian Skills 설치 가이드

> **대상:** Claude Code 에이전트가 이 문서를 읽고 사용자의 프로젝트에 Obsidian 스킬을 설치한다.

## 전제 조건 확인

설치 전 아래 항목을 확인한다. 누락된 항목이 있으면 사용자에게 안내한다.

| 항목 | 확인 방법 | 필수 여부 |
|------|-----------|-----------|
| Obsidian 1.12+ | `obsidian --version` | 필수 |
| Obsidian CLI 활성화 | Obsidian 앱 → 설정 → 일반 → 명령줄 인터페이스 활성화 | 필수 |
| gh CLI 인증 | `gh auth status` | `obsidian-to-issue` 사용 시 필수 |
| Claude Code 설치 | `.claude/` 디렉토리 존재 | 필수 |

---

## 1단계: 사용자 개인화 정보 수집

설치 에이전트는 아래 정보를 사용자에게 질문하여 수집한다.

### 필수 정보

| 항목 | 질문 예시 | 기본값 |
|------|-----------|--------|
| **Obsidian vault 경로** | "Obsidian vault 폴더의 절대 경로를 알려주세요." | 없음 (반드시 수집) |

### 선택 정보

| 항목 | 질문 예시 | 기본값 |
|------|-----------|--------|
| **사용할 스킬 범위** | "전체 5개 스킬을 설치할까요, 일부만 선택할까요?" | 전체 설치 |
| **GitHub 프로젝트 보드 URL** | "GitHub Projects 보드 URL이 있으면 알려주세요." | 빈 값 |
| **노트 언어** | "노트 템플릿을 한국어/영어 중 어느 것으로 쓸까요?" | 한국어 |

### vault 경로 확인 방법

사용자가 vault 경로를 모를 경우 아래 명령으로 탐색한다:

```bash
# macOS
find ~/Library/Mobile\ Documents -name ".obsidian" -type d 2>/dev/null | head -5
find ~ -maxdepth 4 -name ".obsidian" -type d 2>/dev/null | head -5

# Linux
find ~ -maxdepth 4 -name ".obsidian" -type d 2>/dev/null | head -5
```

`.obsidian` 폴더의 **부모 디렉토리**가 vault 경로다.

---

## 2단계: 환경 변수 설정

수집한 vault 경로를 환경 변수로 등록한다.

### 방법 A: 쉘 프로파일에 추가 (추천)

사용자의 쉘 프로파일(`~/.zshrc` 또는 `~/.bashrc`)에 아래를 추가한다:

```bash
export OBSIDIAN_VAULT_ROOT="{수집한 vault 경로}"
```

**주의:** 경로에 공백이 포함된 경우 반드시 따옴표로 감싼다.

### 방법 B: 프로젝트 로컬 .env 파일

프로젝트 루트에 `.env.local` 파일을 생성한다 (`.gitignore`에 포함 확인):

```bash
OBSIDIAN_VAULT_ROOT={수집한 vault 경로}
```

### 환경 변수 검증

설정 후 반드시 확인한다:

```bash
echo "$OBSIDIAN_VAULT_ROOT"
ls "$OBSIDIAN_VAULT_ROOT/.obsidian"  # .obsidian 폴더가 보여야 정상
```

---

## 3단계: 스킬 파일 복사

소스 레포의 `obsidian/skills/` 내용을 대상 프로젝트의 `.claude/skills/`로 복사한다.

### 복사 대상

```bash
# 변수 설정
SOURCE="obsidian/skills"       # agmo-agent 레포 내 경로
TARGET=".claude/skills"        # 대상 프로젝트의 스킬 디렉토리
```

### 전체 설치 (5개 스킬 + 공통 리소스)

```bash
# 1) 공통 리소스 (모든 스킬이 참조)
mkdir -p ${TARGET}/_obsidian-common/ref
mkdir -p ${TARGET}/_obsidian-common/scripts

cp ${SOURCE}/_obsidian-common/ref/frontmatter-schema.md  ${TARGET}/_obsidian-common/ref/
cp ${SOURCE}/_obsidian-common/ref/link-strategy.md       ${TARGET}/_obsidian-common/ref/
cp ${SOURCE}/_obsidian-common/ref/cli-reference.md       ${TARGET}/_obsidian-common/ref/
cp ${SOURCE}/_obsidian-common/scripts/identify-project.sh     ${TARGET}/_obsidian-common/scripts/
cp ${SOURCE}/_obsidian-common/scripts/ensure-project-index.sh ${TARGET}/_obsidian-common/scripts/
cp ${SOURCE}/_obsidian-common/scripts/collect-git-info.sh     ${TARGET}/_obsidian-common/scripts/
chmod +x ${TARGET}/_obsidian-common/scripts/*.sh

# 2) 개별 스킬
cp -r ${SOURCE}/save-plan          ${TARGET}/
cp -r ${SOURCE}/save-impl          ${TARGET}/
cp -r ${SOURCE}/save-note          ${TARGET}/
cp -r ${SOURCE}/obsidian-to-issue  ${TARGET}/
cp -r ${SOURCE}/obsidian-search    ${TARGET}/
```

### 부분 설치 (사용자가 선택한 스킬만)

공통 리소스는 항상 필수다. 개별 스킬만 선택적으로 복사한다:

| 스킬 | 의존하는 공통 스크립트 |
|------|------------------------|
| `save-plan` | `identify-project.sh`, `ensure-project-index.sh` |
| `save-impl` | `identify-project.sh`, `ensure-project-index.sh`, `collect-git-info.sh` |
| `save-note` | `identify-project.sh`, `ensure-project-index.sh` |
| `obsidian-to-issue` | `identify-project.sh`, `ensure-project-index.sh` |
| `obsidian-search` | 없음 (CLI만 사용) |

---

## 4단계: setup.md 생성 (개인화)

대상 프로젝트의 `.claude/skills/_obsidian-common/ref/setup.md`를 생성한다. 이 파일은 **사용자별 개인화 정보**를 담는다.

```markdown
# Obsidian 스킬 설정 가이드

## 전제 조건

- Obsidian 1.12+ 설치
- Obsidian 앱 설정 → 일반 → **명령줄 인터페이스 활성화** → 등록
- `gh` CLI 인증 완료

## 환경 변수 설정

각 사용자는 자신의 Obsidian vault 경로를 환경 변수로 설정해야 한다.

### 방법 1: 쉘 프로파일에 추가 (추천)

`~/.zshrc` 또는 `~/.bashrc`에 추가:

```bash
export OBSIDIAN_VAULT_ROOT="{사용자가 알려준 vault 경로}"
```

### 방법 2: 프로젝트 .env 파일

프로젝트 루트에 `.env.local` 파일 생성 (gitignore 대상):

```bash
OBSIDIAN_VAULT_ROOT={사용자가 알려준 vault 경로}
```

## Vault 디렉토리 구조

스킬이 자동 생성하는 구조:

```
${OBSIDIAN_VAULT_ROOT}/
├── {프로젝트명}/
│   ├── plans/
│   │   └── [Plan] 제목.md
│   ├── implementations/
│   │   └── [Impl] 제목.md
│   ├── designs/
│   │   └── [Design] 제목.md
│   ├── research/
│   │   └── [Research] 제목.md
│   ├── meetings/
│   │   └── [Meeting] 제목.md
│   ├── memos/
│   │   └── [Memo] 제목.md
│   └── {프로젝트명}.md          ← 프로젝트 인덱스 (허브)
```
```

위 템플릿에서 `{사용자가 알려준 vault 경로}` 부분을 **2단계에서 수집한 실제 경로**로 치환한다.

---

## 5단계: SKILL.md 경로 패치

`obsidian/skills/`의 SKILL.md는 상대 경로 참조를 사용한다. `.claude/skills/`에 복사한 후 참조 경로가 올바른지 확인한다.

### 확인 항목

각 SKILL.md의 `**참조:**` 섹션이 아래 패턴인지 확인:

```markdown
**참조:** `.claude/skills/_obsidian-common/ref/` 하위 파일 참조.
```

소스 원본이 아래처럼 되어 있으면:

```markdown
**참조:** `_obsidian-common/ref/` 하위 파일
```

`.claude/skills/` 기준 경로로 패치한다:

```markdown
**참조:** `.claude/skills/_obsidian-common/ref/` 하위 파일 참조.
```

마찬가지로 `**스크립트:**` 섹션도 패치:

```markdown
**스크립트:** `.claude/skills/_obsidian-common/scripts/`
```

---

## 6단계: CLAUDE.md에 Obsidian 연동 규칙 추가

대상 프로젝트의 `CLAUDE.md` (또는 사용자의 `~/.claude/CLAUDE.md`)에 아래 규칙을 추가한다. 이 규칙이 있어야 에이전트가 자동으로 스킬을 트리거한다.

### 추가할 내용

```markdown
### Obsidian 연동 자동 규칙

**플랜 완료 후 Obsidian 자동 저장:**
- OMC `plan`, `ralplan`, `autopilot` 스킬이 `.omc/plans/`에 플랜을 기록하면, 반드시 `save-plan` 스킬을 자동 실행하여 Obsidian vault에도 동기화한다.
- 사용자가 명시적으로 "옵시디언 저장 안해도 돼" 또는 "skip obsidian"이라고 하지 않는 한 항상 실행한다.
- Obsidian 앱이 꺼져 있으면 vault 경로에 직접 파일을 쓰는 fallback을 사용한다.

**구현 완료 후 Obsidian 저장 제안:**
- 구현 작업이 완료되고 커밋/PR이 생성된 후, `save-impl` 스킬 실행을 사용자에게 제안한다.
- 사용자가 "작업 정리해줘", "구현 내용 저장" 등을 말하면 즉시 실행한다.

**Obsidian 키워드 → 스킬 매핑:**

| 패턴 | 스킬 |
|------|------|
| "노트로 이슈 만들어", "옵시디언 이슈", "이슈로 변환" | `obsidian-to-issue` |
| "플랜 저장", "옵시디언에 플랜", "플랜 기록" | `save-plan` |
| "구현 내용 저장", "작업 정리", "옵시디언에 구현 기록" | `save-impl` |
| "옵시디언에 저장", "노트 저장", "기록해줘", "정리해줘" | `save-note` |
| "옵시디언에서 찾아", "관련 노트", "vault 검색" | `obsidian-search` |

**Obsidian vault 경로:** `{사용자가 알려준 vault 경로}`
```

`{사용자가 알려준 vault 경로}` 부분을 **2단계에서 수집한 실제 경로**로 치환한다.

---

## 7단계: issue-template-mapping.md 생성 (선택)

`obsidian-to-issue` 스킬을 설치하는 경우, GitHub Issue 템플릿 매핑 파일을 생성한다.

### 사용자에게 질문

- "GitHub Issue 템플릿을 사용하시나요? (AGMO-Inc/.github 기본 템플릿 / 커스텀 / 미사용)"
- 커스텀인 경우: "레포의 `.github/ISSUE_TEMPLATE/` 경로에 어떤 템플릿 파일이 있나요?"

### 기본 매핑 (AGMO-Inc 표준)

`.claude/skills/_obsidian-common/ref/issue-template-mapping.md`를 생성한다:

```markdown
# Issue Template Mapping (SSOT)

노트의 `issue-type` → GitHub Issue 템플릿 매핑.

| issue-type | 제목 접두사 | 템플릿 파일 |
|------------|-------------|-------------|
| feature | `[Feature]` | `01-기능-개발.yml` |
| task | `[Task]` | `02-기능-개발---하위-태스크.yml` |
| bug | `[Bug]` | `03-버그-리포트.yml` |

템플릿 소스: `AGMO-Inc/.github/.github/ISSUE_TEMPLATE`
```

사용자의 조직/레포에 맞게 템플릿 파일명을 수정한다.

---

## 8단계: 스크립트 실행 권한 확인

```bash
chmod +x .claude/skills/_obsidian-common/scripts/*.sh
```

---

## 9단계: 설치 검증

### 자동 검증 체크리스트

에이전트는 아래 항목을 순서대로 확인한다:

```bash
# 1. 환경 변수 확인
echo "$OBSIDIAN_VAULT_ROOT"
# → 경로가 출력되어야 함

# 2. vault 접근 확인
ls "$OBSIDIAN_VAULT_ROOT/.obsidian"
# → 파일 목록이 보여야 함

# 3. 스킬 파일 존재 확인
ls .claude/skills/_obsidian-common/ref/
ls .claude/skills/_obsidian-common/scripts/
# → 각 ref 3개, scripts 3개 파일

# 4. 스크립트 실행 권한 확인
test -x .claude/skills/_obsidian-common/scripts/identify-project.sh && echo "OK"

# 5. 프로젝트 식별 테스트
bash .claude/skills/_obsidian-common/scripts/identify-project.sh
# → "OWNER/PROJECT OWNER PROJECT" 형태 출력

# 6. Obsidian CLI 확인 (앱 실행 중일 때)
obsidian --version 2>/dev/null && echo "CLI OK" || echo "CLI unavailable (fallback mode)"

# 7. gh CLI 확인 (obsidian-to-issue 설치 시)
gh auth status 2>/dev/null && echo "gh OK" || echo "gh not authenticated"
```

### 결과 보고

검증 완료 후 사용자에게 아래 형식으로 보고한다:

```
## Obsidian 스킬 설치 완료

- Vault 경로: {경로}
- 설치된 스킬: save-plan, save-impl, save-note, obsidian-to-issue, obsidian-search
- Obsidian CLI: 사용 가능 / fallback 모드
- gh CLI: 인증됨 / 미인증
- 프로젝트 식별: {OWNER}/{PROJECT}

### 사용 방법
- 플랜 저장: OMC plan/ralplan 완료 시 자동 실행
- 구현 저장: "작업 정리해줘" 또는 "구현 내용 저장"
- 노트 저장: "옵시디언에 저장" 또는 "기록해줘"
- 이슈 변환: "노트로 이슈 만들어"
- Vault 검색: "옵시디언에서 찾아줘"
```

---

## 트러블슈팅

### "OBSIDIAN_VAULT 환경변수를 설정하세요" 오류

`ensure-project-index.sh`는 `OBSIDIAN_VAULT` 변수를 참조한다. `OBSIDIAN_VAULT_ROOT`와 `OBSIDIAN_VAULT` 둘 다 설정하거나, 스크립트를 패치한다:

```bash
# ~/.zshrc에 둘 다 추가
export OBSIDIAN_VAULT_ROOT="/path/to/vault"
export OBSIDIAN_VAULT="$OBSIDIAN_VAULT_ROOT"
```

### Obsidian CLI가 동작하지 않을 때

1. Obsidian 앱이 실행 중인지 확인
2. 설정 → 일반 → 명령줄 인터페이스가 활성화되어 있는지 확인
3. CLI fallback 모드: vault 경로에 직접 파일을 쓴다 (모든 스킬이 지원)

### 프로젝트 인덱스가 생성되지 않을 때

```bash
# 수동 생성
bash .claude/skills/_obsidian-common/scripts/ensure-project-index.sh {PROJECT} {OWNER}
```

### GitHub Issue 생성 실패

```bash
# gh CLI 인증 확인
gh auth status

# 레포 접근 확인
gh repo view {OWNER}/{PROJECT}
```

---

## 업데이트

agmo-agent 레포의 `obsidian/skills/`가 업데이트되면, 변경된 파일만 다시 복사한다.

```bash
# 변경사항 확인 (agmo-agent 레포에서)
git log --oneline --name-only -- obsidian/skills/

# 변경된 파일만 복사
cp {변경된 파일} .claude/skills/{대응 경로}
```

또는 `agmo-agent-update` 스킬이 있는 프로젝트에서는:

```bash
/agmo-agent-update custom
```
