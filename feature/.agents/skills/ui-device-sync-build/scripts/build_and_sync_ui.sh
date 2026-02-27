#!/usr/bin/env bash
set -euo pipefail

MODE="prod"
UI_DIR=""
DEVICE_UI_DIR=""
DEVICE_UI_ALT_DIR=""
CUSTOM_BUILD_CMD=""
INSTALL_CMD="npm install"
SKIP_INSTALL="false"
DRY_RUN="false"

usage() {
  cat <<'USAGE'
Usage: build_and_sync_ui.sh [options]

Options:
  --mode <prod|dev|map>     Build mode (default: prod)
  --ui-dir <path>           UI project directory (contains package.json)
  --device-ui-dir <path>    Primary device UI target directory
  --device-ui-alt-dir <path> Optional alternate device UI target directory
  --build-cmd <command>     Custom build command (overrides --mode)
  --install-cmd <command>   Dependency install command (default: npm install)
  --skip-install            Skip dependency installation even if node_modules is missing
  --dry-run                 Print resolved paths and commands without running build/sync
  -h, --help                Show this help

Notes:
  - For new projects, pass --ui-dir and --device-ui-dir explicitly.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --ui-dir)
      UI_DIR="${2:-}"
      shift 2
      ;;
    --device-ui-dir)
      DEVICE_UI_DIR="${2:-}"
      shift 2
      ;;
    --device-ui-alt-dir)
      DEVICE_UI_ALT_DIR="${2:-}"
      shift 2
      ;;
    --build-cmd)
      CUSTOM_BUILD_CMD="${2:-}"
      shift 2
      ;;
    --install-cmd)
      INSTALL_CMD="${2:-}"
      shift 2
      ;;
    --skip-install)
      SKIP_INSTALL="true"
      shift
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$MODE" != "prod" && "$MODE" != "dev" && "$MODE" != "map" ]]; then
  echo "Invalid --mode: $MODE (expected prod|dev|map)" >&2
  exit 2
fi

if [[ -z "$UI_DIR" || -z "$DEVICE_UI_DIR" ]]; then
  echo "Missing required paths. Provide --ui-dir and --device-ui-dir." >&2
  exit 1
fi

if [[ ! -d "$UI_DIR" ]]; then
  echo "UI directory not found: $UI_DIR" >&2
  exit 1
fi

if [[ -d "$DEVICE_UI_DIR" ]]; then
  TARGET_DIR="$DEVICE_UI_DIR"
elif [[ -n "$DEVICE_UI_ALT_DIR" && -d "$DEVICE_UI_ALT_DIR" ]]; then
  TARGET_DIR="$DEVICE_UI_ALT_DIR"
else
  TARGET_DIR="$DEVICE_UI_DIR"
fi

if [[ -n "$CUSTOM_BUILD_CMD" ]]; then
  BUILD_CMD_STR="$CUSTOM_BUILD_CMD"
else
  case "$MODE" in
    prod) BUILD_CMD_STR="npm run build" ;;
    dev) BUILD_CMD_STR="npm run build:dev" ;;
    map) BUILD_CMD_STR="npm run build:map" ;;
  esac
fi

echo "[ui-sync] ui dir: $UI_DIR"
echo "[ui-sync] target dir: $TARGET_DIR"
echo "[ui-sync] mode: $MODE"
echo "[ui-sync] build command: $BUILD_CMD_STR"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "[ui-sync] DRY RUN"
  exit 0
fi

cd "$UI_DIR"
if [[ "$SKIP_INSTALL" != "true" && -f "package.json" && ! -d "node_modules" ]]; then
  echo "[ui-sync] node_modules missing -> $INSTALL_CMD"
  bash -lc "$INSTALL_CMD"
fi

echo "[ui-sync] building UI..."
bash -lc "$BUILD_CMD_STR"

DIST_DIR="$UI_DIR/dist"
if [[ ! -d "$DIST_DIR" ]]; then
  echo "Build finished but dist directory not found: $DIST_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

echo "[ui-sync] syncing dist -> device ui"
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "$DIST_DIR/" "$TARGET_DIR/"
else
  find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  cp -R "$DIST_DIR/." "$TARGET_DIR/"
fi

echo "[ui-sync] done"
echo "[ui-sync] deployed to: $TARGET_DIR"
