# Protected Region 상세 규칙

## 코드 재생성 매커니즘

Feature Designer에서 `.fpd` 모델을 저장/빌드하면 코드가 재생성된다. 이때:

1. `/*PROTECTED REGION ID(...) ENABLED START*/` ~ `/*PROTECTED REGION END*/` 사이의 코드만 보존
2. Protected Region 외부의 **모든** 수정은 원본으로 덮어씌워짐
3. `ENABLED` 키워드가 **없는** Protected Region은 빈 상태로 재생성됨

## Protected Region 패턴

### C++ 표준 패턴

```cpp
/*PROTECTED REGION ID(cpp_controller_includes) ENABLED START*/
#include <vector>
#include <json/json.h>
#include "MyHelper.h"
/*PROTECTED REGION END*/
```

### Java 표준 패턴

```java
/*PROTECTED REGION ID(java_imports) ENABLED START*/
import java.util.ArrayList;
import org.json.JSONObject;
/*PROTECTED REGION END*/
```

## 안티패턴 (절대 하지 말 것)

### 1. Protected Region 외부 수정

```cpp
// ❌ 잘못됨 - 이 영역은 재생성 시 소실
#include <my_extra_lib.h>

/*PROTECTED REGION ID(includes) ENABLED START*/
// ✅ 올바름 - 여기에 include 추가
#include <my_extra_lib.h>
/*PROTECTED REGION END*/
```

### 2. Protected Region 경계 수정

```cpp
// ❌ 절대 금지 - 주석 자체를 수정하면 매칭 실패
/*PROTECTED REGION ID(my_custom_id) ENABLED START*/  // 이 줄 수정 금지
...
/*PROTECTED REGION END*/  // 이 줄도 수정 금지
```

### 3. Protected Region 중첩

```cpp
// ❌ 절대 금지 - 중첩 불가
/*PROTECTED REGION ID(outer) ENABLED START*/
    /*PROTECTED REGION ID(inner) ENABLED START*/  // 에러!
    /*PROTECTED REGION END*/
/*PROTECTED REGION END*/
```

### 4. ENABLED 키워드 누락 확인

```cpp
// ❌ ENABLED 없음 - 재생성 시 내용 소실
/*PROTECTED REGION ID(some_region) START*/
// 이 안의 코드는 보존되지 않음!
/*PROTECTED REGION END*/

// ✅ ENABLED 있음 - 재생성 시 보존
/*PROTECTED REGION ID(some_region) ENABLED START*/
// 이 안의 코드는 보존됨
/*PROTECTED REGION END*/
```

## 파일별 Protected Region 매핑

### Controller.cpp 일반 구조

```cpp
// 1. Include 영역
/*PROTECTED REGION ID({feature}_controller_cpp_includes) ENABLED START*/
/*PROTECTED REGION END*/

// 2. 전역/네임스페이스 영역
/*PROTECTED REGION ID({feature}_controller_cpp_globals) ENABLED START*/
/*PROTECTED REGION END*/

// 3. init() 본문
void Controller::init() {
    /*PROTECTED REGION ID({feature}_controller_init) ENABLED START*/
    /*PROTECTED REGION END*/
}

// 4. run() 본문
void Controller::run() {
    /*PROTECTED REGION ID({feature}_controller_run) ENABLED START*/
    /*PROTECTED REGION END*/
}

// 5. shutdown() 본문
void Controller::shutdown() {
    /*PROTECTED REGION ID({feature}_controller_shutdown) ENABLED START*/
    /*PROTECTED REGION END*/
}
```

### Controller.h 일반 구조

```cpp
// 멤버 변수 선언
/*PROTECTED REGION ID({feature}_controller_h_members) ENABLED START*/
WebSocketEndPoint* wsEndpoint;
bool isConnected;
double currentRate;
/*PROTECTED REGION END*/

// 메서드 선언
/*PROTECTED REGION ID({feature}_controller_h_methods) ENABLED START*/
void processData(double value);
void handleCommand(const std::string& cmd);
/*PROTECTED REGION END*/
```

## 새 파일 추가

Protected Region 시스템은 **Feature Designer가 관리하는 파일**에만 적용된다. 완전히 새로운 파일(예: `MyHelper.cpp`, `utils.h`)은 자유롭게 작성 가능하며 재생성 영향을 받지 않는다.

단, 새 파일을:
- Controller에서 사용하려면 Protected Region 안에서 `#include` 추가
- CMake에 등록하려면 `CMakeLists.txt`의 Protected Region에 추가 (또는 별도 CMake 파일로 분리)

## 안전한 작업 워크플로우

1. **수정 전**: `grep -rn "PROTECTED REGION" <file>` 로 Protected Region 위치 파악
2. **수정 중**: 항상 Protected Region 안에서 작업
3. **수정 후**: Feature Designer에서 재생성하여 코드가 보존되는지 확인
4. **팁**: 복잡한 로직은 별도 파일로 분리하고 Protected Region에서는 호출만
