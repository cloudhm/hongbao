//
//  RESTfulAPI.swift
//  Recommender
//
//  Created by huangmin on 07/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
import Alamofire
let postProductIDsPath = "storefront/admin/products"
let getProductsPath = "storefront/admin/products"
let putProductPath = "storefront/admin/products/"
let delProductPath = "storefront/admin/products/"
let postProductHandlesPath = "storefront/admin/products"
let getInfluencersPath = "storefront/admin/influencers"
let postInfluencerPath = "storefront/admin/influencers"
let putInfluencerPath = "storefront/admin/influencers/"
class RESTfulAPI {
    /**
     * POST product IDs
     * ids max count is 100
     */
    static func postProductsIDs(_ ids : [String],
                                _ completion : @escaping([String]?, Error?)->Void)->DataRequest {
        
        let query = ids.map{"id="+$0}.joined(separator: "&")
        return Alamofire
            .request(SettingsManager.shared.getURL(.product) + postProductIDsPath + "?" + query,
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
                guard let error = handleResponse(response) else {
                    guard let value = response.value as? [String: Any] else {
                        completion(nil, NSError(domain: "error",
                                                code: 500,
                                                userInfo: [NSLocalizedDescriptionKey:"未知错误"]) as Error)
                        return
                    }
                    completion(value.keys.map{$0}, response.error)
                    return
                }
                completion(nil, error)
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
            .request(SettingsManager.shared.getURL(.product) + getProductsPath,
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
                guard let _ = handleResponse(response) else {
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
                    return
                }
                completion(nil, nil)
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
            .request(SettingsManager.shared.getURL(.product) + putProductPath + productId + "/top" + "?top=" + (top ? "true" : "false"),
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
                guard let error = handleResponse(response) else {
                    guard let value = response.value as? [String: Any] else {
                        completion(nil, NSError(domain: "error",
                                                code: 500,
                                                userInfo: [NSLocalizedDescriptionKey:"未知错误"]) as Error)
                        return
                    }
                    let decoder = JSONDecoder()
                    var recommenderProduct : RecommenderProduct?
                    do {
                        recommenderProduct = try decoder.decode(RecommenderProduct.self, from: JSONSerialization.data(withJSONObject: value, options: []))
                    } catch {
                        
                    }
                    completion(recommenderProduct, response.error)
                    return
                }
                completion(nil, error)
        }
    }
    /**
     * DELETE product
     * delete product id
     */
    static func delProduct(_ productId : String,
                           _ completion : @escaping(Error?)->Void)-> DataRequest {
        return Alamofire
            .request(SettingsManager.shared.getURL(.product) + delProductPath + productId,
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
                guard let error = handleResponse(response) else {
                    completion(nil)
                    return
                }
                completion(error)
            }
    }
    /**
     * POST product handles
     * handles max count is 100
     */
    static func postProductsHandles(_ handles : [String],
                                    _ completion : @escaping([String]?, Error?)->Void)->DataRequest {
        let query = handles.map{ "handle="+$0 }.joined(separator: "&")
        return Alamofire
            .request(SettingsManager.shared.getURL(.product) + postProductIDsPath + "?" + query,
                     method: .post,
                     parameters: nil,
                     encoding: URLEncoding.default,
                     headers: nil)
            .validate { (request, response, data) in
                return .success
            }
            .responseJSON { response in
                guard let error = handleResponse(response) else {
                    guard let values = response.value as? [String : Any] else {
                        completion(nil, NSError(domain: "error",
                                                code: 500,
                                                userInfo: [NSLocalizedDescriptionKey:"未知错误"]) as Error)
                        return
                    }
                    completion(values.keys.map{$0},nil)
                    return
                }
                completion(nil, error)
        }
    }
    //
    static func getInfluencers(_ page : Int,
                               _ size : Int,
                               _ completion : @escaping([Influencer]?, Bool?)->Void)->DataRequest {
        return Alamofire
            .request(SettingsManager.shared.getURL(.influencer) + getInfluencersPath,
                                 method: .get,
                                 parameters: ["page":page,
                                              "size":size,
                                              "sort":"name,asc"],
                                 encoding: URLEncoding.default,
                                 headers: nil)
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
                        return try decoder.decode(Influencer.self, from: JSONSerialization.data(withJSONObject: $0, options: []))
                    } catch {
                        return nil
                    }
                    } as [Influencer?]).flatMap{$0}
                completion(list, last)
        }
    }
    /**
     * create a influencer
     * post method, influencerJSON required
     */
    static func postInfluencer(_ influencerJSON : [String : Any],
                               _ completion : @escaping(Influencer?, Error?)->Void)->DataRequest{
        return Alamofire
            .request(SettingsManager.shared.getURL(.influencer) + postInfluencerPath,
                                 method: .post,
                                 parameters: influencerJSON,
                                 encoding: JSONEncoding.default,
                                 headers: nil)
            .validate { (request, response, data) in
                return .success
            }
            .responseJSON { response in
                guard let error = handleResponse(response) else {
                    guard let value = response.value as? [String: Any] else {
                        completion(nil,NSError(domain: "error",
                                               code: 500,
                                               userInfo: [NSLocalizedDescriptionKey:"未知错误"]) as Error)
                        return
                    }
                    let decoder = JSONDecoder()
                    var influencer : Influencer?
                    do {
                        influencer = try decoder.decode(Influencer.self, from: JSONSerialization.data(withJSONObject: value, options: []))
                    } catch {
                        
                    }
                    completion(influencer, nil)
                    return
                }
                completion(nil, error)
        }
    }
    /**
     * update influencer
     * id / influencerJSON required
     */
    static func putInfluencer(_ id : Int,
                              _ influencerJSON : [String:Any],
                              _ completion : @escaping(Influencer?, Error?)->Void) -> DataRequest {
        return Alamofire
            .request(SettingsManager.shared.getURL(.influencer) + postInfluencerPath + "/\(id)",
                     method: .put,
                     parameters: influencerJSON,
                     encoding: JSONEncoding.default,
                     headers: nil)
            .validate { (request, response, data) in
                return .success
            }
            .responseJSON { response in
                guard let error = handleResponse(response) else {
                    guard let value = response.value as? [String: Any] else {
                        completion(nil, NSError(domain: "error",
                                                code: 500,
                                                userInfo: [NSLocalizedDescriptionKey:"未知错误"]) as Error)
                        return
                    }
                    let decoder = JSONDecoder()
                    var influencer : Influencer?
                    do {
                        influencer = try decoder.decode(Influencer.self, from: JSONSerialization.data(withJSONObject: value, options: []))
                    } catch {
                        
                    }
                    completion(influencer, nil)
                    return
                }
                completion(nil, error)
        }
    }
    static func handleResponse(_ response : DataResponse<Any>) -> Error? {
        debugPrint(response)
        guard let err = response.error else {
            let statusCode = response.response?.statusCode ?? 500
            if statusCode == 200 || statusCode == 201 || statusCode == 202 || statusCode == 203 || statusCode == 204 {
                return nil
            }
            guard let errPayload = response.value as? [String : Any],
                let errMsg = errPayload["message"] else {
                    return NSError(domain: "error",
                                   code: 500,
                                   userInfo: [NSLocalizedDescriptionKey:"未知错误"]) as Error
            }
            return NSError(domain: "error",
                           code: statusCode,
                           userInfo: [NSLocalizedDescriptionKey:errMsg]) as Error
        }
        return err
    }
}
