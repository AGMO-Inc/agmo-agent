---
name: ui-device-sync-build
description: "(feature - Skill) UI 빌드 산출물을 Device UI 디렉토리로 동기화하는 스킬. UI와 Device를 하나의 배포 단위로 취급하며, 빌드만 하고 복사하지 않으면 완료로 간주하지 않는다. 'UI 빌드', 'UI 동기화', 'UI device 반영', 'npm run build 후 복사', 'UI 빌드+동기화', 'device에 UI 반영' 같은 요청에서 사용한다."
---

# UI to Device Sync Build

## 핵심 규칙

- UI와 Device를 하나의 배포 단위로 취급한다.
- `ui 추가`, `ui를 device에 추가`, `ui 빌드` 계열 요청은 **항상** 아래 순서로 수행한다.
  1. UI 빌드 실행
  2. 빌드 산출물(`dist/`)을 Device UI 디렉토리로 동기화

빌드만 하고 복사하지 않으면 완료로 간주하지 않는다.

## 실행 절차

1. 저장소 루트에서 `scripts/build_and_sync_ui.sh`를 실행한다.
2. 프로젝트별 경로는 `AGENTS.md`의 UI/Device 경로 규칙을 우선 적용해 `--ui-dir`/`--device-ui-dir`로 명시한다.
3. 완료 후 대상 디렉토리에 파일이 반영됐는지 확인한다.

## 명령

```bash
scripts/build_and_sync_ui.sh \
  --ui-dir /path/to/project-ui \
  --device-ui-dir /path/to/project-device/ui
```

옵션:

```bash
# 개발 빌드 + 동기화
scripts/build_and_sync_ui.sh --mode dev

# sourcemap 빌드 + 동기화
scripts/build_and_sync_ui.sh --mode map

# 프로젝트 경로를 명시적으로 지정
scripts/build_and_sync_ui.sh \
  --ui-dir /path/to/project-ui \
  --device-ui-dir /path/to/project-device/ui

# 대체 대상 경로를 함께 지정
scripts/build_and_sync_ui.sh \
  --ui-dir /path/to/project-ui \
  --device-ui-dir /path/to/project-device/ui \
  --device-ui-alt-dir /path/to/project-device/ui-alt

# 빌드 명령이 npm 기본값과 다를 때
scripts/build_and_sync_ui.sh \
  --ui-dir /path/to/project-ui \
  --device-ui-dir /path/to/project-device/ui \
  --build-cmd "pnpm build"
```

## 경로 규칙

동기화 대상은 다음 우선순위로 선택한다.

1. `--device-ui-dir`가 지정되면 해당 경로 사용
2. `--device-ui-alt-dir`가 있고 1번이 없으면 대체 경로 사용
3. 둘 다 없으면 실패 처리한다

## 완료 기준

- UI 빌드가 성공한다.
- Device UI 경로가 최신 `dist/` 내용으로 덮어써진다(`delete + copy`).
- 최종 응답에 사용한 빌드 모드와 동기화 경로를 명시한다.
