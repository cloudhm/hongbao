//
//  Storefront+Addition.swift
//  Recommender
//
//  Created by huangmin on 07/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
import MobileBuySDK
extension Storefront.ProductEdge : Equatable {
    public static func ==(lhs: Storefront.ProductEdge, rhs: Storefront.ProductEdge) -> Bool {
        return lhs.node.id.rawValue == rhs.node.id.rawValue
    }
}
