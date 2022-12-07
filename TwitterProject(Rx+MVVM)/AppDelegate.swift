//
//  AppDelegate.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = MainTabView()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        let appearance2 = UINavigationBarAppearance()
        appearance2.configureWithOpaqueBackground()
        appearance2.backgroundColor = .purple
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        return true
    }
}

