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
<details>
<summary>12월 12일 진행내용</summary>

- 기능 구현
	- LoginView, RegisterationView 구현 완료.
- 뷰 드로잉 관련
	- NSLayoutAchor -> SnapKit으로 수정
</details>
<details>
<summary>12월 26일 진행내용</summary>

- 리팩토링
	- 기능 단위나 화면 단위 구현시 마다 RxSwift 적용하여 리팩토링
- 커밋 관련
	- 커밋 메세지 규칙 적용.
		- 작성 언어는 한글로 설정.
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

## 궁금한 점
<details>
<summary>Resource와 Source의 차이?</summary>

프로젝트 파일이 커지면서 폴더 구조방식에 대해 고민하게 되었고,  
찾아본 결과 많은 사람들이 기본적으로 Resource와 Source폴더를 기준으로 폴더링 하는 것을 알게 되었다.  
두 단어를 개발하면서 많이 접하고 사용하지만, 정작 정확한 의미를 몰라서 찾아보게 되었다.  

### Source

 일반적으로 컴파일 가능하고 사람이 읽을 수 있는 언어로 된 프로그램 코드.

(프로세서에 의해 궁극적으로 실행되는 이진 코드인 대상 코드와 반대).

### Resource

일반적으로 실행 가능한 이미지에 포함된 데이터. 

오류 메시지, 그림, 사운드 클립, 아이콘 등.

출처

[what is a difference between resource and source in programming](https://softwareengineering.stackexchange.com/questions/384540/what-is-a-difference-between-resource-and-source-in-programming)

### 프로젝트에 적용
-> 단어의 정확한 의미를 알고나서 정확한 기준이 생겨 구분하기 편했다.  
LaunchScreen 파일이나 Assets 관련 파일은 Resource 파일에 구분하고,  
내가 작성한 기존 코드들은 Source파일에 정리했다.
</details>