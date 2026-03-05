# Service 클래스 템플릿

## Repository 패턴

모든 SQL 로직은 Repository에, Service는 요청 검증 + Repository 호출만 담당.

### Repository 템플릿

**파일**: `{projName}/src/com/bosch/nevonex/main/rest/{domain}/{Name}Repository.java`

```java
package com.bosch.nevonex.main.rest.{domain};

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class {Name}Repository {

	private final Connection conn;

	public {Name}Repository(Connection conn) {
		this.conn = conn;
	}

	public void insert(String id, String name, String createdAt) throws Exception {
		PreparedStatement ps = conn.prepareStatement(
			"INSERT INTO {table} (id, name, created_at) VALUES (?, ?, ?)"
		);
		ps.setString(1, id);
		ps.setString(2, name);
		ps.setString(3, createdAt);
		ps.executeUpdate();
		ps.close();
	}

	public JsonArray findAll() throws Exception {
		Statement stmt = conn.createStatement();
		ResultSet rs = stmt.executeQuery("SELECT id, name, created_at FROM {table}");
		JsonArray contents = new JsonArray();
		while (rs.next()) {
			JsonObject obj = new JsonObject();
			obj.addProperty("id", rs.getString("id"));
			obj.addProperty("name", rs.getString("name"));
			obj.addProperty("createdAt", rs.getString("created_at"));
			contents.add(obj);
		}
		rs.close();
		stmt.close();
		return contents;
	}

	public int update(String id, String name, String updatedAt) throws Exception {
		PreparedStatement ps = conn.prepareStatement(
			"UPDATE {table} SET name=?, created_at=? WHERE id=?"
		);
		ps.setString(1, name);
		ps.setString(2, updatedAt);
		ps.setString(3, id);
		int updated = ps.executeUpdate();
		ps.close();
		return updated;
	}

	public int deleteByIds(JsonArray ids) throws Exception {
		int deletedCount = 0;
		PreparedStatement ps = conn.prepareStatement("DELETE FROM {table} WHERE id = ?");
		for (int i = 0; i < ids.size(); i++) {
			ps.setString(1, ids.get(i).getAsString());
			deletedCount += ps.executeUpdate();
		}
		ps.close();
		return deletedCount;
	}
}
```

### Service 템플릿

**파일**: `{projName}/src/com/bosch/nevonex/main/rest/{domain}/{Name}Service.java`

예시: `POST MachineModel` → `rest/machinemodel/MachineModelService.java`

```java
package com.bosch.nevonex.main.rest.{domain};

import com.bosch.fsp.logger.FCALLogs;

import com.bosch.nevonex.main.rest.BaseRestService;

import com.google.gson.JsonObject;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.commons.lang3.exception.ExceptionUtils;

import spark.Request;
import spark.Response;

public class {Name}Service extends BaseRestService {

	@Override
	protected Object processService(Request request, Response response) {
		try {
			JsonObject payload = parseBody(request);
			if (payload == null) {
				return errorResponse("Request body is empty");
			}

			// TODO: 필수 필드 검증
			// if (!payload.has("name")) {
			//     return errorResponse("Missing required field: name");
			// }

			String id = String.valueOf(System.currentTimeMillis());
			String createdAt = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").format(new Date());

			{Name}Repository repo = new {Name}Repository(getDbConnection());
			repo.insert(id, payload.get("name").getAsString(), createdAt);

			return successResponse(id);

		} catch (Exception e) {
			FCALLogs.getInstance().log.error(ExceptionUtils.getRootCauseMessage(e));
			return errorResponse(e.getMessage());
		}
	}
}
```

## BaseRestService 제공 유틸

- `parseBody(request)` → `JsonObject` (body 파싱)
- `getDbConnection()` → `Connection` (H2 DB 커넥션 — Repository 생성자에 전달)
- `successResponse(id)` → `{"status":"success","id":"..."}`
- `errorResponse(message)` → `{"status":"error","message":"..."}`
- `gson` → 공유 Gson 인스턴스
- `controller` + getter/setter → Agnote 컨트롤러 참조

## CRUD 패턴 (Repository 내부)

### GET (전체 조회) — Repository.findAll()
```java
public JsonArray findAll() throws Exception {
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT id, name, created_at FROM {table}");
    JsonArray contents = new JsonArray();
    while (rs.next()) {
        JsonObject obj = new JsonObject();
        obj.addProperty("id", rs.getString("id"));
        obj.addProperty("name", rs.getString("name"));
        contents.add(obj);
    }
    rs.close(); stmt.close();
    return contents;
}
```

### GET (전체 조회) — Service에서 호출
```java
{Name}Repository repo = new {Name}Repository(getDbConnection());
JsonObject result = new JsonObject();
result.add("contents", repo.findAll());
return result.toString();
```

### PUT (수정) — Repository.update()
```java
public int update(String id, String name, String updatedAt) throws Exception {
    PreparedStatement ps = conn.prepareStatement(
        "UPDATE {table} SET name=?, created_at=? WHERE id=?"
    );
    ps.setString(1, name);
    ps.setString(2, updatedAt);
    ps.setString(3, id);
    int updated = ps.executeUpdate();
    ps.close();
    return updated;
}
```

### PUT (수정) — Service에서 호출
```java
{Name}Repository repo = new {Name}Repository(getDbConnection());
int updated = repo.update(id, payload);
if (updated == 0) return errorResponse("{Name} not found: " + id);
return successResponse(id);
```

### DELETE (bulk 삭제) — Repository.deleteByIds()
```java
public int deleteByIds(JsonArray ids) throws Exception {
    int deletedCount = 0;
    PreparedStatement ps = conn.prepareStatement("DELETE FROM {table} WHERE id = ?");
    for (int i = 0; i < ids.size(); i++) {
        ps.setString(1, ids.get(i).getAsString());
        deletedCount += ps.executeUpdate();
    }
    ps.close();
    return deletedCount;
}
```

### DELETE (bulk 삭제) — Service에서 호출
```java
{Name}Repository repo = new {Name}Repository(getDbConnection());
int deletedCount = repo.deleteByIds(idsArray);
```

## 크로스 도메인 JOIN

다른 도메인의 데이터가 필요하면 해당 Repository를 import하여 호출:

```java
// WorkLogGetByIdService.java
Connection conn = getDbConnection();
OperatorRepository operatorRepo = new OperatorRepository(conn);
result.add("operator", operatorRepo.findById(operatorId));

CropRepository cropRepo = new CropRepository(conn);
result.add("crops", cropRepo.findByIds(cropIds));
```

## 주의사항

- Service에 SQL을 직접 작성하지 않음 — 모든 SQL은 Repository에 위치
- Repository 생성자에 `getDbConnection()` 전달 (`new {Name}Repository(getDbConnection())`)
- Repository 메서드는 `throws Exception` 선언, Service의 catch 블록에서 처리
- `PreparedStatement`로 SQL Injection 방지 (필수)
- ResultSet, PreparedStatement는 사용 후 `close()` 호출
- 테이블 스키마는 `DatabaseManager.java`의 `createTables()`에 정의
- 복합 JSON 필드(배열, 중첩 객체)는 TEXT/CLOB 컬럼에 JSON 문자열로 저장
