# ApplicationMain 등록 코드 템플릿

**파일**: `{projName}/src/com/bosch/nevonex/main/impl/ApplicationMain.java`
**위치**: `addCustomUISupport()` 메소드 내부, CORS 설정 이후에 추가

## import 추가

```java
import com.bosch.nevonex.main.rest.{domain}.{Name}Service;
```

## 등록 코드

```java
// {Name}
{Name}Service {name}Service = new {Name}Service();
{name}Service.setController(controller);
UIWebServiceProvider.getInstance().register{Method}Service("{route-path}", {name}Service);
```

## 등록 메소드 매핑

| HTTP Method | 등록 메소드 |
|-------------|-----------|
| GET | `UIWebServiceProvider.getInstance().registerGetService("route-path", service)` |
| POST | `UIWebServiceProvider.getInstance().registerPostService("route-path", service)` |
| PUT | `UIWebServiceProvider.getInstance().registerPutService("route-path", service)` |
| DELETE | `UIWebServiceProvider.getInstance().registerDeleteService("route-path", service)` |
