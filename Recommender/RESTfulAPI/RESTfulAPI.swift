//
//  RESTfulAPI.swift
//  Recommender
//
//  Created by huangmin on 07/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
import Alamofire
let postProductIDsPath = "http://192.168.20.34:3000/storefront/admin/products"
let getProductsPath = "http://192.168.20.34:3000/storefront/admin/products"
let putProductPath = "http://192.168.20.34:3000/storefront/admin/products/"
let delProductPath = "http://192.168.20.34:3000/storefront/admin/products/"
let postProductHandlesPath = "http://192.168.20.34:3000/storefront/admin/products"
class RESTfulAPI {
    /**
     * POST product IDs
     * ids max count is 100
     */
    static func postProductsIDs(_ ids : [String],
                                _ completion : @escaping([Int]?, Error?)->Void)->DataRequest {
        var query = ""
        for idStr in ids {
            if query.count > 0 {
                query += "&"
            }
            query += ("id="+idStr)
        }
        return Alamofire
            .request(postProductIDsPath + "?" + query,
                     method: .post,
                     parameters: nil,
                     encoding: URLEncoding.default,
                     headers: nil)
            .downloadProgress(queue: DispatchQueue.global(qos : .utility)) { progress in
                print("Progress: \(progress.fractionCompleted)")
            }
            .validate { (request, response, data) in
                return .success
            }
            .responseJSON { response in
                debugPrint(response)
                guard let value = response.value as? [String: [Int]],
                let notfoundIDs = value["notFound"] else {
                    completion(nil, response.error)
                    return
                }
                completion(notfoundIDs,response.error)
            }
    }
    /**
     * GET product IDs
     * get a list of products
     */
    static func getProducts(_ page : Int,
                            _ size : Int,
                            _ completion : @escaping([RecommenderProduct]?, Bool?)->Void)->DataRequest {
        return Alamofire
            .request(getProductsPath,
                     method: .get,
                     parameters: ["page":page,
                                  "size":size,
                                  "sort":"id,desc"],
                     encoding: URLEncoding.default,
                     headers: nil)
            .downloadProgress(queue: DispatchQueue.global(qos : .utility)) { progress in
                print("Progress: \(progress.fractionCompleted)")
            }
            .validate { (request, response, data) in
                return .success
            }
            .responseJSON { response in
                debugPrint(response)
                guard let value = response.value as? [String: Any] else {
                    completion(nil,nil)
                    return
                }
                guard let content = value["content"] as? [[String : Any]],
                let last = value["last"] as? Bool else {
                    completion(nil, nil)
                    return
                }
                let decoder = JSONDecoder()
                let list = (content.map{
                    do {
                        return try decoder.decode(RecommenderProduct.self, from: JSONSerialization.data(withJSONObject: $0, options: []))
                    } catch {
                        return nil
                    }
                } as [RecommenderProduct?]).flatMap{$0}
                completion(list, last)
            }
    }
    /**
     * PUT product id
     * only modify product's property top(type boolean)
     */
    static func putProduct(_ productId : String,
                           _ top : Bool,
                           _ completion : @escaping(RecommenderProduct?, Error?)->Void)-> DataRequest {
        return Alamofire
            .request(putProductPath + productId + "?top=" + (top ? "true" : "false"),
                     method: .put,
                     parameters: nil,
                     encoding: URLEncoding.default,
                     headers: nil)
            .downloadProgress(queue: DispatchQueue.global(qos : .utility)) { progress in
                print("Progress: \(progress.fractionCompleted)")
            }
            .validate { (request, response, data) in
                return .success
            }
            .responseJSON { response in
                debugPrint(response)
                guard let value = response.value as? [String: Any] else {
                    completion(nil, response.error)
                    return
                }
                let decoder = JSONDecoder()
                var recommenderProduct : RecommenderProduct?
                do {
                    recommenderProduct = try decoder.decode(RecommenderProduct.self, from: JSONSerialization.data(withJSONObject: value, options: []))
                } catch {
                    
                }
                completion(recommenderProduct, response.error)
        }
    }
    /**
     * DELETE product
     * delete product id
     */
    static func delProduct(_ productId : String,
                           _ completion : @escaping(Error?)->Void)-> DataRequest {
        return Alamofire
            .request(delProductPath + productId,
                     method: .delete,
                     parameters: nil,
                     encoding: URLEncoding.default,
                     headers: nil)
            .downloadProgress(queue: DispatchQueue.global(qos : .utility)) { progress in
                print("Progress: \(progress.fractionCompleted)")
            }
            .validate { (request, response, data) in
                return .success
            }
            .responseJSON { response in
                debugPrint(response)
                completion(response.error)
            }
    }
    /**
     * POST product handles
     * handles max count is 100
     */
    static func postProductsHandles(_ handles : [String],
                                    _ completion : @escaping([Int]?, Error?)->Void)->DataRequest {
        var query = ""
        for handle in handles {
            if query.count > 0 {
                query += "&"
            }
            query += ("handle="+handle.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
        }
        return Alamofire
            .request(postProductIDsPath + "?" + query,
                     method: .post,
                     parameters: nil,
                     encoding: URLEncoding.default,
                     headers: nil)
            .validate { (request, response, data) in
                return .success
            }
            .responseJSON { response in
                debugPrint(response)
                guard let value = response.value as? [String: [Int]],
                    let notfoundIDs = value["notFound"] else {
                        completion(nil, response.error)
                        return
                }
                completion(notfoundIDs,response.error)
        }
    }
}
