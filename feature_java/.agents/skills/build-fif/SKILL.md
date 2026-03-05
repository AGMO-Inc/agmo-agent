---
name: build-fif
description: 배포용 FIF 파일 빌드 (Docker 기반)
triggers:
  - build fif
  - fif 빌드
  - 배포 빌드
  - fif build
aliases: [fif-build, deploy-build]
quality: high
model: sonnet
context: fork
agent: seamos-builder
---

# FIF Build Skill

> **Agent 위임**: 이 스킬의 모든 작업은 Agent 도구를 사용하여 `seamos-builder` 에이전트에게 위임하여 실행할 것. Agent 호출 시 사용자의 요청 내용과 파싱된 인자를 프롬프트로 전달한다.

배포용 FIF 파일을 자동으로 빌드한다. Docker 확인 → Maven JAR 빌드 → Docker 이미지 Pull → FIF 생성까지 전 과정을 자동화.

**IMPORTANT: 이 스킬이 로드되면 즉시 빌드 스크립트를 실행하라. 문서를 출력하지 말고 바로 실행할 것.**

## 설정값

| 환경변수 | 설명 | 기본값 |
|---|---|---|
| `NVX_DOCKER_IMAGE` | Docker Registry FIF gen 이미지 | `public.ecr.aws/g0j5z0m9/seamos/app-builder:8.5.0` |

## 실행

프로젝트 루트에서 빌드 스크립트 실행:

```bash
bash "$(dirname "$0")/../.claude/skills/build-fif/scripts/build-fif.sh" "$PWD"
```

또는 스킬 디렉토리 기준:

```bash
SKILL_DIR="<skill-directory-path>"
bash "$SKILL_DIR/scripts/build-fif.sh" "$PWD"
```

스크립트가 7단계를 자동 실행한다:

1. Docker 설치/실행 확인
2. 프로젝트 구조 검증 (FSP, pom.xml)
3. gen JAR 로컬 Maven 설치 + 앱 JAR 빌드
4. Docker 이미지 pull (캐시 존재 시 스킵)
5. 임시 디렉토리 준비 및 파일 복사
6. Docker 컨테이너에서 FIF 생성
7. 결과물을 `output/fif_output/`에 복사

실패 시 `trap EXIT`으로 Docker 컨테이너 및 임시 파일 자동 정리.

## 참조

- [빌드 상세 설명](references/build-details.md) - gen JAR 의존성, Docker 이미지 관리, invoke_offline_util.sh 매핑, 트러블슈팅
