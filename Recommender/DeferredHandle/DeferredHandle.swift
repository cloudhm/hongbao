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
        case influencersCSV
        static func validateURL(_ url : URL?) -> DeferredHandleType {
            guard let url = url else {
                return .none
            }
            if url.lastPathComponent.hasPrefix("products_export") && url.lastPathComponent.hasSuffix("csv") {
                return .productHandlesCSV
            } else if url.lastPathComponent.hasPrefix("influencers") && url.lastPathComponent.hasSuffix("csv") {
                return .influencersCSV
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
            uploadHandles(elements.sorted().map{ URL(string: $0)?.lastPathComponent ?? $0}.map{$0.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!})
        case .influencersCSV:
            guard let list = NSArray(contentsOfCSVURL:contentURL) as? [[String]] else {
                return
            }
            let influencersJSON = Influencer.convertInfluencersJSON(list)
            if influencersJSON.count == 0 { return }
            var influencers : [Influencer] = []
            let decoder = JSONDecoder()
            for influencerJSON in influencersJSON {
                do  {
                    let influencer = try decoder.decode(Influencer.self, from: JSONSerialization.data(withJSONObject: influencerJSON, options: []))
                    influencers.append(influencer)
                } catch {
                    
                }
            }
            let controller = UIAlertController(title: "提示", message: "请选择上传/预览", preferredStyle: .alert)
            let previewAction = UIAlertAction(title: "预览", style: .default, handler: { (action) in
                guard let previewController = UIApplication.shared.keyWindow?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: String(describing:PreviewInfluencerViewController.self)) as? PreviewInfluencerViewController else {
                    return
                }
                previewController.influencers = influencers
                ((UIApplication.shared.keyWindow?.rootViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.pushViewController(previewController, animated: true)
            })
            controller.addAction(previewAction)
            let submitAction = UIAlertAction(title: "上传", style: .default, handler: { (action) in
                DeferredHandle.submitInfluencerAction(influencersJSON)
            })
            controller.addAction(submitAction)
            let cancelAction = UIAlertAction(title: "暂不", style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
        default:
            contentURL = nil
            return
        }
        self.contentURL = nil
    }
    static func submitInfluencerAction(_ influencersJSON : [[String : Any]]){
        let operationQueue : OperationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        MBProgressHUD.showAnimationView(UIApplication.shared.keyWindow?.rootViewController?.view, "同步中\n请等待...")
        for json in influencersJSON {
            let block = BlockOperation(block: {
                guard let id = json[Influencer.InfluencerKeys.id.rawValue] as? Int else {
                        _ = RESTfulAPI.postInfluencer(json) { influencer, error in
                            debugPrint(error)
                        }
                        return
                }
                _ = RESTfulAPI.putInfluencer(id, json) { influencer, error in
                    debugPrint(error)
                }
            })
            operationQueue.addOperations([block], waitUntilFinished: true)
        }
        let block = BlockOperation(block: {
            DispatchQueue.main.async {
                MBProgressHUD.hide(UIApplication.shared.keyWindow?.rootViewController?.view)
                let controller = UIAlertController(title: "提示", message: "上传同步已完毕。如有问题请联系技术开发", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                    ((UIApplication.shared.keyWindow?.rootViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.popViewController(animated: true)
                })
                controller.addAction(okAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
            }
        })
        operationQueue.addOperations([block], waitUntilFinished: true)
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
