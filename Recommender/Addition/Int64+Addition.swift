//
//  Int64+Addition.swift
//  Recommender
//
//  Created by huangmin on 04/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
extension Int64 {
    /**
     * id convert
     * https://ecommerce.shopify.com/c/shopify-apis-and-technology/t/product-id-in-admin-api-vs-product-id-in-graphql-465430
     */
    func encodingProductID()->String?{
        return "gid://shopify/Product/\(self)".data(using: .utf8)?.base64EncodedString()
    }
    func encodingProductVariantID()->String?{
        return "gid://shopify/ProductVariant/\(self)".data(using: .utf8)?.base64EncodedString()
    }
}
