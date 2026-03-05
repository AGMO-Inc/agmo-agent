# curl 테스트 마크다운 출력 포맷

## 마크다운 템플릿

```markdown
# {Domain Name} REST API 테스트

> Base URL: `http://localhost:1456`

---

## {METHOD} `/{route-path}` — {설명}

\```bash
curl -X {METHOD} http://localhost:1456/{route-path} \
  -H "Content-Type: application/json" \
  -d '{
    {샘플 JSON body}
  }'
\```

**성공 응답:**
\```json
{성공 응답 예시}
\```

**실패 응답 ({실패 케이스}):**
\```json
{실패 응답 예시}
\```

---
```

## HTTP Method별 curl 생성 규칙

| Method | Body | Path Param | 샘플 구조 |
|--------|------|-----------|----------|
| GET | 없음 | 없음 | `curl -X GET {url}` |
| POST | 있음 | 없음 | `curl -X POST {url} -H ... -d '{body}'` |
| PUT | 있음 | `:id` 가능 | `curl -X PUT {url}/{id} -H ... -d '{body}'` |
| DELETE | 있음 | 없음 | `curl -X DELETE {url} -H ... -d '{body}'` |

## 샘플 데이터 생성 규칙

Entity 필드 타입에 따라 샘플 값을 생성:

| Java 타입 | 샘플 값 |
|-----------|---------|
| `String` | 도메인에 맞는 한글 샘플 텍스트 |
| `String` (image/base64) | `"base64encodedstring"` |
| `int` | 도메인 맥락에 맞는 정수값 |
| `double` | 도메인 맥락에 맞는 소수값 |
| `boolean` | `true` |

## 응답 패턴

각 엔드포인트의 응답 패턴:

**POST (생성):**
- 성공: `{"status": "success", "id": "{timestamp}"}`
- 실패: `{"status": "error", "message": "Missing required field: {field}"}`

**GET (조회):**
- 성공: `{"contents": [{entity 배열}]}`
- 빈 데이터: `{"contents": []}`

**PUT (수정):**
- 성공: `{"status": "success", "id": "{id}"}`
- 실패 (미존재): `{"status": "error", "message": "{Entity} not found: {id}"}`
- 실패 (필드 누락): `{"status": "error", "message": "Missing required field: {field}"}`

**DELETE (삭제):**
- 성공: `{"status": "success", "deletedCount": {N}}`
- 실패 (ids 누락): `{"status": "error", "message": "Missing required field: ids"}`
