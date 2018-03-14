//
//  InfluencerSocialTableViewCell.swift
//  Recommender
//
//  Created by huangmin on 13/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit

class InfluencerSocialTableViewCell: UITableViewCell, UITextFieldDelegate{
    @IBOutlet weak var handleTF: UITextField!
    @IBOutlet weak var socialTypeBtn: UIButton!
    var browseAction : ((_ handle : URL?)->Void)?
    var socialChooseAction : ((_ sender : UIButton)->Void)?
    var influencerSocialJSON : [String : Any]? {
        willSet {
            handleTF.text = (newValue?[InfluencerSocial.InfluencerSocialKeys.handle.rawValue] as? URL)?.description
            socialTypeBtn.setTitle((newValue?[InfluencerSocial.InfluencerSocialKeys.type.rawValue] as? String) ?? "Choose", for: .normal)
        }
    }
    var updateAction : ((_ influencerSocialJSON : [String : Any])->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        handleTF.delegate = self
    }
    
    @IBAction func clickBrowseBtn(_ sender: UIButton) {
        browseAction?(URL(string: handleTF.text ?? ""))
    }
    @IBAction func clickSocialTypeBtn(_ sender: UIButton) {
        socialChooseAction?(sender)
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField == handleTF {
            influencerSocialJSON?[InfluencerSocial.InfluencerSocialKeys.handle.rawValue] = URL(string: textField.text ?? "")
        }
        guard let influencerSocialJSON = influencerSocialJSON else {return}
        updateAction?(influencerSocialJSON)
    }
}
