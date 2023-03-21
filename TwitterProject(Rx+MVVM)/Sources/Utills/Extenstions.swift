//
//  Extenstions.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

// MARK: - UIView
extension UIView {
    func setupNSLayoutAnchor(top: NSLayoutYAxisAnchor? = nil,
                             left: NSLayoutXAxisAnchor? = nil,
                             right: NSLayoutXAxisAnchor? = nil,
                             bottom: NSLayoutYAxisAnchor? = nil,
                             paddingTop: CGFloat = 0,
                             paddingLeft: CGFloat = 0,
                             paddingRight: CGFloat = 0,
                             paddingBottom: CGFloat = 0,
                             height: CGFloat? = nil,
                             width: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    func setupCenter(superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
    }
    func setupCenterX(superView: UIView, top: NSLayoutYAxisAnchor? = nil,paddingTop: CGFloat = 0,bottom: NSLayoutYAxisAnchor? = nil,paddingBottom: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
    }
    func setupCenterY(superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
    }
    func setupSize(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
}
// MARK: - UIColor

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let twitterBlue = UIColor.rgb(red: 29, green: 161, blue: 242)
}
// MARK: - ImagePickerController RxExtension

final class RxImagePickerDelegateProxy: DelegateProxy<UIImagePickerController, UINavigationControllerDelegate & UIImagePickerControllerDelegate>, DelegateProxyType, UINavigationControllerDelegate & UIImagePickerControllerDelegate {

    static func currentDelegate(for object: UIImagePickerController) -> (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?, to object: UIImagePickerController) {
        object.delegate = delegate
    }

    static func registerKnownImplementations() {
        self.register { RxImagePickerDelegateProxy(parentObject: $0, delegateProxy: RxImagePickerDelegateProxy.self) }
     }
}

extension Reactive where Base: UIImagePickerController {

    var didFinishPickingMediaWithInfo: Observable<[UIImagePickerController.InfoKey: AnyObject]> {
        return RxImagePickerDelegateProxy.proxy(for: base)
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            .map({ (a) in
                return try castOrThrow(Dictionary<UIImagePickerController.InfoKey, AnyObject>.self, a[1])
            })
    }
}

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}
// MARK: - RxGesture extension - 동시 인식 안돼게 하기
extension Reactive where Base: RxGestureView {
  public func tapGestureOnTop() -> TapControlEvent {
    return self.tapGesture { gesture, delegate in
      delegate.simultaneousRecognitionPolicy = .never
    }
  }
}

// MARK: - UIResponder
extension UIResponder {
    var superViewController: UIViewController? {
        var responder = self
        while let nextResponder = responder.next {
            responder = nextResponder
            if let superViewCOntroller = responder as? UIViewController {
                return superViewCOntroller
            }
        }
        return nil
    }
}

extension UIViewController {
    func makeContainerView(image: UIImage?, textField: UITextField) -> UIView {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = image
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = .white
        
        view.addSubview(imageView)
        view.addSubview(textField)
        view.addSubview(bottomLine)
        
        imageView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0))
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        textField.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.trailing.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 8))
        }
        bottomLine.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.leading)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.75)
        }
        return view
    }
    func makeTextField(placeHolerString: String) -> UITextField {
        let textField = UITextField()
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.attributedPlaceholder = NSAttributedString(string: placeHolerString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        return textField
    }
    func makeButton(buttonTitle: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(buttonTitle, for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(50)
        }
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }
    func attributedButton(firstPart: String, secondPart: String) -> UIButton {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: firstPart, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        
        attributedTitle.append(NSAttributedString(string: secondPart, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }
}

extension ViewModelType {
    func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
}
