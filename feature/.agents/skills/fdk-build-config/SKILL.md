---
name: fdk-build-config
description: "(feature - Skill) NEVONEX FDK 빌드 설정 가이드. CMake FetchContent를 이용한 C++ 외부 라이브러리 추가, Maven/JAR 기반 Java 의존성 관리, FIF(Feature Install File) 패키지 생성, Azure DevOps CI/CD 파이프라인 설정을 다룬다. Feature 빌드 구성 변경, 새 라이브러리 추가, 배포 패키지 생성 시 사용한다. 'CMake 설정', '라이브러리 추가', 'FetchContent', 'FIF 패키지', '빌드 설정', 'Maven 의존성', 'CI/CD 파이프라인', 'Azure DevOps', '배포 패키지' 같은 요청에서 사용한다."
---

# FDK Build Config

## Overview

NEVONEX Feature는 C++(CMake)과 Java(Maven/JAR) 빌드 시스템을 사용한다. 배포 시 `.fif`(Feature Install File) 패키지로 묶어 CCU에 설치하며, Azure DevOps 파이프라인으로 자동화한다.

## C++ 외부 라이브러리 추가 (CMake FetchContent)

### 기본 패턴

`CMakeLists.txt`에 `FetchContent`로 외부 라이브러리를 추가한다:

```cmake
cmake_minimum_required(VERSION 3.17)

include(FetchContent)

# 예: nlohmann/json 라이브러리 추가
FetchContent_Declare(
    nlohmann_json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG        v3.11.2
)
FetchContent_MakeAvailable(nlohmann_json)

# 타겟에 링크
target_link_libraries(${PROJECT_NAME} PRIVATE nlohmann_json::nlohmann_json)
```

### Header-Only 라이브러리

```cmake
FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG        v1.12.0
)
FetchContent_MakeAvailable(spdlog)
target_link_libraries(${PROJECT_NAME} PRIVATE spdlog::spdlog_header_only)
```

### 로컬 라이브러리 (소스 포함)

```cmake
# 프로젝트 내 lib/ 디렉토리에 있는 라이브러리
add_subdirectory(lib/my_custom_lib)
target_link_libraries(${PROJECT_NAME} PRIVATE my_custom_lib)
```

### 주의사항

- **CMake 최소 버전**: 3.17 (CCU 빌드 환경)
- **C++ 표준**: C++11 (`set(CMAKE_CXX_STANDARD 11)`)
- **타겟 아키텍처**: `aarch64` (CCU ARM 프로세서)
- **크로스 컴파일**: CCU 툴체인 사용 시 라이브러리가 ARM 호환인지 확인
- **라이선스**: 오픈소스 라이브러리 라이선스 호환성 확인 필수

## Java 의존성 관리

### Maven (권장)

`pom.xml`에 의존성 추가:

```xml
<dependency>
    <groupId>com.google.code.gson</groupId>
    <artifactId>gson</artifactId>
    <version>2.10.1</version>
</dependency>
```

### 수동 JAR 추가

Maven 없이 직접 JAR를 사용하는 경우:

```
feature/
├── lib/
│   ├── gson-2.10.1.jar
│   └── commons-io-2.13.0.jar
└── src/
    └── main/java/...
```

Build path에 JAR 추가:
```xml
<!-- pom.xml systemPath 방식 -->
<dependency>
    <groupId>local</groupId>
    <artifactId>custom-lib</artifactId>
    <version>1.0</version>
    <scope>system</scope>
    <systemPath>${project.basedir}/lib/custom-lib.jar</systemPath>
</dependency>
```

## FIF 패키지 생성

FIF(Feature Install File)는 CCU에 설치하는 최종 배포 패키지다.

### 패키지 구성

```
my-feature.fif
├── bin/                    # 컴파일된 바이너리 (aarch64)
├── webapp/                 # 웹 UI 파일
├── config/                 # 설정 파일
├── Manifest.xml            # Feature 메타데이터
└── signature               # 서명 파일
```

### 빌드 → 패키징 흐름

```
1. C++ 빌드    : CMake → make → aarch64 바이너리
2. Java 빌드   : Maven → JAR
3. UI 번들     : webapp/ 디렉토리 복사
4. FIF 생성    : 빌드 도구가 위 산출물을 .fif로 패키징
5. 서명        : NEVONEX 인증서로 서명
```

## Azure DevOps CI/CD 파이프라인

### 파이프라인 구조

```yaml
# azure-pipelines.yml (예시 구조)
trigger:
  branches:
    include:
      - main
      - develop

pool:
  vmImage: 'ubuntu-latest'

stages:
  - stage: Build
    jobs:
      - job: BuildFeature
        steps:
          - task: CMake@1
            inputs:
              cmakeArgs: '-DCMAKE_TOOLCHAIN_FILE=toolchain-aarch64.cmake ..'
          - script: make -j$(nproc)
            displayName: 'Build C++ binary'
          - task: Maven@3
            inputs:
              mavenPomFile: 'pom.xml'
              goals: 'package'
            displayName: 'Build Java components'

  - stage: Package
    dependsOn: Build
    jobs:
      - job: CreateFIF
        steps:
          - script: ./tools/create_fif.sh
            displayName: 'Create FIF package'
          - publish: $(Build.ArtifactStagingDirectory)/my-feature.fif
            artifact: fif-package

  - stage: Deploy
    dependsOn: Package
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    jobs:
      - job: DeployToNEVONEX
        steps:
          - download: current
            artifact: fif-package
          - script: ./tools/deploy_fif.sh
            displayName: 'Deploy to NEVONEX portal'
```

### 주요 파이프라인 단계

| 단계 | 동작 |
|------|------|
| Build | CMake 크로스 컴파일 (aarch64) + Maven Java 빌드 |
| Package | 바이너리 + webapp + config → FIF 패키징 + 서명 |
| Deploy | NEVONEX 포털에 업로드 (main 브랜치만) |

### 크로스 컴파일 툴체인

```cmake
# toolchain-aarch64.cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)
```

## 체크리스트

새 라이브러리 추가 시:
- [ ] 라이선스 호환성 확인 (GPL 주의)
- [ ] aarch64 크로스 컴파일 호환성 확인
- [ ] CMake FetchContent 또는 Maven dependency 추가
- [ ] CI/CD 파이프라인에서 빌드 확인
- [ ] FIF 패키지 크기 영향 확인 (CCU 저장공간 제한: 16GB eMMC)

## Resources

### references/
- `cmake-patterns.md` — CMake FetchContent 고급 패턴, 크로스 컴파일 설정, 자주 사용하는 C++ 라이브러리 목록
- `fif-packaging.md` — FIF 패키지 상세 구조, Manifest.xml 스키마, Azure 파이프라인 전체 예제
