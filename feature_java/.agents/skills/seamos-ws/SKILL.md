---
name: seamos-ws
description: SEAMOS WebSocket 통신 코드 생성기 (send/receive/handler)
triggers:
  - websocket
  - ws
  - broadcastMessage
  - ws send
  - ws receive
  - ws handler
argument-hint: "help | send <dataName> | receive <controlId> | handler"
aliases: [ws-gen, seamos-websocket]
quality: high
model: sonnet
context: fork
agent: seamos-dev
---

# SEAMOS WebSocket Code Generator

> **Agent 위임**: 이 스킬의 모든 작업은 Agent 도구를 사용하여 `seamos-dev` 에이전트에게 위임하여 실행할 것. Agent 호출 시 사용자의 요청 내용과 파싱된 인자를 프롬프트로 전달한다.

SEAMOS/NEVONEX 플랫폼의 WebSocket 통신 보일러플레이트 코드를 자동 생성하는 스킬.

## When to Activate

- 사용자가 WebSocket 메시지 송/수신 코드를 작성해야 할 때
- "websocket", "ws", "broadcastMessage" 등의 키워드 감지 시
- **키워드 "websocket" 또는 "ws"가 사용자 메시지에 포함되면 즉시 이 스킬을 발동할 것**

## Arguments Parsing

| 인자 패턴 | 동작 |
|-----------|------|
| `help` | 사용법 안내 출력 |
| `send <dataName>` | Agnote.run()에 broadcastMessage 코드 추가 |
| `receive <controlId>` | UIWebsocketEndPoint.message()에 수신 핸들러 추가 |
| `handler` | 전체 WebSocket 메시지 라우팅 구조 생성 |

---

## help 명령어

`help`가 인자일 때 아래 내용을 사용자에게 출력:

```
SEAMOS WebSocket Skill (/seamos-ws)

사용법:
  /seamos-ws help                          - 이 도움말 표시
  /seamos-ws send <dataName>               - WebSocket 데이터 전송 코드 생성
  /seamos-ws receive <controlId>           - WebSocket 수신 핸들러 추가
  /seamos-ws handler                       - 전체 WebSocket 메시지 라우터 생성

대상 파일:
  송신: {projName}/src/com/bosch/nevonex/main/impl/Agnote.java → run() 메소드
  수신: {projName}/src/com/bosch/nevonex/main/impl/UIWebsocketEndPoint.java → message() 메소드

주의사항:
  - WebSocket 메시지는 JSON 형식 (key=위젯ID, value=데이터)
  - Boolean 위젯은 "yes"/"no" 문자열 전송 (true/false 아님)
  - broadcastMessage는 연결된 모든 클라이언트에 전송됨
```

---

## WebSocket Code Generation

### 공통 정보

- **WebSocket 엔드포인트**: `UIWebsocketEndPoint.java` (싱글톤, `@WebSocket`)
- **경로**: `ws://host:1456/socket`
- **송신**: `wsEndPoint.broadcastMessage(String jsonString)`
- **수신**: `@OnWebSocketMessage public void message(Session session, String message)`
- **JSON**: Gson (`JsonObject`, `JsonArray`, `JsonParser`)
- **메시지 포맷**: JSON 객체, key=위젯/컨트롤 ID, value=데이터

### `send <dataName>` 실행 시

> 📎 send 코드 템플릿(단일값, GPS, 배열)은 `.claude/skills/seamos-ws/ref/send-template.md` 를 Read하여 참조할 것

### `receive <controlId>` 및 `handler` 실행 시

> 📎 receive/handler 코드 템플릿은 `.claude/skills/seamos-ws/ref/receive-template.md` 를 Read하여 참조할 것

### Framework Reference (필요 시)


---

## Notes

- WebSocket 브로드캐스트는 연결된 **모든** 클라이언트에 전송됨.
- `GracefulFeatureStop` 체크는 모든 메시지 핸들러에서 수행해야 함.
- EMF 등록은 이 스킬의 범위 밖임.
