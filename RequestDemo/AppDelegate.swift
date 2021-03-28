//
//  AppDelegate.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        windowConfig()
        // Override point for customization after application launch.
        return true
    }
    /// window配置
    private func windowConfig() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let mainController = MainListController()
        window?.rootViewController = mainController
    }
}
