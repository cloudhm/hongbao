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
final class DeferredHandle : NSObject{
    enum DeferredHandleType {
        case none
        case productHandlesCSV
        case productIdsTXT
        case productIdsCSV
        case influencersCSV
    }
    static let shared : DeferredHandle = DeferredHandle()
    private var content : String?
    private var type : DeferredHandleType = .none
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    func action(){
        guard let content = formatContent() else {
            return
        }
        if type == .productIdsTXT || type == .productIdsCSV {
            guard let controller : SearchViewController = UIApplication.shared.keyWindow?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController else {
                return
            }
            controller.preText = content
            ((UIApplication.shared.keyWindow?.rootViewController as? UITabBarController)?.selectedViewController as? UINavigationController)?.pushViewController(controller, animated: true)
        } else if type == .productHandlesCSV {
            uploadHandles(content.split(separator: ",").map{String($0)})
        }
        self.content = nil
        self.type = .none
    }
    @objc func didBecomeActive(){
        action()
    }
    private func formatContent() -> String?{
        // string --> ids joint by comma
        func convertIDs(_ text : String,_ symbol : Character) -> String {
            let result = ((text.split(separator: symbol).map{
                GraphQL.ID(rawValue: String($0).getIntNumber()?.encodingProductID())
                } as [GraphQL.ID?]).flatMap{$0}.map{$0.rawValue.decodingGraphID()} as [Int64?]).flatMap{$0}.map{"\($0)"}
            return Set(result).joined(separator: ",")
        }
        // string --> handles joint by comma
        func convertHandles(_ text : String) -> String {
            var list = (text.split(separator: "\r\n").map{
                $0.split(separator: ",").first
            }).flatMap{$0}
            list.removeFirst()
            return Set(list).joined(separator: ",")
        }
        guard let content = self.content else { return nil }
        if type == .productIdsCSV || type == .productIdsTXT {
            if content.contains(",") {
                return convertIDs(content, ",")
            } else {
                return convertIDs(content, "\r\n")
            }
        } else if  type == .productHandlesCSV {
            return convertHandles(content)
        }
        return nil
    }
    func configureContent(_ url : URL) {
        if !validateURLPath(url) {
            return
        }
        var parseContent : NSString?
        do  {
            parseContent = try NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue)
        } catch {
            let encoding : UInt = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.macChineseSimp.rawValue))
            do  {
                let data = try Data(contentsOf: url)
                parseContent = NSString(data: data, encoding: encoding)
            } catch {
                
            }
        }
        guard let content = parseContent else { return }
        self.content = content as String
        if url.lastPathComponent.hasPrefix("ids") && url.lastPathComponent.hasSuffix("txt") {
            self.type = .productIdsTXT
        } else if url.lastPathComponent.hasPrefix("ids") && url.lastPathComponent.hasSuffix("csv") {
            self.type = .productIdsCSV
        } else if url.lastPathComponent.hasPrefix("products_export") && url.lastPathComponent.hasSuffix("csv") {
            self.type = .productHandlesCSV
        }
    }
    private func validateURLPath(_ url : URL) -> Bool {
        if url.scheme == "file" &&
            ((url.lastPathComponent.hasPrefix("ids") && url.lastPathComponent.hasSuffix("txt") ) ||
                (url.lastPathComponent.hasPrefix("ids") && url.lastPathComponent.hasSuffix("csv")) ||
                (url.lastPathComponent.hasPrefix("products_export") && url.lastPathComponent.hasSuffix("csv"))) {
            return true
        }
        return false
    }
    private func uploadHandles(_ handles : [String]) {
        if handles.count == 0 {
            return
        }
        MBProgressHUD.showAnimationView(UIApplication.shared.keyWindow?.rootViewController?.view, "Uploading\nPlease waiting...")
        _ = RESTfulAPI.postProductsHandles(handles) { (ids, error) in
            MBProgressHUD.hide(UIApplication.shared.keyWindow?.rootViewController?.view)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            var controller : UIAlertController?
            if error != nil {
                controller = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            } else {
                controller = UIAlertController(title: "Tips", message: "Upload finished", preferredStyle: .alert)
            }
            controller?.addAction(okAction)
            guard let alertController = controller else { return }
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
}
