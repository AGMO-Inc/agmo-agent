#!/bin/bash
# 현재 프로젝트 식별. 출력: REPO OWNER PROJECT (공백 구분)
REPO=$(git remote get-url origin 2>/dev/null | sed -E 's#.+[:/]([^/]+/[^/.]+)(\.git)?$#\1#')
OWNER=$(echo "$REPO" | cut -d/ -f1)
PROJECT=$(echo "$REPO" | cut -d/ -f2)
echo "$REPO $OWNER $PROJECT"
