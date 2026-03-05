# Java → JSON Schema 타입 매핑

## 타입 매핑 테이블

| Java 타입 | JSON Schema `type` | `format` |
|-----------|-------------------|----------|
| `String` | `string` | - |
| `int` | `integer` | `int32` |
| `long` | `integer` | `int64` |
| `double` | `number` | `double` |
| `float` | `number` | `float` |
| `boolean` | `boolean` | - |

## 특수 필드 감지

- 필드명에 `image`, `base64`, `photo` 포함 시 → `format: "byte"` (base64 encoded)
- 필드명이 `id` → `description: "Auto-generated unique identifier"`
- 필드명이 `createdAt` → `format: "date-time"`
