//
//  DeferredHandle.swift
//  Recommender
//
//  Created by huangmin on 08/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
import UIKit
import MobileBuySDK
final class DeferredHandle : NSObject{
    static let shared : DeferredHandle = DeferredHandle()
    var content : String?
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    func action(){
        guard let content = formatContent() else {
            return
        }
        guard let controller : SearchViewController = UIApplication.shared.keyWindow?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController else {
            return
        }
        controller.preText = content
        ((UIApplication.shared.keyWindow?.rootViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.pushViewController(controller, animated: true)
        self.content = nil
    }
    @objc func didBecomeActive(){
        action()
    }
    private func formatContent() -> String?{
        func reset(_ text : String,_ symbol : Character) -> String {
            return ((text.split(separator: symbol).map{
                GraphQL.ID(rawValue: String($0).getIntNumber()?.encodingProductID())
                } as [GraphQL.ID?]).flatMap{$0}.map{$0.rawValue.decodingGraphID()} as [Int64?]).flatMap{$0}.map{"\($0)"}.joined(separator: ",")
        }
        guard let content = self.content else { return nil }
        if content.contains(",") {
            return reset(content, ",")
        } else {
            return reset(content, "\r\n")
        }
    }
}
