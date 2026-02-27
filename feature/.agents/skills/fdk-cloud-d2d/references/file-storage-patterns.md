# FileProvider & Agri-Router 상세

## FileProvider 패턴

### 카테고리 설계

카테고리는 논리적 폴더와 같다. 용도별로 분리하여 관리:

| 카테고리 | 용도 | 예시 파일 |
|----------|------|----------|
| `config` | 사용자 설정 | `settings.json`, `calibration.json` |
| `logs` | 세션 로그 | `session_20240101.csv` |
| `pending_upload` | 업로드 대기 | `data_1704067200.json` |
| `field_data` | 필드 데이터 | `field_001.geojson` |
| `cache` | 임시 캐시 | `last_state.json` |

### 설정 파일 관리

```cpp
// 설정 저장
void saveConfig(const Json::Value& config) {
    auto& fp = FileProvider::getInstance();
    fp.saveToDisk("config", "user_settings.json", config.toStyledString());
}

// 설정 로드 (init에서)
Json::Value loadConfig() {
    auto& fp = FileProvider::getInstance();
    try {
        auto content = fp.retrieveFromDisk("config", "user_settings.json");
        Json::Value config;
        Json::Reader reader;
        if (reader.parse(content, config)) {
            return config;
        }
    } catch (...) {
        NEVONEX_LOG(SeverityLevel::info) << "No saved config, using defaults";
    }
    return getDefaultConfig();
}
```

### 로그 관리

```cpp
class SessionLogger {
    std::stringstream buffer;
    std::string sessionId;

public:
    void start() {
        sessionId = generateSessionId();
        buffer.str("");
        buffer << "timestamp,rate,speed,lat,lng\n";
    }

    void log(double rate, double speed, double lat, double lng) {
        buffer << getCurrentTimestamp() << ","
               << rate << "," << speed << ","
               << lat << "," << lng << "\n";
    }

    void flush() {
        auto& fp = FileProvider::getInstance();
        fp.saveToDisk("logs", sessionId + ".csv", buffer.str());
        buffer.str("");
    }

    void stop() {
        flush();
    }
};
```

### 용량 관리

CCU 저장공간은 16GB eMMC를 OS/앱과 공유한다. 과도한 저장 방지:

```cpp
void cleanupOldLogs(int maxFiles = 50) {
    auto& fp = FileProvider::getInstance();
    auto files = fp.retrieveAllFilesFromDisk("logs");

    if (files.size() > maxFiles) {
        // 오래된 파일부터 삭제
        std::sort(files.begin(), files.end(),
            [](auto& a, auto& b) { return a.name < b.name; });

        int toDelete = files.size() - maxFiles;
        for (int i = 0; i < toDelete; i++) {
            fp.deleteFromDisk("logs", files[i].name);
        }
    }
}
```

## Agri-Router 연동

### 개요

Agri-Router는 농업 기계 간 데이터 교환 플랫폼이다. ISOXML, Shapefile, TaskData 등 농업 표준 포맷을 지원한다.

### 지원 파일 포맷

| 포맷 | MIME 타입 | 용도 |
|------|----------|------|
| ISOXML | `application/xml` | 작업 데이터 (Task/Prescription) |
| Shapefile | `application/zip` | 필드 경계, 처방 맵 |
| GPS Track | `application/gpx+xml` | 경로 기록 |
| 이미지 | `image/png`, `image/jpeg` | 필드 사진 |

### 업로드 흐름

```cpp
// 1. TaskData XML 생성
std::string taskData = generateISOXML(sessionData);

// 2. 로컬 저장 (백업)
FileProvider::getInstance().saveToDisk("agrirouter", "task_001.xml", taskData);

// 3. Agri-Router 업로드
uploadAgriRouterFile("task_001.xml", "application/xml");
```

### TMT (Task Management Transfer)

TMT는 Agri-Router를 통해 수신하는 작업 지시서다:

```cpp
// TMT 목록 조회
auto tmtList = getAgriRouterTMTList();

for (auto& tmt : tmtList) {
    NEVONEX_LOG(SeverityLevel::info) << "TMT: " << tmt.name;

    // TMT 다운로드 및 적용
    auto content = downloadAgriRouterTMT(tmt.id);
    if (tmt.type == "ISOXML") {
        parseAndApplyISOXML(content);
    }
}
```

### 오프라인 시 Agri-Router 데이터 처리

```cpp
void handleAgriRouterUpload(const std::string& fileName, const std::string& mimeType) {
    auto& fp = FileProvider::getInstance();

    try {
        uploadAgriRouterFile(fileName, mimeType);
        // 성공 시 pending에서 제거
        fp.deleteFromDisk("agrirouter_pending", fileName);
    } catch (...) {
        // 실패 시 pending에 저장
        auto content = fp.retrieveFromDisk("agrirouter", fileName);
        fp.saveToDisk("agrirouter_pending", fileName, content);
        NEVONEX_LOG(SeverityLevel::warning) << "Agri-Router upload queued: " << fileName;
    }
}
```
