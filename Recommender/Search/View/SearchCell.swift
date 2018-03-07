//
//  SearchCell.swift
//  Recommender
//
//  Created by huangmin on 07/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit
import MobileBuySDK
class SearchCell: UITableViewCell {
    @IBOutlet weak var productIdLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productOptionsLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    var product : Storefront.Product? {
        willSet {
            guard let newProduct = newValue else { return }
            productIdLabel.text = "\(newProduct.id.rawValue.decodingGraphID() ?? 0)"
            productImageView.sd_setImage(with: newProduct.images.edges.first?.node.src, placeholderImage: nil, options: .retryFailed, completed: nil)
            productTitleLabel.text = newProduct.title
            var productOptions = ""
            for productOption in newProduct.options {
                if productOptions.count > 0 {
                    productOptions += "\n"
                }
                productOptions = productOptions + productOption.name + ":" + productOption.values.joined(separator: ",")
            }
            productOptionsLabel.text = productOptions
            guard let productVariant = newProduct.variants.edges.first?.node else { return }
            productPriceLabel.text = productVariant.price.formatPrice()
        }
    }
    @IBAction func tapAction(_ sender: Any) {
        CartController.shared.addToCart(product)
    }
}
