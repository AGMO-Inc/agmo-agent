# ApplicationMain 등록 템플릿

## 대상 파일

`{projName}/src/com/bosch/nevonex/main/impl/ApplicationMain.java`

## 등록 위치

`addCustomUISupport()` 메서드 내, 기존 서비스 등록 코드 하단에 추가.

## import 추가

파일 상단 import 블록에 추가:

```java
import com.bosch.nevonex.main.rest.{domain}.{Name}CloudUploadService;
```

## 등록 코드

`addCustomUISupport()` 메서드 내부에 추가:

```java
// Cloud Upload - {Name}
{Name}CloudUploadService {name}CloudUploadService = new {Name}CloudUploadService();
{name}CloudUploadService.setController(controller);
UIWebServiceProvider.getInstance().registerPostService("cloud-upload/{route-path}", {name}CloudUploadService);
```

## 네이밍 예시

| Name | domain | route-path | 변수명 | 등록 경로 |
|------|--------|------------|--------|-----------|
| `GpsData` | `gpsdata` | `gps-data` | `gpsDataCloudUploadService` | `cloud-upload/gps-data` |
| `SensorReading` | `sensorreading` | `sensor-reading` | `sensorReadingCloudUploadService` | `cloud-upload/sensor-reading` |
| `WorkLog` | `worklog` | `work-log` | `workLogCloudUploadService` | `cloud-upload/work-log` |

## 참고

- 라우트 경로는 `cloud-upload/` 접두사를 사용하여 기존 REST 엔드포인트와 구분
- `setController(controller)`는 BaseRestService의 `IAgnote controller` 참조 설정
- 등록은 반드시 POST 메서드 (`registerPostService`)로 수행
