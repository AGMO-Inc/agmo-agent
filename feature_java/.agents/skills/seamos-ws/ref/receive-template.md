# WebSocket Receive/Handler 코드 템플릿

## `receive <controlId>` 코드

**파일**: `{projName}/src/com/bosch/nevonex/main/impl/UIWebsocketEndPoint.java`
**위치**: `message()` 메소드 내부, `FCALLogs.getInstance().log.debug(message);` 줄 이후

필요한 import 추가 (없는 경우):
```java
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
```

추가할 코드:

```java
JsonObject json = JsonParser.parseString(message).getAsJsonObject();
if (json.has("{controlId}")) {
    // Handle {controlId} from UI
    // Boolean 컨트롤: json.get("{controlId}").getAsString().equals("yes")
    // Number 컨트롤: json.get("{controlId}").getAsInt()
    // String 컨트롤: json.get("{controlId}").getAsString()
    // TODO: 수신된 값을 처리하는 로직 구현
}
```

**주의**: SEAMOS Custom UI의 Boolean 위젯은 `true`/`false`가 아닌 `"yes"`/`"no"` 문자열을 전송함.

## `handler` 전체 라우팅 구조

기존 `message()` 메소드를 전체 라우팅 구조로 교체:

```java
@OnWebSocketMessage
public void message(Session session, String message) throws IOException {
    if (GracefulFeatureStop.getInstance().isFeatureStopped()) {
        FCALLogs.getInstance().log
                .debug("The feature is going to be stopped, so HMI messages cannot be processed.");
        return;
    }
    FCALLogs.getInstance().log.debug(message);

    try {
        JsonObject json = JsonParser.parseString(message).getAsJsonObject();

        // TODO: 각 컨트롤 ID에 대한 핸들러 추가
        // 예시:
        // if (json.has("startButton")) {
        //     boolean start = json.get("startButton").getAsString().equals("yes");
        //     // 컨트롤러에 전달
        // } else if (json.has("speedSlider")) {
        //     int speed = json.get("speedSlider").getAsInt();
        //     // 컨트롤러에 전달
        // }

    } catch (Exception e) {
        FCALLogs.getInstance().log.error("Error parsing WebSocket message: " + e.getMessage());
    }
}
```

필요한 import:
```java
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
```
