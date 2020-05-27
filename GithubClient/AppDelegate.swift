//
//  AppDelegate.swift
//  GithubClient
//
//  Created by lieon on 2020/5/22.
//  Copyright © 2020 lieon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let root = UINavigationController(rootViewController: ViewRouter.createModule())
        window?.rootViewController = root
        window?.makeKeyAndVisible()
        User.shared.read()
        return true
    }
}

