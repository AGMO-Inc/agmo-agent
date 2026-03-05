#!/usr/bin/env bash
#
# clone-template.sh - AGMO Custom UI React 템플릿 클론
#
# 사용법:
#   ./clone-template.sh [target-directory]
#   인자 없으면 기본값: custom-ui-react-template
#
set -euo pipefail

REPO_URL="https://github.com/AGMO-Inc/custom-ui-react-template.git"
TARGET_DIR="${1:-custom-ui-react-template}"

# 디렉토리 존재 여부 확인
if [ -d "$TARGET_DIR" ]; then
    echo "이미 '$TARGET_DIR' 디렉토리가 존재합니다."
    echo "삭제 후 다시 시도하거나, 다른 경로를 지정해 주세요."
    exit 1
fi

# git clone 실행
git clone "$REPO_URL" "$TARGET_DIR"

echo ""
echo "Custom UI React 템플릿이 클론되었습니다."
echo ""
echo "  경로: $TARGET_DIR/"
echo "  GitHub: $REPO_URL"
echo ""
echo "시작하려면:"
echo "  cd $TARGET_DIR && npm install"
