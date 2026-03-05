# Entity 템플릿

**파일**: `{projName}/src/com/bosch/nevonex/main/rest/{domain}/{Name}Entity.java`

예시: `POST MachineModel` → `rest/machinemodel/MachineModelEntity.java`

```java
package com.bosch.nevonex.main.rest.{domain};

public class {Name}Entity {
	private String id;
	// TODO: payload 필드 추가 (타입에 맞게)
	private String createdAt;

	public {Name}Entity() {
	}

	// TODO: 각 필드의 getter/setter 추가

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(String createdAt) {
		this.createdAt = createdAt;
	}
}
```
