# NMEA-0183 프로토콜 상세

## 문장 형식

NMEA-0183 문장의 일반 형식:

```
$TALKER_SENTENCE_ID,field1,field2,...*CHECKSUM\r\n
```

- `$`: 시작 문자
- Talker ID: 2글자 (GP=GPS, GL=GLONASS, GN=Combined)
- Sentence ID: 3글자 (GGA, GST, RMC 등)
- `*`: 체크섬 구분자
- Checksum: 2자리 16진수 (XOR)
- `\r\n`: 줄 끝

## GGA - 위치 정보

### 형식

```
$GPGGA,hhmmss.ss,llll.ll,a,yyyyy.yy,a,x,xx,x.x,x.x,M,x.x,M,x.x,xxxx*hh
```

### 필드 설명

| 필드 | 예시 | 설명 |
|------|------|------|
| 1 | `123519.00` | UTC 시간 (12:35:19.00) |
| 2 | `4807.038` | 위도 (48°07.038') |
| 3 | `N` | 위도 방향 (N/S) |
| 4 | `01131.000` | 경도 (11°31.000') |
| 5 | `E` | 경도 방향 (E/W) |
| 6 | `1` | Fix quality (0=없음, 1=GPS, 2=DGPS, 4=RTK Fixed, 5=RTK Float) |
| 7 | `08` | 추적 위성 수 |
| 8 | `0.9` | HDOP (수평 정밀도) |
| 9 | `545.4` | 고도 (미터, 해수면 기준) |
| 10 | `M` | 고도 단위 |
| 11 | `47.0` | 지오이드 높이 |
| 12 | `M` | 지오이드 단위 |
| 13 | | DGPS 업데이트 시간 (초) |
| 14 | | DGPS 기준국 ID |

### Fix Quality 값

| 값 | 의미 | 정밀도 |
|----|------|--------|
| 0 | Fix 없음 | - |
| 1 | GPS Fix | ~3-5m |
| 2 | DGPS Fix | ~1-3m |
| 4 | RTK Fixed | ~2cm |
| 5 | RTK Float | ~20cm |

## GST - 위치 오차 통계

### 형식

```
$GPGST,hhmmss.ss,x.x,x.x,x.x,x.x,x.x,x.x,x.x*hh
```

### 필드 설명

| 필드 | 설명 |
|------|------|
| 1 | UTC 시간 |
| 2 | RMS (전체 잔차의 표준편차) |
| 3 | 장반경 표준편차 (m) |
| 4 | 단반경 표준편차 (m) |
| 5 | 장반경 방위 (도) |
| 6 | 위도 표준편차 (m) |
| 7 | 경도 표준편차 (m) |
| 8 | 고도 표준편차 (m) |

## AGRICA - Bosch 독자 프로토콜

Bosch의 고정밀 위치/자세 정보를 포함하는 독자 문장. 표준 NMEA에는 포함되지 않으며, Bosch GNSS 수신기에서만 출력된다.

주요 정보:
- 고정밀 위도/경도 (RTK 보정 후)
- Roll/Pitch/Yaw (IMU 융합)
- 속도 벡터 (North/East/Down)
- 위치 정확도 지표

## 체크섬 계산

### 알고리즘

`$`와 `*` 사이 모든 문자의 XOR:

```cpp
uint8_t calculateNMEAChecksum(const std::string& sentence) {
    uint8_t checksum = 0;
    bool started = false;

    for (char c : sentence) {
        if (c == '$') {
            started = true;
            continue;
        }
        if (c == '*') {
            break;
        }
        if (started) {
            checksum ^= static_cast<uint8_t>(c);
        }
    }

    return checksum;
}

// 검증
bool verifyNMEAChecksum(const std::string& sentence) {
    size_t starPos = sentence.find('*');
    if (starPos == std::string::npos || starPos + 2 >= sentence.size()) {
        return false;
    }

    uint8_t calculated = calculateNMEAChecksum(sentence);
    uint8_t received = std::stoi(sentence.substr(starPos + 1, 2), nullptr, 16);

    return calculated == received;
}
```

### 예시

```
$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,47.0,M,,*47

체크섬 = 'G' ^ 'P' ^ 'G' ^ 'G' ^ 'A' ^ ',' ^ '1' ^ '2' ^ ... = 0x47
```

## 위도/경도 변환

### NMEA 형식 → Decimal Degrees

NMEA는 `ddmm.mmmm` (도분) 형식을 사용:

```cpp
double nmeaToDecimalDegrees(double nmeaValue, char direction) {
    int degrees = static_cast<int>(nmeaValue / 100);
    double minutes = nmeaValue - (degrees * 100);
    double decimal = degrees + (minutes / 60.0);

    if (direction == 'S' || direction == 'W') {
        decimal = -decimal;
    }

    return decimal;
}

// 예: 4807.038, N → 48.1173°
// degrees = 48, minutes = 7.038
// decimal = 48 + 7.038/60 = 48.1173
```
