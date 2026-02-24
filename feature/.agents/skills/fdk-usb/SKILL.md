---
name: fdk-usb
description: "(feature - Skill) NEVONEX FDK USB API 가이드. CCU에 연결된 USB 드라이브와 파일을 교환하는 API를 다룬다. FEU→USB 파일 복사, USB→FEU 파일 복사, USB 디렉토리 트리 조회, 디렉토리 생성/이름변경, OTG 드라이브 마운트/언마운트를 구현할 때 사용한다. 'USB 파일 복사', 'USB 읽기/쓰기', 'USB 마운트', 'OTG 드라이브', 'USB 디렉토리', 'USB 파일 전송', 'FEU에서 USB로' 같은 요청에서 사용한다."
---

# FDK USB API

## Overview

USB API를 사용하면 Feature(FEU)와 USB 드라이브/OTG 터미널 간 파일을 전송할 수 있다. `FileProvider::getInstance()`를 통해 USB 관련 기능에 접근한다.

## USB 디렉토리 트리 조회

```cpp
#include <nevonex/file/FileProvider.h>

const std::unique_ptr<UsbContent>& usbContent = FileProvider::getInstance().getListOfFilesFromUSB();
```

`usbContent`는 USB 드라이브의 디렉토리 구조를 `UsbContent` 객체로 반환한다.

## FEU → USB 파일 복사

```cpp
auto child = usbContent->getChildAt(targetUSBPath);
if (child != nullptr) {
    child->copyFile(filePathInFEU);
}
```

| 매개변수 | 설명 |
|----------|------|
| `targetUSBPath` | USB 드라이브 내 대상 폴더 경로 |
| `filePathInFEU` | FEU 내 원본 파일 경로 |

## USB → FEU 파일 복사

```cpp
const std::shared_ptr<UsbContent> child = usbContent->getChildAt(sourceUSBPath);
if (child != nullptr) {
    boost::filesystem::path filePath = child->download(targetPathInFEU);
}
```

| 매개변수 | 설명 |
|----------|------|
| `sourceUSBPath` | USB 드라이브 내 원본 파일 경로 |
| `targetPathInFEU` | FEU 내 대상 폴더 경로 |

## 디렉토리 관리

```cpp
const std::unique_ptr<UsbContent>& usbContent = FileProvider::getInstance().getListOfFilesFromUSB();
if (usbContent != nullptr) {
    usbContent->createDirectory(dirName);    // 새 디렉토리 생성
    usbContent->updateName(newDirName);      // 디렉토리 이름 변경
}
```

## OTG 드라이브 마운트

```cpp
bool mounted = UsbContent::mountOTGDrive();
bool unmounted = UsbContent::unMountOTGDrive();
```

- `mountOTGDrive()`: USB OTG 드라이브를 마운트. 성공 시 `true`
- `unMountOTGDrive()`: USB OTG 드라이브를 언마운트. 성공 시 `true`

## 주의사항

- USB 드라이브가 연결되지 않은 상태에서 API 호출 시 `nullptr` 반환 가능 → 반드시 null 체크
- `getChildAt()` 경로가 존재하지 않으면 `nullptr` 반환
- USB I/O는 블로킹 → `Controller::run()` 안에서 직접 호출하지 말고 Process Timer나 별도 스레드에서 처리
- CCU USB 포트는 OTG 지원
