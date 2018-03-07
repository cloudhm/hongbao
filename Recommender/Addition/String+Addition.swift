//
//  String+Addition.swift
//  Recommender
//
//  Created by huangmin on 04/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
extension String {
    /**
     * id convert
     * https://ecommerce.shopify.com/c/shopify-apis-and-technology/t/product-id-in-admin-api-vs-product-id-in-graphql-465430
     */
    func decodingGraphID() -> Int64? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        guard let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        guard let lastComponent = URL(string: str)?.pathComponents.last else {
            return nil
        }
        return Int64(lastComponent)
    }
    
    func getIntNumber() -> String? {
        let string = NSString(string: self)
        let range = string.range(of: "[0-9]+", options: .regularExpression)
        if range.location == NSNotFound || range.length == 0 {
            return nil
        }
        return string.substring(with: range)
    }
    func encodingProductID()->String?{
        return ("gid://shopify/Product/"+self).data(using: .utf8)?.base64EncodedString()
    }
    func encodingProductVariantID()->String?{
        return ("gid://shopify/ProductVariant/"+self).data(using: .utf8)?.base64EncodedString()
    }
}
