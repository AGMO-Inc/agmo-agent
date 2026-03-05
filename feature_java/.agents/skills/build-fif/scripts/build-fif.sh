#!/usr/bin/env bash
#
# build-fif.sh - 배포용 FIF 파일 자동 빌드 스크립트
#
# 사용법:
#   ./build-fif.sh [프로젝트_루트]
#
# 환경변수:
#   NVX_DOCKER_IMAGE - Docker Registry 이미지 (기본: public.ecr.aws/g0j5z0m9/seamos/app-builder:8.5.0)
#
set -euo pipefail

PROJ_ROOT="${1:-$PWD}"
cd "$PROJ_ROOT"

FEATURE_NAME=$(basename "$PROJ_ROOT")
FSP_PATH="$PROJ_ROOT/com.bosch.fsp.$FEATURE_NAME"
APP_PATH="$PROJ_ROOT/$FEATURE_NAME"
CONTAINER="nvx-fif-gen-cntr"
NVX_DOCKER_IMAGE="${NVX_DOCKER_IMAGE:-public.ecr.aws/g0j5z0m9/seamos/app-builder:8.5.0}"
NVX_VERSION="${NVX_DOCKER_IMAGE##*:}"

# ── Step 1: Docker 설치 및 실행 확인 ────────────────────────
echo "[1/7] Docker 확인 중..."

DOCKER_BIN=""
for p in /usr/bin/docker /usr/local/bin/docker /snap/bin/docker; do
    [ -x "$p" ] && DOCKER_BIN="$p" && break
done
[ -z "$DOCKER_BIN" ] && DOCKER_BIN=$(command -v docker 2>/dev/null || true)

if [ -z "$DOCKER_BIN" ]; then
    echo "ERROR: Docker가 설치되어 있지 않습니다."
    echo "  Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y docker.io"
    echo "  공식 문서: https://docs.docker.com/engine/install/ubuntu/"
    exit 1
fi

if ! "$DOCKER_BIN" info >/dev/null 2>&1; then
    echo "ERROR: Docker daemon is not running."
    echo "  실행: sudo systemctl start docker"
    exit 1
fi

echo "[1/7] Docker 확인 완료 ($DOCKER_BIN)"

# ── Step 2: 프로젝트 검증 ──────────────────────────────────
echo "[2/7] 프로젝트 검증 중..."

if [ ! -d "$FSP_PATH" ]; then
    echo "ERROR: FSP 디렉토리가 없습니다: $FSP_PATH"
    exit 1
fi

if [ ! -f "$APP_PATH/pom.xml" ]; then
    echo "ERROR: pom.xml이 없습니다: $APP_PATH/pom.xml"
    exit 1
fi

echo "[2/7] 프로젝트 검증 완료"
echo "  Feature: $FEATURE_NAME"
echo "  FSP: $FSP_PATH"
echo "  App: $APP_PATH"
echo "  Docker Image: $NVX_DOCKER_IMAGE"

# 실패 시 컨테이너 및 임시 파일 자동 정리
trap 'docker rm -f $CONTAINER 2>/dev/null; rm -rf /tmp/nvx' EXIT

# ── Step 3: gen JAR 로컬 설치 및 Maven JAR 빌드 ───────────
echo "[3/7] gen JAR 로컬 설치 및 Maven JAR 빌드 중..."

GEN_PATH="$PROJ_ROOT/com.bosch.fsp.$FEATURE_NAME.gen"
GEN_JAR="$GEN_PATH/target/${FEATURE_NAME}-1.0.0.jar"
GEN_POM="$GEN_PATH/pom.xml"

if [ ! -f "$GEN_JAR" ]; then
    echo "ERROR: gen JAR이 없습니다: $GEN_JAR"
    echo "  com.bosch.fsp.$FEATURE_NAME.gen 프로젝트를 먼저 빌드해주세요."
    exit 1
fi

# gen JAR + POM을 로컬 Maven 저장소에 설치 (pomFile 필수 - references/build-details.md 참조)
mvn install:install-file \
    -Dfile="$GEN_JAR" \
    -DpomFile="$GEN_POM" \
    -q
echo "  gen JAR 로컬 설치 완료"

