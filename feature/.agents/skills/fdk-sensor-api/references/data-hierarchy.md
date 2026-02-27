# Implement 데이터 계층 상세

## 전체 데이터 구조

### Implement (최상위)

| 속성 | 타입 | R/W | 설명 |
|------|------|-----|------|
| `getActualWorkingSpeed()` | double | R | 실제 작업 속도 (m/s) |
| `getMaximumWorkingWidth()` | double | R/W | 최대 작업 폭 (m) |
| `getFuelConsumption()` | double | R | 연료 소비량 |
| `getActualWorkState()` | enum | R | 현재 작업 상태 |
| `getBoom(index)` | Boom* | R | Boom 객체 접근 |
| `getBulkProcessor()` | BulkProcessor* | R | 일괄 처리기 |

### Boom

| 속성 | 타입 | R/W | 설명 |
|------|------|-----|------|
| `getSection(index)` | Section* | R | Section 접근 |
| `getChannel(index)` | Channel* | R | Channel 직접 접근 |
| `getActualApplicationRate()` | double | R | Boom 전체 살포율 |
| `getSetpointApplicationRate()` | double | R/W | 목표 살포율 |

### Section

| 속성 | 타입 | R/W | 설명 |
|------|------|-----|------|
| `getChannel(index)` | Channel* | R | Channel 접근 |
| `getSectionState()` | enum | R | 섹션 활성/비활성 |

### Channel

| 속성 | 타입 | R/W | 설명 |
|------|------|-----|------|
| `getActualApplicationRate()` | ValueWrapper | R | 실제 살포율 |
| `setSetpointApplicationRate(v)` | void | W | 목표 살포율 설정 |
| `getActualWorkingWidth()` | ValueWrapper | R | 실제 작업 폭 |
| `getSubChannel(index)` | SubChannel* | R | SubChannel 접근 |
| `getActualApplicationVolume()` | ValueWrapper | R | 실제 살포량 |
| `getTotalApplicationVolume()` | ValueWrapper | R | 누적 살포량 |

### SubChannel

Channel과 동일한 API 구조를 가지며, 더 세밀한 제어 단위를 나타낸다.

## ValueWrapper 패턴

센서 값은 raw value가 아닌 `ValueWrapper` 객체로 반환된다:

```cpp
auto wrapper = channel->getActualApplicationRate();

// 유효성 체크 (필수)
bool valid = wrapper.is_Valid();

// 값 획득
double value = wrapper.getValue();

// 타임스탬프 (마지막 갱신 시각, epoch ms)
uint64_t ts = wrapper.getValue_Timestamp();
```

### 유효하지 않은 값의 원인

- 센서 미연결
- 초기화 중 (아직 첫 번째 값 수신 전)
- 통신 에러
- 해당 채널이 모델에 정의되지 않음

## Java API 대응표

### Implement

```java
// Provider 획득
IImplementProvider implementProvider = NEVONEXApplication.getInstance().getImplementProvider();

// Boom 접근
IBoom boom = implementProvider.getBoom(0);

// Machine 데이터
double speed = implementProvider.getActualWorkingSpeed().getValue();
```

### Boom/Channel

```java
IBoom boom = implementProvider.getBoom(0);
IChannel channel = boom.getChannel(0);

// 읽기
double rate = channel.getActualApplicationRate().getValue();
boolean valid = channel.getActualApplicationRate().isValid();

// 쓰기
channel.setSetpointApplicationRate(25.5);
```

### BulkProcessor (Java)

```java
BulkProcessor bulkProcessor = implementProvider.getBulkProcessor();
bulkProcessor.setSetpointApplicationRate(0, 0, 25.5);  // boom, channel, value
bulkProcessor.setSetpointApplicationRate(0, 1, 30.0);
bulkProcessor.executeBulkOperations();
```

### 로깅 (Java)

```java
FCALLogs.getInstance().log.info("Rate: " + rate);
FCALLogs.getInstance().log.debug("Debug message");
FCALLogs.getInstance().log.warning("Warning message");
FCALLogs.getInstance().log.fatal("Fatal error: " + error);
```

## 인덱스 범위

- Boom, Section, Channel, SubChannel의 인덱스는 0부터 시작
- 사용 가능한 인덱스 범위는 Feature Designer의 `.fpd` 모델에서 정의
- 범위 밖 인덱스 접근 시 null/nullptr 반환 → null 체크 필수
