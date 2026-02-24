---
name: fdk-external-api
description: "(feature - Skill) NEVONEX FDK External API 호출 가이드. Cloud 프록시를 경유해 외부 REST API(HTTP)를 호출하는 패턴을 다룬다. Feature에서 직접 인터넷 접근이 불가하므로, Cloud::uploadData()로 요청을 전송하고 CloudDownloadListener에서 비동기 응답을 수신하는 구조이다. '외부 API 호출', 'External API', 'HTTP 요청', 'Cloud 프록시', '이메일 전송', '외부 서버 통신', 'REST 호출', 'correlation-id' 같은 요청에서 사용한다."
---

# FDK External API

## Overview

NEVONEX Feature는 CCU 내부에서 실행되어 **인터넷에 직접 접근할 수 없다**. 외부 REST API를 호출하려면 Cloud 프록시를 경유해야 한다.

```
Feature(CCU) --uploadData()--> NEVONEX Cloud --HTTP--> External Server
Feature(CCU) <--handleMessage()-- NEVONEX Cloud <--HTTP-- External Server
```

## 요청 전송 패턴

### 1. Adapter 클래스 구성

외부 API 호출을 담당하는 Adapter를 커스텀 코드로 분리한다:

```cpp
/**
 * @file ExternalApiAdapter.hpp
 * @author <작성자명>
 * @brief Cloud 프록시 경유 외부 API 호출 어댑터
 */

#pragma once
#include <json/json.h>
#include <string>

namespace AppMain {
namespace Adapter {

class ExternalApiAdapter {
public:
    ExternalApiAdapter();

    /**
     * Cloud 프록시를 통해 외부 API로 요청 전송
     * @param externalUrl 외부 API URL (https://...)
     * @param method HTTP 메서드 (GET, POST, PUT, DELETE)
     * @param header 요청 헤더 (Json::objectValue)
     * @param msg 요청 본문 (Json::objectValue)
     * @return true=Cloud 업로드 성공, false=업로드 실패
     */
    bool send(const std::string& externalUrl,
             const std::string& method,
             const Json::Value& header,
             const Json::Value& msg);

private:
    std::string createCorrelationId() const;
};

} // namespace Adapter
} // namespace AppMain
```

### 2. 요청 JSON 구조

Cloud에 업로드하는 JSON은 다음 표준 구조를 따른다:

```cpp
Json::Value requestJson(Json::objectValue);
requestJson["correlation-id"] = createCorrelationId();
requestJson["externalUrl"]    = externalUrl;
requestJson["method"]         = method;     // "POST", "GET", etc.
requestJson["header"]         = header;     // Json::objectValue
requestJson["msg"]            = msg;         // Json::objectValue (본문)

Json::StreamWriterBuilder writerBuilder;
writerBuilder["indentation"] = "";
std::string jsonStr = Json::writeString(writerBuilder, requestJson);

::nevonex::cloud::Cloud::getInstance()->uploadData(jsonStr, 1);
```

### 3. Correlation ID

비동기 요청/응답 매칭을 위한 고유 ID:

```cpp
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_generators.hpp>
#include <boost/uuid/uuid_io.hpp>

std::string ExternalApiAdapter::createCorrelationId() const {
    boost::uuids::uuid uuid = boost::uuids::random_generator()();
    return "EXT_" + boost::uuids::to_string(uuid);
}
```

- 접두사(`EXT_`)는 프로젝트 규약으로 통일
- UUID v4 기반으로 충돌 없는 고유 ID 보장

## 비동기 응답 수신

### CloudDownloadListener에서 응답 처리

외부 서버의 응답은 Cloud를 거쳐 `CloudDownloadListener::handleMessage()`로 전달된다:

```cpp
void CloudDownloadListener::handleMessage(const std::string& _content) {
    /*PROTECTED REGION ID(CloudDownloadListener_handleMessage) ENABLED START*/
    NEVONEX_LOG(SeverityLevel::info) << "Cloud Message: " << _content;
    if (!Utils::Util::convertStringToJson(_content, apiResponse)) {
        NEVONEX_LOG(SeverityLevel::warning) << "Cloud response is not valid JSON.";
        return;
    }

    // apiResponse 구조는 외부 서버 응답에 따라 다름 — 프로젝트에 맞게 파싱/디스패치 구현
    // 예: type 필드로 분기, correlation-id로 요청과 매칭 등
    /*PROTECTED REGION END*/
}
```

### 응답 처리 흐름

```
1. Cloud::uploadData(requestJson)  → 외부 서버로 전송
2. 외부 서버 처리 후 응답 반환       → NEVONEX Cloud 수신
3. CloudDownloadListener::handleMessage(response)  → Feature 수신
4. type 기반 디스패치 → Controller의 핸들러 메서드 호출
5. 핸들러에서 비즈니스 로직 처리 + UI 알림(WebSocket)
```

## 사용 지침

### 요청 전송 규칙

- **반환값 의미**: `send()` 반환값은 "Cloud 업로드 성공" 여부이지 "외부 API 응답 성공"이 아님
- **try/catch 필수**: `Cloud::getInstance()->uploadData()` 호출은 반드시 예외 처리
- **JSON 키 고정**: `correlation-id`, `externalUrl`, `method`, `header`, `msg` — 프로젝트 규약에 맞춰 일관성 유지
- **indentation 없이 직렬화**: `writerBuilder["indentation"] = ""` (네트워크 전송용)

### 응답 수신 규칙
- **파싱 후 구현**: `handleMessage()`에서 JSON 파싱까지는 공통이고, 그 이후 디스패치/비즈니스 로직은 프로젝트에서 구현
- **비동기 인지**: 요청과 응답이 시간적으로 분리됨 — 타임아웃/재시도 로직은 Controller에서 관리
- **UI 알림**: 응답 처리 후 WebSocket으로 UI에 결과 전달 (fdk-websocket 참조)

### Adapter 설계 규칙

- Controller에서 `std::shared_ptr<ExternalApiAdapter>`로 주입
- Adapter는 커스텀 코드 (Protected Region 없음, `@author` 필수)
- 하나의 Adapter로 여러 외부 API를 처리 (URL/method로 구분)