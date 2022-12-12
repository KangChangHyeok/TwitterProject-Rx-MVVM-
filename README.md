## 트위터 클론 프로젝트 Rx + MVVM 리팩토링

## 프로젝트 목표
처음 강의를 들으면서 프로젝트를 만들때는 보고 따라 치기만 해서 강의 내용을 제대로 흡수하지 못했음.  
해당 강의를 처음부터 다시 복습하면서 코드를 내 것으로 만들고,  
기능이나 화면 단위 구현 마다 RxSwift와 MVVM 패턴을 적용하여 리팩토링 진행.

## 기술 스택
### Swift
- Swift 5
- UIKit
- RxSwift
- RxCocoa

### 뷰 드로잉
- snapKit

### 백엔드
- fireBase

### 디자인 패턴
- MVVM

## 프로젝트 진행과정(2022.12.7~ 진행중)

<details>
<summary>12월 7일 진행내용</summary>

- 프로젝트 기본 세팅 완료.
- MainTabView 구현 완료.
</details>

## 문제 해결
<details>
<summary>iOS 15 이후 지정한 NavigationBar의 BartintColor가 적용되지 않는 문제</summary>

### 문제상황

![](https://i.esdrop.com/d/t/Uu08dF3KgL/IfFSXPn7cQ.jpg)

코드에서 navigationBar의 색상을 white로 지정하였음.

하지만 실행해서 확인할 경우 지정한 색상이 적용되지 않고 투명하게 NavigationBar가 출력되었다.

### 원인

iOS 15부터 기능의 확장으로 인해 isTranslucent 의 default 설정이 false으로 지정되고,

scrollEdgeAppearance 속성이 iOS15에서는 모든 네비게이션에 적용되면서 발생한 문제.

scrollEdgeAppearance는 스크롤되는 contents의 Edge 자리가 네비게이션 가장자리에 맞춰질 때,

즉 **네비게이션 컨트롤러를 스크롤 하기 전의 상황**에서 apperance를 세팅해 주는 속성값이다.

standardApperance는 **스크롤중인 상황을 의미**한다.

### 해결방법

AppDelegate의 didFinishLaunchingWithOptions함수에서 UINavigationBarAppearance 객체를 생성.

해당 객체의 **configureWithOpaqueBackground()함수를 실행하여 불투명하게**  
Appearance 설정 후

backgroundColor 속성값을 내가 바꾸고자 하는 색상으로 변경한다.

UINavigationBar.appearance()의 standardAppearance와 scrollEdgeAppearance를 위에서 만든 appearance 객체로 변경.

```swift
let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
```
</details>