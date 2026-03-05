# Custom UI Deploy 상세 가이드

## 앱 디렉토리 자동 감지 규칙

- 프로젝트 루트에서 `com.*`으로 시작하지 않으면서 `pom.xml`을 포함하는 첫 번째 하위 디렉토리를 앱으로 인식
- 예: `{projName}/pom.xml` → `APP_DIR={projName}`

## 빌드 전제 조건

- UI 프로젝트는 npm 기반이어야 함 (`package.json` 필수)
- `npm run build` 실행 시 `dist/` 디렉토리가 생성되어야 함 (Vite 기본 출력)
- `vite.config.ts`에 `base: './'` 설정이 되어 있어야 상대 경로로 정상 작동

## 배포 동작

- 대상: `{app}/ui/` 디렉토리
- 배포 시 기존 `ui/` 내용은 완전히 교체됨 (의도된 동작)
- `dist/` 내 모든 파일을 `ui/`로 복사

## 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| `dist/` 미생성 | build script 누락 또는 에러 | `package.json`의 `scripts.build` 확인 |
| 경로 깨짐 | `base` 설정 누락 | `vite.config.ts`에 `base: './'` 추가 |
| 앱 감지 실패 | `pom.xml` 없음 | 앱 디렉토리에 `pom.xml` 존재 확인 |
