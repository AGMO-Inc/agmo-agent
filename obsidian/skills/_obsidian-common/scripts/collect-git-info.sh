#!/bin/bash
# 구현 정보 수집. JSON 출력.
BASE=$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD origin/develop 2>/dev/null || echo "")
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
ISSUE_NUM=$(grep -oE '#[0-9]+' TODO-Issue.md 2>/dev/null | head -1 || echo "")
ISSUE_TITLE=$(grep -E '^- 제목:' TODO-Issue.md 2>/dev/null | sed 's/^- 제목:[[:space:]]*//' || echo "")
PR_URL=$(gh pr view "$BRANCH" --json url -q .url 2>/dev/null || echo "")
CHANGED_FILES=$(git diff --name-only "$BASE"..HEAD 2>/dev/null | head -30 || echo "")

cat << EOF
{
  "base": "$BASE",
  "branch": "$BRANCH",
  "issue_num": "$ISSUE_NUM",
  "issue_title": "$ISSUE_TITLE",
  "pr_url": "$PR_URL",
  "changed_files": "$(echo "$CHANGED_FILES" | tr '\n' '|')"
}
EOF
