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
    var productsVariable : Variable<[Storefront.Product]> = Variable([])
    func addToCart(_ product : Storefront.Product?) {
        guard let product = product else { return }
        let flag = productsVariable.value.contains(product)
        if !flag {
            productsVariable.value.append(product)
        }
    }
}
