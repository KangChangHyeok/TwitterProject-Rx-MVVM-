//
//  AuthenticationNavigationController.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/08.
//
import UIKit

class LoginNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        self.topViewController
    }
    override func viewDidLoad() {
        navigationBar.isHidden = true
    }
}
