#!/bin/bash
# 프로젝트 인덱스 노트 확인/생성
# Usage: ensure-project-index.sh <PROJECT> <OWNER> [VAULT_ROOT]
PROJECT="$1"
OWNER="$2"
VAULT_ROOT="${3:-${OBSIDIAN_VAULT:?OBSIDIAN_VAULT 환경변수를 설정하세요}}"

# Obsidian CLI 시도
if obsidian read file="${PROJECT}" >/dev/null 2>&1; then
  echo "EXISTS"
  exit 0
fi

# fallback: 파일 직접 확인
INDEX_FILE="${VAULT_ROOT}/${PROJECT}/${PROJECT}.md"
if [ -f "$INDEX_FILE" ]; then
  echo "EXISTS"
  exit 0
fi

# 생성
mkdir -p "${VAULT_ROOT}/${PROJECT}/plans" "${VAULT_ROOT}/${PROJECT}/implementations"

obsidian create name="${PROJECT}" path="${PROJECT}/" content="---
type: project-index
project: ${PROJECT}
repo: ${OWNER}/${PROJECT}
project-url:
tags:
  - project
---

# ${PROJECT}

- repo: [${OWNER}/${PROJECT}](https://github.com/${OWNER}/${PROJECT})

## 최근 Plans
> Obsidian backlink 패널에서 자동 수집됨

## 최근 Implementations
> Obsidian backlink 패널에서 자동 수집됨" 2>/dev/null || {
  # Obsidian CLI 실패 시 직접 파일 생성
  cat > "$INDEX_FILE" << EOF
---
type: project-index
project: ${PROJECT}
repo: ${OWNER}/${PROJECT}
project-url:
tags:
  - project
---

# ${PROJECT}

- repo: [${OWNER}/${PROJECT}](https://github.com/${OWNER}/${PROJECT})

## 최근 Plans
> Obsidian backlink 패널에서 자동 수집됨

## 최근 Implementations
> Obsidian backlink 패널에서 자동 수집됨
EOF
}

echo "CREATED"
