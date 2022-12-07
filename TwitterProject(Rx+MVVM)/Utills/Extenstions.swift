//
//  Extenstions.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//

import UIKit
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
    func setupCenterX(superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
    }
    func setupCenterY(superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
    }
}
// MARK: - UIColor

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let twitterBlue = UIColor.rgb(red: 29, green: 161, blue: 242)
}
