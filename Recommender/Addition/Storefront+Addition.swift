//
//  Storefront+Addition.swift
//  Recommender
//
//  Created by huangmin on 07/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
import MobileBuySDK
extension Storefront.Product : Equatable {
    public static func ==(lhs: Storefront.Product, rhs: Storefront.Product) -> Bool {
        return lhs.id.rawValue == rhs.id.rawValue
    }
}
