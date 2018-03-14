//
//  InfluencerInfoCell.swift
//  Recommender
//
//  Created by huangmin on 13/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit

class InfluencerInfoCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarUrlLabel: UILabel!
    @IBOutlet weak var handleTF: UITextField!
    var action : ((_ handle : URL?)->Void)?
    var updatedAction : ((_ influencerInfo : [String : Any])->Void)?
    var uploadAction : (()->Void)?
    var influencerInfo : [String : Any]? {
        willSet {
            nameTF.text = newValue?[Influencer.InfluencerKeys.name.rawValue] as? String
            avatarImageView.sd_setImage(with: newValue?[Influencer.InfluencerKeys.image.rawValue] as? URL, placeholderImage: nil, options: .retryFailed, completed: nil)
            avatarUrlLabel.text = (newValue?[Influencer.InfluencerKeys.image.rawValue] as? URL)?.description
            handleTF.text = (newValue?[Influencer.InfluencerKeys.handle.rawValue] as? URL)?.description
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        nameTF.delegate = self
        handleTF.delegate = self
    }
    @IBAction func tapAction(_ sender: UIButton) {
        action?(URL(string: handleTF.text ?? ""))
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField == nameTF {
            influencerInfo?[Influencer.InfluencerKeys.name.rawValue] = textField.text
        } else if textField == handleTF {
            influencerInfo?[Influencer.InfluencerKeys.handle.rawValue] = URL(string: textField.text ?? "")
        }
        guard let influencerInfo = influencerInfo else {return}
        updatedAction?(influencerInfo)
    }
}
