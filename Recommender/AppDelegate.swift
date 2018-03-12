//
//  AppDelegate.swift
//  Recommender
//
//  Created by huangmin on 04/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit
import netfox
import Alamofire
import Foundation
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NFX.sharedInstance().start()
        
        let path = Bundle.main.path(forResource: "influencers", ofType: "json")
        do {
            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path!))
            let jsons = try JSONSerialization.jsonObject(with: data, options: [])
            for json in (jsons as! [[String:Any]]) {
                Alamofire.request("http://192.168.20.34:3000/storefront/admin/influencers",
                                  method: HTTPMethod.post,
                                  parameters: json,
                                  encoding: JSONEncoding.default,
                                  headers: nil)
            }
        } catch {
            
        }
 
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        DeferredHandle.shared.configureContent(url)
        return true
    }
}

