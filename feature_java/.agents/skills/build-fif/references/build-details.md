# FIF Build 상세 설명

## 목차

- [프로젝트 디렉토리 구조](#프로젝트-디렉토리-구조)
- [gen JAR 의존성 처리](#gen-jar-의존성-처리)
- [Docker 이미지 관리](#docker-이미지-관리)
- [invoke_offline_util.sh 매핑](#invoke_offline_utilsh-매핑)
- [build.sh 인자 설명](#buildsh-인자-설명)
- [트러블슈팅](#트러블슈팅)

---

## 프로젝트 디렉토리 구조

FIF 빌드 대상 프로젝트는 다음 구조를 따른다:

```
<FEATURE_NAME>/              ← PROJ_ROOT (프로젝트 루트)
├── com.bosch.fsp.<name>/    ← FSP_PATH (FSP 프로젝트)
├── com.bosch.fsp.<name>.gen/← GEN_PATH (gen 프로젝트, JAR 소스)
├── <name>/                  ← APP_PATH (앱 프로젝트, pom.xml 포함)
│   └── pom.xml
└── output/fif_output/       ← 빌드 결과물 출력 위치
```

## gen JAR 의존성 처리

gen 프로젝트(`com.bosch.fsp.<name>.gen`)의 JAR을 로컬 Maven 저장소에 설치할 때 **반드시 `-DpomFile` 옵션**을 사용해야 한다.

### 왜 `-DpomFile`이 필수인가?

`mvn install:install-file`에 `-Dfile`만 지정하면 POM 없이 JAR만 설치된다. 이 경우:
- gen JAR이 의존하는 EMF, Spark 등 transitive dependency가 Maven 의존성 그래프에서 누락
- 앱 프로젝트(`mvn package`) 빌드 시 컴파일 에러 발생

`-DpomFile`을 함께 지정하면 gen 프로젝트의 `pom.xml`에 선언된 모든 dependency가 로컬 저장소에 함께 등록되어 transitive dependency가 정상 해결된다.

### JAR 빌드 방식

앱 프로젝트는 `maven-assembly-plugin`의 `jar-with-dependencies` 설정으로 Runnable JAR을 생성한다. 빌드 결과물은 `target/*-jar-with-dependencies.jar` 패턴으로 동적 탐지한다.

## Docker 이미지 관리

- 기본 이미지: `public.ecr.aws/g0j5z0m9/seamos/app-builder:8.5.0` (AWS Public ECR)
- `NVX_DOCKER_IMAGE` 환경변수로 다른 버전/레지스트리 이미지 오버라이드 가능
- Registry 이미지를 pull 후 `nvx-fif-gen:<version>` 로컬 태그를 부여하여 캐싱
- 재실행 시 로컬 태그가 존재하면 pull을 스킵

## invoke_offline_util.sh 매핑

스크립트의 각 단계는 원본 `invoke_offline_util.sh`의 로직을 비대화형으로 재현한다:

| 스크립트 Step | invoke_offline_util.sh 라인 | 설명 |
|---|---|---|
| Step 5 (임시 디렉토리) | 73-99 | /tmp/nvx 구성 및 파일 복사 |
| Step 6 (컨테이너 실행) | 106-125 | Docker run/cp/exec |

### target/ 제거 이유 (Step 5)

`/tmp/nvx/app_proj/`에 복사 후 `target/` 디렉토리를 삭제하는 이유:
- 컨테이너 내부 `package_java.sh`가 JAR 파일을 glob 패턴으로 탐지
- `target/`이 남아있으면 중복 JAR이 매치되어 빌드 실패 가능
- 원본 `invoke_offline_util.sh:89-90`과 동일한 처리

## build.sh 인자 설명

```
docker exec $CONTAINER /usr/share/build.sh \
    $1: FEATURE_NAME        - 피처 이름
    $2: APP_DIR_NAME        - 앱 디렉토리명 (basename)
    $3: FSP_DIR_NAME        - FSP 디렉토리명 (basename)
    $4: "java"              - 빌드 타입
    $5: CPP_SDK_PATH        - C++ SDK 경로 (Java 빌드에서는 미사용, 원본 호환용)
    $6: JAR_PATH            - JAR 파일 경로
    $7: "aarch64"           - 타겟 아키텍처
```

5번째 인자 `${FEATURE_NAME}_CPP_SDK`는 원본 `invoke_offline_util.sh:18`의 SDK_PATH 패턴. Java 빌드에서는 실제로 사용되지 않으나 원본 동작과의 호환성을 위해 유지.

## 트러블슈팅

### Docker 관련

| 증상 | 원인 | 해결 |
|---|---|---|
| `Docker가 설치되어 있지 않습니다` | Docker 미설치 | `sudo apt-get install -y docker.io` |
| `Docker daemon is not running` | 데몬 미실행 | `sudo systemctl start docker` |
| `permission denied` | 권한 부족 | `sudo usermod -aG docker $USER` 후 재로그인 |

### Maven 빌드 관련

| 증상 | 원인 | 해결 |
|---|---|---|
| `gen JAR이 없습니다` | gen 프로젝트 미빌드 | `com.bosch.fsp.<name>.gen` 프로젝트 먼저 빌드 |
| EMF/Spark 컴파일 에러 | `-DpomFile` 누락 | 스크립트가 자동 처리 (수동 실행 시 확인) |
| `jar-with-dependencies JAR not found` | assembly 플러그인 미설정 | pom.xml의 maven-assembly-plugin 설정 확인 |

### FIF 결과물 관련

| 증상 | 원인 | 해결 |
|---|---|---|
| `FIF 파일을 찾을 수 없습니다` | build.sh 실패 | Docker 로그 확인: `docker logs nvx-fif-gen-cntr` |
| 출력 디렉토리 비어있음 | 컨테이너 내부 에러 | `docker exec nvx-fif-gen-cntr ls /fif_output/` 로 확인 |
