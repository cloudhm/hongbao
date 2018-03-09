//
//  AppDelegate.swift
//  Recommender
//
//  Created by huangmin on 04/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit
import netfox
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NFX.sharedInstance().start()
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        DeferredHandle.shared.configureContent(url)
        return true
    }
}

