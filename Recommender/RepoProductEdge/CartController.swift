//
//  CartController.swift
//  Recommender
//
//  Created by huangmin on 07/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
import MobileBuySDK
import RxSwift
import RxCocoa
class CartController{
    // MARK: declare variables
    static let shared : CartController = CartController()
    var productEdgesVariable : Variable<[Storefront.ProductEdge]> = Variable([])
    func addToCart(_ productEdge : Storefront.ProductEdge?) {
        guard let productEdge = productEdge else { return }
        let flag = productEdgesVariable.value.contains(productEdge)
        if !flag {
            productEdgesVariable.value.append(productEdge)
        }
    }
}
