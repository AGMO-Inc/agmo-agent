#!/usr/bin/env bash
# Custom UI Build & Deploy Script
# Usage: deploy-ui.sh <ui-project-path> [project-root]
set -euo pipefail

UI_PATH="${1:-}"
PROJECT_ROOT="${2:-.}"

# Step 1: 인자 검증
if [ -z "$UI_PATH" ]; then
  cat <<'MSG'
UI 프로젝트 경로를 지정해 주세요.

사용법: /deploy-ui <ui-project-path>
예시:   /deploy-ui custom-ui-react-template
MSG
  exit 1
fi

# 상대 경로 → 프로젝트 루트 기준 해석
if [[ "$UI_PATH" != /* ]]; then
  UI_PATH="${PROJECT_ROOT}/${UI_PATH}"
fi

# Step 2: UI 프로젝트 경로 검증
[ ! -d "$UI_PATH" ] && echo "ERROR: 디렉토리 '${UI_PATH}'가 존재하지 않습니다." && exit 1
[ ! -f "$UI_PATH/package.json" ] && echo "ERROR: '${UI_PATH}/package.json'이 없습니다. npm 프로젝트가 아닙니다." && exit 1
echo "UI 프로젝트 확인: $UI_PATH"

# Step 3: {app} 디렉토리 자동 감지 (com.* 제외, pom.xml 포함)
APP_DIR=""
for dir in "${PROJECT_ROOT}"/*/; do
  dir_name="$(basename "$dir")"
  [[ "$dir_name" == com.* ]] && continue
  if [ -f "${dir}pom.xml" ]; then
    APP_DIR="$dir_name"
    break
  fi
done
[ -z "$APP_DIR" ] && echo "ERROR: 앱 디렉토리를 자동 감지할 수 없습니다." && exit 1
echo "앱 디렉토리 감지: $APP_DIR"

# Step 4: npm install (node_modules 없을 때만)
if [ ! -d "$UI_PATH/node_modules" ]; then
  echo "node_modules가 없습니다. npm install 실행 중..."
  (cd "$UI_PATH" && npm install)
else
  echo "node_modules 확인 완료. npm install 생략."
fi

# Step 5: npm build
(cd "$UI_PATH" && npm run build)
[ ! -d "$UI_PATH/dist" ] && echo "ERROR: 빌드 후 dist/ 폴더가 생성되지 않았습니다." && exit 1
echo "빌드 완료: $UI_PATH/dist/"

# Step 6: 배포 (dist → {app}/ui/)
APP_UI="${PROJECT_ROOT}/${APP_DIR}/ui"
mkdir -p "$APP_UI"
rm -rf "${APP_UI:?}"/*
cp -r "$UI_PATH"/dist/* "$APP_UI"/
FILE_COUNT=$(find "$APP_UI" -type f | wc -l)

# Step 7: 완료 메시지
cat <<MSG

Custom UI 빌드 및 배포가 완료되었습니다.

  UI 프로젝트: $UI_PATH
  배포 경로:   $APP_UI/
  파일 수:     ${FILE_COUNT}개
MSG
