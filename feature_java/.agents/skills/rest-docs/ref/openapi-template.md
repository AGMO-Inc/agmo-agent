# OpenAPI 3.0 JSON 템플릿

## 기본 구조

```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "{projName} REST API",
    "version": "1.0.0",
    "description": "Auto-generated SEAMOS REST API documentation"
  },
  "servers": [
    {
      "url": "http://localhost:{port}",
      "description": "Local development server"
    }
  ],
  "paths": {},
  "components": {
    "schemas": {}
  }
}
```

## Method별 paths 생성 규칙

### GET (조회)

```json
{
  "summary": "{Name} 리스트 조회",
  "operationId": "get{Name}List",
  "responses": {
    "200": {
      "description": "Success",
      "content": {
        "application/json": {
          "schema": {
            "type": "object",
            "properties": {
              "contents": {
                "type": "array",
                "items": { "$ref": "#/components/schemas/{Name}Entity" }
              }
            }
          }
        }
      }
    }
  }
}
```

### POST (생성)

```json
{
  "summary": "{Name} 생성",
  "operationId": "create{Name}",
  "requestBody": {
    "required": true,
    "content": {
      "application/json": {
        "schema": {
          "type": "object",
          "required": ["{REQUIRED_FIELDS 배열}"],
          "properties": {
            "{각 필드}": { "type": "{매핑된 타입}" }
          }
        }
      }
    }
  },
  "responses": {
    "200": {
      "description": "Success",
      "content": {
        "application/json": {
          "schema": { "$ref": "#/components/schemas/SuccessResponse" }
        }
      }
    },
    "400": {
      "description": "Validation error",
      "content": {
        "application/json": {
          "schema": { "$ref": "#/components/schemas/ErrorResponse" }
        }
      }
    }
  }
}
```

### PUT (수정)

```json
{
  "summary": "{Name} 수정",
  "operationId": "update{Name}",
  "parameters": [
    {
      "name": "id",
      "in": "path",
      "required": true,
      "schema": { "type": "string" },
      "description": "대상 리소스 ID"
    }
  ],
  "requestBody": {
    "required": true,
    "content": {
      "application/json": {
        "schema": {
          "type": "object",
          "required": ["{REQUIRED_FIELDS 배열 - id 제외}"],
          "properties": {
            "{각 필드 - id/createdAt 제외}": { "type": "{매핑된 타입}" }
          }
        }
      }
    }
  },
  "responses": {
    "200": {
      "description": "Success",
      "content": {
        "application/json": {
          "schema": { "$ref": "#/components/schemas/SuccessResponse" }
        }
      }
    },
    "400": {
      "description": "Validation error or not found",
      "content": {
        "application/json": {
          "schema": { "$ref": "#/components/schemas/ErrorResponse" }
        }
      }
    }
  }
}
```

### DELETE (삭제)

```json
{
  "summary": "{Name} 삭제",
  "operationId": "delete{Name}",
  "requestBody": {
    "required": true,
    "content": {
      "application/json": {
        "schema": {
          "type": "object",
          "required": ["ids"],
          "properties": {
            "ids": {
              "type": "array",
              "items": { "type": "string" },
              "description": "삭제할 리소스 ID 배열"
            }
          }
        }
      }
    }
  },
  "responses": {
    "200": {
      "description": "Success",
      "content": {
        "application/json": {
          "schema": {
            "type": "object",
            "properties": {
              "status": { "type": "string", "example": "success" },
              "deletedCount": { "type": "integer", "description": "삭제된 항목 수" }
            }
          }
        }
      }
    }
  }
}
```

## 공통 schemas (components/schemas에 항상 포함)

```json
{
  "SuccessResponse": {
    "type": "object",
    "properties": {
      "status": { "type": "string", "example": "success" },
      "id": { "type": "string", "description": "생성/수정된 리소스 ID" }
    }
  },
  "ErrorResponse": {
    "type": "object",
    "properties": {
      "status": { "type": "string", "example": "error" },
      "message": { "type": "string", "description": "에러 메시지" }
    }
  }
}
```

## Entity schema 생성 규칙

Entity 클래스의 모든 private 필드를 순회하여 schema 생성:

```json
{
  "{Name}Entity": {
    "type": "object",
    "properties": {
      "id": { "type": "string", "description": "Auto-generated unique identifier" },
      "{fieldName}": { "type": "{매핑된 타입}", "format": "{해당시}" },
      "createdAt": { "type": "string", "format": "date-time" }
    }
  }
}
```
