//
//  SettingsCell.swift
//  Recommender
//
//  Created by huangmin on 12/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var hostTF: UITextField!
    @IBOutlet weak var portTF: UITextField!
    var saveAction : (()->Void)?
    weak var settingsBean : SettingsBean? {
        willSet{
            titleLabel.text = newValue?.title
            actionBtn.setTitle(newValue?.edited ?? false ? "Done" : "Edit", for: .normal)
            hostTF.text = newValue?.host
            portTF.text = newValue?.port
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        hostTF.delegate = self
        portTF.delegate = self
    }
    
    @IBAction func tapAction(_ sender: UIButton) {
        settingsBean?.edited = !(settingsBean?.edited ?? false)
        actionBtn.setTitle(settingsBean?.edited ?? false ? "Done" : "Edit", for: .normal)
        if !(settingsBean?.edited ?? false) {
            settingsBean?.host = hostTF.text ?? ""
            settingsBean?.port = portTF.text ?? ""
            saveAction?()
        }
    }
}
extension SettingsCell : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return settingsBean?.edited ?? false
    }
}
