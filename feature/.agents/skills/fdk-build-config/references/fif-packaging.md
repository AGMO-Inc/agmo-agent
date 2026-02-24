# FIF 패키지 & Azure 파이프라인 상세

## FIF 패키지 구조

### Manifest.xml 스키마

```xml
<?xml version="1.0" encoding="UTF-8"?>
<feature>
    <name>My Feature</name>
    <version>1.0.0</version>
    <vendor>My Company</vendor>
    <description>Feature description</description>

    <!-- GUI 설정 -->
    <gui type="custom_with_hmi_gui">
        <page name="main" src="index.html"/>
        <page name="settings" src="settings.html"/>
    </gui>

    <!-- 바이너리 설정 -->
    <binary>
        <cpp>bin/my_feature</cpp>
        <java>bin/my_feature.jar</java>
    </binary>

    <!-- 필요 권한 -->
    <permissions>
        <permission>imu</permission>
        <permission>gnss</permission>
        <permission>cloud</permission>
        <permission>d2d</permission>
        <permission>usb</permission>
    </permissions>

    <!-- 하드웨어 요구사항 -->
    <requirements>
        <min-firmware>2.0.0</min-firmware>
        <min-memory>256MB</min-memory>
    </requirements>
</feature>
```

### 패키지 디렉토리 구조

```
my-feature.fif (ZIP 기반)
├── Manifest.xml            # Feature 메타데이터
├── bin/
│   ├── my_feature          # C++ 바이너리 (aarch64)
│   └── my_feature.jar      # Java JAR (선택적)
├── webapp/
│   ├── index.html
│   ├── settings.html
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   ├── app.js
│   │   └── lib/
│   │       └── jquery-3.7.1.min.js
│   └── img/
├── config/
│   └── default_config.json # 기본 설정
├── data/
│   └── test_route.csv      # 부속 데이터 (선택적)
└── signature               # 디지털 서명
```

## Azure DevOps 파이프라인 전체 예제

### azure-pipelines.yml

```yaml
trigger:
  branches:
    include:
      - main
      - develop
      - feature/*
  paths:
    exclude:
      - '*.md'
      - 'docs/**'

pr:
  branches:
    include:
      - main
      - develop

variables:
  - name: featureName
    value: 'my-feature'
  - name: buildConfiguration
    value: 'Release'

pool:
  vmImage: 'ubuntu-20.04'

stages:
  # ========== Stage 1: Build ==========
  - stage: Build
    displayName: 'Build Feature'
    jobs:
      - job: BuildCpp
        displayName: 'Build C++ Components'
        steps:
          - task: UsePythonVersion@0
            inputs:
              versionSpec: '3.10'

          # 크로스 컴파일 도구 설치
          - script: |
              sudo apt-get update
              sudo apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
            displayName: 'Install aarch64 toolchain'

          # CMake 빌드
          - script: |
              mkdir -p build
              cd build
              cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain-aarch64.cmake \
                    -DCMAKE_BUILD_TYPE=$(buildConfiguration) \
                    ..
              make -j$(nproc)
            displayName: 'CMake Build (aarch64)'

          # 바이너리 아티팩트 게시
          - publish: $(System.DefaultWorkingDirectory)/build/$(featureName)
            artifact: cpp-binary
            displayName: 'Publish C++ binary'

      - job: BuildJava
        displayName: 'Build Java Components'
        condition: and(succeeded(), eq(variables['hasJava'], 'true'))
        steps:
          - task: Maven@3
            inputs:
              mavenPomFile: 'pom.xml'
              goals: 'package'
              options: '-DskipTests'
            displayName: 'Maven Package'

          - publish: $(System.DefaultWorkingDirectory)/target/$(featureName).jar
            artifact: java-jar
            displayName: 'Publish JAR'

  # ========== Stage 2: Test ==========
  - stage: Test
    displayName: 'Run Tests'
    dependsOn: Build
    condition: succeeded()
    jobs:
      - job: UnitTests
        displayName: 'Unit Tests'
        steps:
          - script: |
              mkdir -p build-test
              cd build-test
              cmake -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON ..
              make -j$(nproc)
              ctest --output-on-failure
            displayName: 'Run C++ unit tests'

  # ========== Stage 3: Package ==========
  - stage: Package
    displayName: 'Create FIF Package'
    dependsOn:
      - Build
      - Test
    condition: succeeded()
    jobs:
      - job: CreateFIF
        displayName: 'Package FIF'
        steps:
          # 아티팩트 다운로드
          - download: current
            artifact: cpp-binary

          # FIF 패키지 생성
          - script: |
              mkdir -p fif-staging/bin
              mkdir -p fif-staging/webapp
              mkdir -p fif-staging/config

              # 바이너리 복사
              cp $(Pipeline.Workspace)/cpp-binary/$(featureName) fif-staging/bin/

              # 웹앱 복사
              cp -r webapp/* fif-staging/webapp/

              # 설정 복사
              cp config/default_config.json fif-staging/config/

              # Manifest 복사
              cp Manifest.xml fif-staging/

              # FIF 생성 (ZIP)
              cd fif-staging
              zip -r $(Build.ArtifactStagingDirectory)/$(featureName)-$(Build.BuildNumber).fif .
            displayName: 'Create FIF package'

          # FIF 아티팩트 게시
          - publish: $(Build.ArtifactStagingDirectory)/$(featureName)-$(Build.BuildNumber).fif
            artifact: fif-package
            displayName: 'Publish FIF'

  # ========== Stage 4: Deploy ==========
  - stage: Deploy
    displayName: 'Deploy to NEVONEX'
    dependsOn: Package
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployFIF
        displayName: 'Deploy FIF to NEVONEX Portal'
        environment: 'production'
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: fif-package

                - script: |
                    echo "Deploying $(featureName) to NEVONEX Portal..."
                    # NEVONEX 배포 스크립트/API 호출
                    # ./tools/deploy_to_nevonex.sh $(Pipeline.Workspace)/fif-package/*.fif
                  displayName: 'Deploy to NEVONEX'
```

### 환경 변수 / 시크릿

| 변수 | 용도 | 설정 위치 |
|------|------|----------|
| `NEVONEX_API_KEY` | 포털 API 인증 | Pipeline Library (Secret) |
| `SIGNING_CERT` | FIF 서명 인증서 | Secure Files |
| `featureName` | Feature 이름 | Pipeline Variables |

## 로컬 빌드 가이드

### 네이티브 빌드 (개발/테스트)

```bash
mkdir build-native && cd build-native
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j$(nproc)
./my_feature  # 로컬에서 테스트
```

### 크로스 빌드 (배포)

```bash
mkdir build-arm && cd build-arm
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain-aarch64.cmake \
      -DCMAKE_BUILD_TYPE=Release \
      ..
make -j$(nproc)
file my_feature  # "ELF 64-bit LSB executable, ARM aarch64" 확인
```

### 수동 FIF 생성

```bash
mkdir -p fif-staging/{bin,webapp,config}
cp build-arm/my_feature fif-staging/bin/
cp -r webapp/* fif-staging/webapp/
cp Manifest.xml fif-staging/
cd fif-staging
zip -r ../my-feature.fif .
```
