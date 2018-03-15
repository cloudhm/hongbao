//
//  RecommenderCell.swift
//  Recommender
//
//  Created by huangmin on 07/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit

class RecommenderCell: UITableViewCell {
    // MARK: declare outlets
    @IBOutlet weak var productIdLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var topSwitch: UISwitch!
    var action : ((_ recommenderProduct : RecommenderProduct?, _ isOn : Bool)->Void)?
    // MARK: declare variables
    var recommenderProduct : RecommenderProduct? {
        willSet {
            guard let newProduct = newValue else { return }
            productIdLabel.text = "\(newProduct.id)"
            productImageView.sd_setImage(with: newProduct.image, placeholderImage: nil, options: .retryFailed, completed: nil)
            productTitleLabel.text = newProduct.title
            productPriceLabel.text = newProduct.min_price?.formatPrice()
            topSwitch.isOn = newProduct.top ?? false
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        topSwitch.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    @objc func valueChanged(_ sender : UISwitch) {
        action?(recommenderProduct,sender.isOn)
    }
}
