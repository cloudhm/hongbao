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
import MBProgressHUD
import ObjectiveC
import Alamofire
final class DeferredHandle : NSObject{
    enum DeferredHandleType {
        case none
        case productHandlesCSV
        case productIdsTXT
        case productIdsCSV
        case influencersCSV
        case updateInfluencersCSV
        static func validateURL(_ url : URL?) -> DeferredHandleType {
            guard let url = url else {
                return .none
            }
            if url.lastPathComponent.hasPrefix("ids") && url.lastPathComponent.hasSuffix("txt") {
                return .productIdsTXT
            } else if url.lastPathComponent.hasPrefix("ids") && url.lastPathComponent.hasSuffix("csv") {
                return .productIdsCSV
            } else if url.lastPathComponent.hasPrefix("products_export") && url.lastPathComponent.hasSuffix("csv") {
                return .productHandlesCSV
            } else if url.lastPathComponent.hasPrefix("influencers") && url.lastPathComponent.hasSuffix("csv") {
                return .influencersCSV
            } else if url.lastPathComponent.hasPrefix("update_influencers") && url.lastPathComponent.hasSuffix("csv"){
                return .updateInfluencersCSV
            }
            return .none
        }
    }
    static let shared : DeferredHandle = DeferredHandle()
    private var contentURL : URL?
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    func action(){
        // string --> ids joint by comma
        func convertIDs(_ text : String,_ symbol : Character) -> String {
            let result = ((text.split(separator: symbol).map{
                GraphQL.ID(rawValue: String($0).getIntNumber()?.encodingProductID())
                } as [GraphQL.ID?]).flatMap{$0}.map{$0.rawValue.decodingGraphID()} as [Int64?]).flatMap{$0}.map{"\($0)"}
            return Set(result).joined(separator: ",")
        }
        let type = DeferredHandleType.validateURL(contentURL)
        switch type {
        case .productHandlesCSV:
            guard let list = NSArray(contentsOfCSVURL:contentURL) as? [[String]] else {
                return
            }
            var elements : Set<String> = []
            for (index,element) in list.enumerated() {
                if index > 0 {
                    guard let firstElement = element.first else {
                        continue
                    }
                    elements.insert(firstElement)
                }
            }
            uploadHandles(elements.sorted())
            break
        case .productIdsTXT:
            do  {
                let text = try NSString(contentsOf: contentURL!, encoding: String.Encoding.utf8.rawValue)
                guard let controller : SearchViewController = UIApplication.shared.keyWindow?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController else {
                        return
                }
                controller.preText = convertIDs(text as String,",")
                ((UIApplication.shared.keyWindow?.rootViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.pushViewController(controller, animated: true)
            } catch {
            }
            break
        case .productIdsCSV:
            guard let list = NSArray(contentsOfCSVURL:contentURL) as? [[String]] else {
                return
            }
            var elements : Set<String> = []
            for (index,element) in list.enumerated() {
                if index > 0 {
                    guard let firstElement = element.first else {
                        continue
                    }
                    elements.insert(firstElement)
                }
            }
            let text = elements.joined(separator: ",")
            guard let controller : SearchViewController = UIApplication.shared.keyWindow?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController else {
                return
            }
            controller.preText = convertIDs(text,",")
            ((UIApplication.shared.keyWindow?.rootViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.pushViewController(controller, animated: true)
        case .influencersCSV:
            guard let list = NSArray(contentsOfCSVURL:contentURL) as? [[String]] else {
                return
            }
            let influencersJSON = Influencer.convertInfluencersJSON(list)
            if influencersJSON.count == 0 { return }
            let operationQueue : OperationQueue = OperationQueue()
            operationQueue.maxConcurrentOperationCount = 1
            MBProgressHUD.showAnimationView(UIApplication.shared.keyWindow?.rootViewController?.view, "上传中\n请等待...")
            for json in influencersJSON {
                let block = BlockOperation(block: {
                    _ = RESTfulAPI.postInfluencer(json) { influencer, error in
                        debugPrint(error)
                        if influencer != nil {
                            sleep(1)
                        }
                    }
                })
                operationQueue.addOperations([block], waitUntilFinished: true)
            }
            let block = BlockOperation(block: {
                DispatchQueue.main.async {
                    MBProgressHUD.hide(UIApplication.shared.keyWindow?.rootViewController?.view)
                }
            })
            operationQueue.addOperations([block], waitUntilFinished: true)
        case .updateInfluencersCSV:
            guard let list = NSArray(contentsOfCSVURL:contentURL) as? [[String]] else {
                return
            }
            let influencersJSON = Influencer.convertInfluencersJSON(list)
            if influencersJSON.count == 0 { return }
            let operationQueue : OperationQueue = OperationQueue()
            operationQueue.maxConcurrentOperationCount = 1
            MBProgressHUD.showAnimationView(UIApplication.shared.keyWindow?.rootViewController?.view, "上传中\n请等待...")
            for json in influencersJSON {
                let block = BlockOperation(block: {
                    guard let idStr = json[Influencer.InfluencerKeys.id.rawValue] as? String,
                        let id = Int(idStr) else {
                            return
                    }
                    _ = RESTfulAPI.putInfluencer(id, json) { influencer, error in
                        debugPrint(error)
                        if influencer != nil {
                            sleep(1)
                        }
                    }
                })
                operationQueue.addOperations([block], waitUntilFinished: true)
            }
            let block = BlockOperation(block: {
                DispatchQueue.main.async {
                    MBProgressHUD.hide(UIApplication.shared.keyWindow?.rootViewController?.view)
                }
            })
            operationQueue.addOperations([block], waitUntilFinished: true)
        default:
            contentURL = nil
            return
        }
        self.contentURL = nil
    }
    
    
    @objc func didBecomeActive(){
        action()
    }
    func configureContent(_ url : URL) {
        contentURL = url
    }
    private func uploadHandles(_ handles : [String]) {
        if handles.count == 0 {
            return
        }
        MBProgressHUD.showAnimationView(UIApplication.shared.keyWindow?.rootViewController?.view, "上传中\n请等待...")
        _ = RESTfulAPI.postProductsHandles(handles) { (ids, error) in
            MBProgressHUD.hide(UIApplication.shared.keyWindow?.rootViewController?.view)
            let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            var controller : UIAlertController?
            if error != nil {
                controller = UIAlertController(title: "错误", message: error?.localizedDescription, preferredStyle: .alert)
            } else {
                controller = UIAlertController(title: "提示", message: "上传完成了", preferredStyle: .alert)
            }
            controller?.addAction(okAction)
            guard let alertController = controller else { return }
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
}
