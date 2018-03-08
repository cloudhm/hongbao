//
//  Client.swift
//  Storefront
//
//  Created by Shopify.
//  Copyright (c) 2017 Shopify Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import MobileBuySDK
final class Client {
    
    static let shopDomain = "whatsmode.com"          // graphql.myshopify.com
    static let apiKey     = "6c54edda1f76ffe052d27d6918e3e615" // 8e2fef6daed4b93cf4e731f580799dd1
    
    static let shared = Client()
    
    private let client: Graph.Client = Graph.Client(shopDomain: Client.shopDomain, apiKey: Client.apiKey)
    
    // ----------------------------------
    //  MARK: - Init -
    //
    private init() {
        self.client.cachePolicy = .networkOnly
    }
}

/**
 * query root
 */
extension Client {
    func queryProductListBy(_ cursor : String?,_ refresh : Bool, _ completion : @escaping(Storefront.ProductConnection?, String?)->Void) -> Task {
        let query = ClientQuery.queryProductList(cursor)
        let task = self.client.queryGraphWith(query, cachePolicy: refresh ? .cacheFirst(expireIn: 60) : .cacheFirst(expireIn: 3600), retryHandler: nil) { response, error in
            completion(response?.shop.products, error?.message())
        }
        task.resume()
        return task
    }
    func queryProductsByIDs(_ ids : [GraphQL.ID], _ completion : @escaping([Storefront.Product]?, String?)->Void) -> Task {
        let query = ClientQuery.queryProductListByIds(ids)
        let task = self.client.queryGraphWith(query, cachePolicy: .cacheFirst(expireIn: 3600), retryHandler: nil) { response, error in
            guard let products = response?.nodes as? [Storefront.Product?] else {
                completion(nil, error?.message())
                return
            }
            completion(products.flatMap{$0},  error?.message())
        }
        task.resume()
        return task
    }
}
// ----------------------------------
//  MARK: - GraphError -
//
extension Optional where Wrapped == Graph.QueryError {
    
    func debugPrint() {
        switch self {
        case .some(let value):
            print("Graph.QueryError: \(value)")
        case .none:
            break
        }
    }
}
extension Graph.QueryError {
    func message() -> String? {
        switch self {
        case .request(let error):
            return error?.localizedDescription
        case .invalidQuery(let reasons):
            return reasons.first?.message
        default:
            return localizedDescription
        }
    }
}
