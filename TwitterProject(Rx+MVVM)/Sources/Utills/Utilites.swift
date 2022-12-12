//
//  Utilites.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/12.
//

import UIKit

struct Utilites {
    
    func makeContainerView(image: UIImage?, textField: UITextField) -> UIView {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = image
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = .white
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0))
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.trailing.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 8))
        }
        view.addSubview(bottomLine)
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
