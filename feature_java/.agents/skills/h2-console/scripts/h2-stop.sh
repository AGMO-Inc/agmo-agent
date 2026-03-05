#!/bin/bash
PID=$(lsof -ti:8082 2>/dev/null || true)
if [ -n "$PID" ]; then
  kill $PID
  echo "H2 Console이 종료되었습니다."
else
  echo "실행 중인 H2 Console이 없습니다."
fi
