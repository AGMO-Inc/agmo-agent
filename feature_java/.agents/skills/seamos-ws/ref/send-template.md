# WebSocket Send 코드 템플릿

**파일**: `{projName}/src/com/bosch/nevonex/main/impl/Agnote.java`
**위치**: `run()` 메소드 내부의 try 블록 안

필요한 import 추가 (없는 경우):
```java
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
```

## 단일 값 전송

```java
// Send {dataName} to UI
JsonObject {dataName}Object = new JsonObject();
{dataName}Object.addProperty("{dataName}", /* TODO: 전송할 값 */);
wsEndPoint.broadcastMessage({dataName}Object.toString());
```

## GPS 위치 데이터 전송 (dataName이 gps/location/position 관련일 때)

```java
// Send GPS data to UI
if (getGPSPlugin() != null) {
    JsonObject gpsObject = new JsonObject();
    gpsObject.addProperty("latitude", getGPSPlugin().getLatitude());
    gpsObject.addProperty("longitude", getGPSPlugin().getLongitude());
    gpsObject.addProperty("altitude", getGPSPlugin().getAltitude());
    gpsObject.addProperty("hdop", getGPSPlugin().getHDOP());
    gpsObject.addProperty("numSatellites", getGPSPlugin().getNumSatellites());
    gpsObject.addProperty("packetTime", getGPSPlugin().getPacketTime());
    wsEndPoint.broadcastMessage(gpsObject.toString());
}
```

## 배열/차트 데이터 전송

```java
// Send chart data to UI
JsonObject chartObject = new JsonObject();
JsonArray dataArray = new JsonArray();
dataArray.add(/* value1 */);
dataArray.add(/* value2 */);
dataArray.add(/* value3 */);
chartObject.add("{dataName}", dataArray);
wsEndPoint.broadcastMessage(chartObject.toString());
```
