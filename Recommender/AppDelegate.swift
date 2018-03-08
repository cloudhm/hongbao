//
//  AppDelegate.swift
//  Recommender
//
//  Created by huangmin on 04/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "file" && (url.pathExtension == "txt" || url.pathExtension == "csv") {
            do  {
                let content = try NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue)
                DeferredHandle.shared.content = content as String
            } catch {
            }
        }
        return true
    }
}

