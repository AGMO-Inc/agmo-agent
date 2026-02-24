---
name: fdk-property-listener
description: "(feature - Skill) NEVONEX FDK PropertyChangeListener 가이드. 센서/인터페이스 데이터가 변경될 때 콜백으로 알림을 받는 패턴을 다룬다. 폴링(run() 루프) 대신 이벤트 기반으로 특정 Implement 속성 변경을 감지하고 싶을 때 사용한다. '속성 변경 감지', 'PropertyChangeListener', '이벤트 기반 감지', '센서값 변경 콜백', 'ReferencePosition 변경', '폴링 대신 리스너', 'Implement 속성 변경 시 즉시 반응' 같은 요청에서 사용한다."
---

# FDK PropertyChangeListener

## Overview

`Controller::run()`은 10Hz 폴링이지만, 특정 속성 변경을 즉시 감지해야 할 때는 `PropertyChangeListener`를 사용한다. Implement 객체에 리스너를 등록하면 해당 속성이 변경될 때마다 콜백이 호출된다.

## 리스너 클래스 작성

`ApplicationMainImpl.cpp` 상단(Protected Region 안)에 커스텀 리스너 클래스를 정의한다:

```cpp
/*PROTECTED REGION ID(property_listener_class) ENABLED START*/
class MyPropertyListener : public virtual ::nevonex::fcal_runtime::PropertyChangeListener
{
private:
    Controller_ptr controller;
public:
    MyPropertyListener(::AppMain::Controller_ptr _ctrl) : controller(_ctrl) {}

    inline virtual void propertyChange(
        ::nevonex::fcal_runtime::PropertyChangeEvent<
            const ::ecore::EJavaObject&, const ::ecore::EJavaObject&> changeEvent) override
    {
        try {
            ::ecore::EObject_ptr src = EJavaObject::any_cast<::ecore::EObject_ptr>(
                changeEvent.getSource());

            // 속성 이름과 소스 타입으로 필터링
            if (boost::iequals(src->eClass()->getName(), "Implement")
                && boost::iequals(changeEvent.getPropertyName(), "getReferencePosition"))
            {
                EJavaObject newValue = changeEvent.getNewValue();
                if (EJavaObject::is_a<EObject_ptr>(newValue)) {
                    using namespace ::nevonex::common;
                    EObject_ptr posObj = EJavaObject::any_cast<EObject_ptr>(newValue);
                    if (::ecore::instanceOf<AbsolutePosition>(posObj)) {
                        AbsolutePosition_ptr pos = ::ecore::as<AbsolutePosition>(posObj);
                        controller->setGetReferencePosition(pos);
                    }
                }
            }
        } catch (...) {
            NEVONEX_LOG(SeverityLevel::error)
                << boost::current_exception_diagnostic_information();
        }
    }
};
/*PROTECTED REGION END*/
```

## 리스너 등록

`onStart()` 메서드에서 Machine/Implement 초기화 후 등록한다:

```cpp
void ApplicationMain::onStart(::nevonex::feature::AbstractMachine_ptr machine)
{
    if (Implement_ptr implement = ::ecore::as<Implement>(machine))
    {
        /*PROTECTED REGION ID(ImplementProviderImplement_onStart) ENABLED START*/
        implement->addPropertyChangeListener(new MyPropertyListener(m_controller));
        /*PROTECTED REGION END*/
    }
}
```

## PropertyChangeEvent API

| 메서드 | 반환 타입 | 설명 |
|--------|----------|------|
| `getSource()` | `EJavaObject` | 변경이 발생한 소스 객체 |
| `getPropertyName()` | `string` | 변경된 속성 이름 |
| `getNewValue()` | `EJavaObject` | 새 값 |
| `getOldValue()` | `EJavaObject` | 이전 값 |

## 값 추출 패턴

`EJavaObject`에서 실제 타입을 추출하는 패턴:

```cpp
EJavaObject newValue = changeEvent.getNewValue();

// EObject 파생 타입 확인 및 캐스팅
if (EJavaObject::is_a<EObject_ptr>(newValue)) {
    EObject_ptr obj = EJavaObject::any_cast<EObject_ptr>(newValue);
    if (::ecore::instanceOf<AbsolutePosition>(obj)) {
        AbsolutePosition_ptr pos = ::ecore::as<AbsolutePosition>(obj);
        // pos 사용
    }
}
```

## 사용 지침

- **등록 위치**: `onStart()`의 Protected Region 안에서 등록 (Machine 초기화 완료 후)
- **필터링 필수**: 콜백은 등록된 객체의 **모든** 속성 변경에 호출됨 → `getPropertyName()`으로 원하는 속성만 필터링
- **예외 처리**: 콜백 내에서 반드시 try/catch로 감싸기 (미처리 예외 시 Feature 크래시)
- **폴링 vs 이벤트**: 단순 주기적 읽기는 `run()` 사용, 변경 즉시 반응이 필요하면 PropertyChangeListener 사용
- **메모리 관리**: `new`로 생성한 리스너는 Feature 종료 시까지 유지됨 (SDK가 관리)
