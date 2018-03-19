//
//  PreviewInfluencerSocialCell.swift
//  Recommender
//
//  Created by huangmin on 19/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit

class PreviewInfluencerSocialCell: UICollectionViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    var influencerSocial : InfluencerSocial? {
        willSet {
            typeLabel.text = newValue?.type
            guard let id = newValue?.id else {
                numberLabel.text = "new"
                return
            }
            numberLabel.text = "\(id)"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        numberLabel.adjustsFontSizeToFitWidth = true
    }
}
