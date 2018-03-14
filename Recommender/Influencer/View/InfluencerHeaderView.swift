//
//  InfluencerHeaderView.swift
//  Recommender
//
//  Created by huangmin on 14/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit

class InfluencerHeaderView: UITableViewHeaderFooterView {
    var titleLabel : UILabel!
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerX.equalTo(0)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