cd "$APP_PATH" && mvn package -q -DskipTests
cd "$PROJ_ROOT"

JAR_FILE=$(ls "$APP_PATH"/target/*-jar-with-dependencies.jar 2>/dev/null | head -1)
if [ -z "$JAR_FILE" ]; then
    echo "ERROR: jar-with-dependencies JAR not found in $APP_PATH/target/"
    exit 1
fi
JAR_BASENAME=$(basename "$JAR_FILE")
echo "[3/7] JAR 빌드 완료: $JAR_BASENAME"

# ── Step 4: Docker 이미지 Pull ─────────────────────────────
echo "[4/7] Docker 이미지 확인 중..."

if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "nvx-fif-gen:${NVX_VERSION}"; then
    echo "[4/7] Docker 이미지 pulling 중... (시간이 걸릴 수 있습니다)"
    docker pull "$NVX_DOCKER_IMAGE"
    docker tag "$NVX_DOCKER_IMAGE" "nvx-fif-gen:${NVX_VERSION}"
    echo "[4/7] Docker 이미지 pull 완료: nvx-fif-gen:${NVX_VERSION}"
else
    echo "[4/7] Docker 이미지 이미 존재 (스킵)"
fi

# ── Step 5: 임시 디렉토리 준비 및 파일 복사 ────────────────
echo "[5/7] 빌드 파일 준비 중..."

rm -rf /tmp/nvx && mkdir -p /tmp/nvx/{fsp_proj,app_proj,java_app_jar}

cp -r "$FSP_PATH" /tmp/nvx/fsp_proj/
cp -r "$APP_PATH" /tmp/nvx/app_proj/
# target/ 제거: 컨테이너 내 package_java.sh의 중복 JAR glob 매치 방지
rm -rf "/tmp/nvx/app_proj/$(basename "$APP_PATH")/target"
cp "$JAR_FILE" /tmp/nvx/java_app_jar/

echo "[5/7] 빌드 파일 준비 완료"

# ── Step 6: Docker 컨테이너 실행 및 FIF 빌드 ──────────────
echo "[6/7] FIF 빌드 시작..."

docker rm -f "$CONTAINER" 2>/dev/null || true

docker run -d --name "$CONTAINER" "nvx-fif-gen:${NVX_VERSION}" tail -f /dev/null

echo "[6/7] 파일을 컨테이너로 복사 중..."
docker cp /tmp/nvx/fsp_proj/. "$CONTAINER":/usr/nvx/tmp-workspace/
docker cp /tmp/nvx/app_proj/. "$CONTAINER":/usr/nvx/tmp-workspace/
docker cp /tmp/nvx/java_app_jar/. "$CONTAINER":/usr/nvx/tmp-workspace/

echo "[6/7] FIF 생성 중... (시간이 걸릴 수 있습니다)"
docker exec "$CONTAINER" /usr/share/build.sh \
    "$FEATURE_NAME" \
    "$(basename "$APP_PATH")" \
    "$(basename "$FSP_PATH")" \
    java \
    "/usr/nvx/workspace/$FEATURE_NAME/${FEATURE_NAME}_CPP_SDK" \
    "/usr/nvx/workspace/$FEATURE_NAME/$JAR_BASENAME" \
    aarch64

# ── Step 7: 결과물 복사 및 완료 ────────────────────────────
echo "[7/7] 결과물 복사 중..."

rm -rf "$PROJ_ROOT/output"
mkdir -p "$PROJ_ROOT/output"
docker cp "$CONTAINER":/fif_output "$PROJ_ROOT/output/"

FIF_FILE=$(ls "$PROJ_ROOT"/output/fif_output/*.fif 2>/dev/null | head -1)
if [ -n "$FIF_FILE" ]; then
    FIF_SIZE=$(du -h "$FIF_FILE" | cut -f1)
    echo ""
    echo "[7/7] FIF 빌드 완료!"
    echo "  파일: $FIF_FILE"
    echo "  크기: $FIF_SIZE"
    echo "  출력: $PROJ_ROOT/output/fif_output/"
else
    echo ""
    echo "WARNING: FIF 파일을 찾을 수 없습니다. output/fif_output/ 디렉토리를 확인해주세요."
    exit 1
fi
