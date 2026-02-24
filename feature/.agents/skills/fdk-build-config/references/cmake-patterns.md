# CMake FetchContent 고급 패턴

## 자주 사용하는 C++ 라이브러리

### JSON 파싱 (nlohmann/json)

```cmake
FetchContent_Declare(
    nlohmann_json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG        v3.11.2
)
FetchContent_MakeAvailable(nlohmann_json)
target_link_libraries(${PROJECT_NAME} PRIVATE nlohmann_json::nlohmann_json)
```

### 로깅 (spdlog)

```cmake
FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG        v1.12.0
)
FetchContent_MakeAvailable(spdlog)
target_link_libraries(${PROJECT_NAME} PRIVATE spdlog::spdlog_header_only)
```

### HTTP 클라이언트 (cpp-httplib, header-only)

```cmake
FetchContent_Declare(
    httplib
    GIT_REPOSITORY https://github.com/yhirose/cpp-httplib.git
    GIT_TAG        v0.14.1
)
FetchContent_MakeAvailable(httplib)
target_link_libraries(${PROJECT_NAME} PRIVATE httplib::httplib)
```

### CSV 파싱 (csv-parser)

```cmake
FetchContent_Declare(
    csv_parser
    GIT_REPOSITORY https://github.com/vincentlaucsb/csv-parser.git
    GIT_TAG        2.1.3
)
FetchContent_MakeAvailable(csv_parser)
target_link_libraries(${PROJECT_NAME} PRIVATE csv)
```

### 수학/선형대수 (Eigen, header-only)

```cmake
FetchContent_Declare(
    eigen
    GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
    GIT_TAG        3.4.0
    GIT_SHALLOW    TRUE  # 큰 레포는 shallow clone
)
FetchContent_MakeAvailable(eigen)
target_include_directories(${PROJECT_NAME} PRIVATE ${eigen_SOURCE_DIR})
```

## FetchContent 고급 옵션

### Shallow Clone (빌드 속도 향상)

```cmake
FetchContent_Declare(
    large_lib
    GIT_REPOSITORY https://github.com/example/large-lib.git
    GIT_TAG        v1.0.0
    GIT_SHALLOW    TRUE    # 전체 히스토리 안 받음
)
```

### 특정 디렉토리만 (PATCH_COMMAND)

```cmake
FetchContent_Declare(
    my_lib
    URL https://github.com/example/lib/archive/v1.0.tar.gz
    URL_HASH SHA256=abc123...
)
```

### 빌드 옵션 설정

```cmake
# FetchContent_MakeAvailable 전에 옵션 설정
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)     # 테스트 빌드 안 함
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)    # 예제 빌드 안 함
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE) # 정적 라이브러리

FetchContent_MakeAvailable(my_lib)
```

## 크로스 컴파일 (aarch64)

### 툴체인 파일

```cmake
# toolchain-aarch64.cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# CCU 빌드 환경의 크로스 컴파일러 경로
set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# Sysroot (선택적)
# set(CMAKE_SYSROOT /path/to/aarch64-sysroot)

# 라이브러리 검색 경로
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
```

### 빌드 명령

```bash
mkdir build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain-aarch64.cmake \
      -DCMAKE_BUILD_TYPE=Release \
      ..
make -j$(nproc)
```

### ARM 호환성 확인

```bash
# 빌드된 바이너리 아키텍처 확인
file build/my_feature
# 예: ELF 64-bit LSB executable, ARM aarch64

# 라이브러리 의존성 확인 (크로스 환경)
aarch64-linux-gnu-readelf -d build/my_feature
```

## 전체 CMakeLists.txt 예시

```cmake
cmake_minimum_required(VERSION 3.17)
project(MyFeature VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# FetchContent 모듈
include(FetchContent)

# 외부 의존성
FetchContent_Declare(
    nlohmann_json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG        v3.11.2
)

FetchContent_Declare(
    csv_parser
    GIT_REPOSITORY https://github.com/vincentlaucsb/csv-parser.git
    GIT_TAG        2.1.3
)

FetchContent_MakeAvailable(nlohmann_json csv_parser)

# 소스 파일
file(GLOB_RECURSE SOURCES "src/*.cpp")

# 실행 파일
add_executable(${PROJECT_NAME} ${SOURCES})

# 링크
target_link_libraries(${PROJECT_NAME} PRIVATE
    nlohmann_json::nlohmann_json
    csv
    # NEVONEX SDK 라이브러리 (빌드 환경에서 제공)
    nevonex_sdk
)

# 인클루드 경로
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)
```
