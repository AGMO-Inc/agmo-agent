# H2 Console 접속 정보

| 항목 | 값 |
|------|------|
| URL | http://localhost:8082 |
| JDBC URL | jdbc:h2:./disk/{projName} |
| User | sa |
| Password | (빈칸) |

- DB 파일 경로: `{projName}/disk/{projName}.mv.db`
- 앱(port 1456)과 H2 Console은 동시 실행 불가 (파일 DB 잠금)
- H2 Console 종료 후 앱 재실행: 빌드 후 `java -jar` 실행
