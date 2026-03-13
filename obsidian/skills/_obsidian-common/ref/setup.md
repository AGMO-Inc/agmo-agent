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
export OBSIDIAN_VAULT_ROOT="$HOME/obsidian-vault"  # 자신의 vault 경로로 변경
```

### 방법 2: 프로젝트 .env 파일

프로젝트 루트에 `.env.local` 파일 생성 (gitignore 대상):

```bash
OBSIDIAN_VAULT_ROOT=/Users/myname/my-vault
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
│   └── {프로젝트명}.md          ← 프로젝트 인덱스 (허브)
```
