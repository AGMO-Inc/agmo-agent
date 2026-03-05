# Cloud Upload Service 템플릿

## 파일 위치

`{projName}/src/com/bosch/nevonex/main/rest/{domain}/{Name}CloudUploadService.java`

## 템플릿

```java
package com.bosch.nevonex.main.rest.{domain};

import com.bosch.nevonex.cloud.impl.Cloud;
import com.bosch.nevonex.common.ConnectionTypeEnum;
import com.bosch.fsp.runtime.feature.exception.CloudBadRequestException;
import com.bosch.fsp.runtime.feature.exception.CloudUnAuthorizedException;
import com.bosch.fsp.runtime.feature.exception.CloudAccessDeniedException;
import com.bosch.fsp.runtime.feature.exception.CloudConnectionException;
import com.bosch.fsp.runtime.feature.exception.PlatformServiceException;
import com.bosch.nevonex.main.rest.BaseRestService;
import com.google.gson.JsonObject;
import spark.Request;
import spark.Response;
import com.bosch.fsp.logger.FCALLogs;
import org.apache.commons.lang3.exception.ExceptionUtils;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.UUID;

public class {Name}CloudUploadService extends BaseRestService {

    private String createCorrelationId() {
        return UUID.randomUUID().toString();
    }

    @Override
    protected Object processService(Request request, Response response) {
        try {
            JsonObject payload = parseBody(request);
            if (payload == null) {
                return errorResponse("Request body is empty");
            }

            // 필수: externalUrl
            if (!payload.has("externalUrl") || payload.get("externalUrl").getAsString().isEmpty()) {
                return errorResponse("'externalUrl' field is required");
            }
            String externalUrl = payload.get("externalUrl").getAsString();

            // 필수: method (POST or GET)
            if (!payload.has("method") || payload.get("method").getAsString().isEmpty()) {
                return errorResponse("'method' field is required (POST or GET)");
            }
            String method = payload.get("method").getAsString().toUpperCase();
            if (!method.equals("POST") && !method.equals("GET")) {
                return errorResponse("'method' must be POST or GET");
            }

            // 선택: header (JSON object)
            JsonObject header = payload.has("header") && payload.get("header").isJsonObject()
                ? payload.get("header").getAsJsonObject() : new JsonObject();

            // 선택: msg (String)
            String msg = payload.has("msg") ? payload.get("msg").getAsString() : "";

            // Cloud 업로드용 JSON 조합
            // correlation-id: 요청 고유키. CloudDownloadListener에서 응답 수신 시 이 값으로 요청-응답을 매칭한다.
            String correlationId = createCorrelationId();
            JsonObject requestJson = new JsonObject();
            requestJson.addProperty("correlation-id", correlationId);
            requestJson.addProperty("externalUrl", externalUrl);
            requestJson.addProperty("method", method);
            requestJson.add("header", header);
            requestJson.addProperty("msg", msg);

            String data = requestJson.toString();

            // 선택: priority (기본값 2 = Medium)
            int priority = payload.has("priority")
                ? payload.get("priority").getAsInt() : 2;

            // 선택: connectionType (기본값 WIFI)
            ConnectionTypeEnum connectionType = ConnectionTypeEnum.WIFI;
            if (payload.has("connectionType")) {
                String typeStr = payload.get("connectionType").getAsString();
                ConnectionTypeEnum parsed = ConnectionTypeEnum.get(typeStr);
                if (parsed == null) {
                    return errorResponse("Invalid connectionType: " + typeStr + ". Use WIFI or SATELLITE");
                }
                connectionType = parsed;
            }

            // Cloud 업로드 실행
            String result = Cloud.getInstance()
                .uploadData(data, priority, connectionType);

            // 성공 응답 (correlationId를 반환하여 클라이언트가 리스너 응답과 매칭 가능)
            JsonObject res = new JsonObject();
            res.addProperty("status", "success");
            res.addProperty("correlationId", correlationId);
            res.addProperty("response", result);
            return res.toString();

        } catch (CloudBadRequestException e) {
            FCALLogs.getInstance().log.error("Cloud bad request: " + e.getMessage());
            return errorResponse("Cloud bad request: " + e.getMessage());
        } catch (CloudUnAuthorizedException e) {
            FCALLogs.getInstance().log.error("Cloud unauthorized: " + e.getMessage());
            return errorResponse("Cloud unauthorized: " + e.getMessage());
        } catch (CloudAccessDeniedException e) {
            FCALLogs.getInstance().log.error("Cloud access denied: " + e.getMessage());
            return errorResponse("Cloud access denied: " + e.getMessage());
        } catch (CloudConnectionException e) {
            FCALLogs.getInstance().log.error("Cloud connection failed: " + e.getMessage());
            return errorResponse("Cloud connection failed: " + e.getMessage());
        } catch (PlatformServiceException e) {
            FCALLogs.getInstance().log.error("Platform service error: " + e.getMessage());
            return errorResponse("Platform service error: " + e.getMessage());
        } catch (FileNotFoundException | IOException e) {
            FCALLogs.getInstance().log.error("IO error: " + e.getMessage());
            return errorResponse("IO error: " + e.getMessage());
        } catch (Exception e) {
            FCALLogs.getInstance().log.error(ExceptionUtils.getRootCauseMessage(e));
            return errorResponse(e.getMessage());
        }
    }
}
```

## uploadData에 전달되는 data JSON 구조

```json
{
  "correlation-id": "550e8400-e29b-41d4-a716-446655440000",
  "externalUrl": "https://api.example.com/data",
  "method": "POST",
  "header": { "Authorization": "Bearer token123" },
  "msg": "{\"key\": \"value\"}"
}
```

- `correlation-id`: UUID v4 랜덤 문자열. CloudDownloadListener에서 응답 수신 시 이 값으로 요청-응답을 식별하는 고유키
- `externalUrl`: 외부 API 서버 URL
- `method`: HTTP 메서드 (POST 또는 GET)
- `header`: 외부 API 요청 시 포함할 헤더 (JSON object)
- `msg`: 외부 API 요청 본문 (String)
