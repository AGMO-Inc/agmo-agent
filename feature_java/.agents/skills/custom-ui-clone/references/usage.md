# Custom UI Clone 사용 가이드

## 인자 패턴

| 인자 패턴 | 동작 |
|---|---|
| `[target-directory]` | 지정한 경로에 클론 |
| (인자 없음) | 현재 디렉토리에 `custom-ui-react-template/`으로 클론 |

## 저장소 정보

- GitHub: https://github.com/AGMO-Inc/custom-ui-react-template.git
- 스택: React + TypeScript + Vite + TanStack Router
- 클론 후 `npm install`로 의존성 설치 필요

## 트러블슈팅

| 증상 | 원인 | 해결 |
|---|---|---|
| `디렉토리가 존재합니다` | 이미 클론됨 | 삭제 후 재시도 또는 다른 경로 지정 |
| `git clone` 실패 | 네트워크/권한 문제 | GitHub 접근 가능 여부 확인, SSH key 또는 토큰 확인 |
| `npm install` 실패 | Node.js 미설치 | Node.js 18+ 설치 필요 |
