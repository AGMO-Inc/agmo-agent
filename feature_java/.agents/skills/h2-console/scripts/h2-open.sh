#!/bin/bash
set -e

# 앱 프로세스 종료 (port 1456 - H2 파일 DB 동시 접근 불가)
lsof -ti:1456 | xargs -r kill 2>/dev/null || true

# 앱 디렉토리 자동 감지 (com.* 제외, pom.xml 포함)
APP_DIR=""
for dir in */; do
  dir_name="$(basename "$dir")"
  [[ "$dir_name" == com.* ]] && continue
  if [ -f "${dir}pom.xml" ]; then
    APP_DIR="$dir_name"
    break
  fi
done

if [ -z "$APP_DIR" ]; then
  echo "ERROR: 앱 디렉토리를 자동 감지할 수 없습니다. (pom.xml 포함 디렉토리 필요)"
  exit 1
fi

# jar-with-dependencies JAR 자동 감지
JAR_FILE=$(ls "$APP_DIR"/target/*-jar-with-dependencies.jar 2>/dev/null | head -1)
if [ -z "$JAR_FILE" ]; then
  echo "ERROR: jar-with-dependencies JAR을 찾을 수 없습니다. 먼저 빌드를 실행해 주세요."
  exit 1
fi

# H2 Console 백그라운드 실행
cd "$APP_DIR"
java -cp "../$JAR_FILE" org.h2.tools.Console -web -webPort 8082 &

# 접속 확인 (최대 5초)
sleep 2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082)
if [ "$HTTP_CODE" = "200" ]; then
  cat <<EOF
H2 Console이 실행되었습니다.

  URL:       http://localhost:8082
  JDBC URL:  jdbc:h2:./disk/${APP_DIR}
  User:      sa
  Password:  (빈칸)

종료하려면: /h2-console stop
EOF
else
  echo "ERROR: H2 Console 실행 실패 (HTTP $HTTP_CODE)"
  exit 1
fi
