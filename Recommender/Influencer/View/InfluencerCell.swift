//
//  InfluencerCell.swift
//  Recommender
//
//  Created by huangmin on 12/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit

class InfluencerCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var action : ((_ influencerSocial : InfluencerSocial) -> Void)?
    var editInfluencer : ((_ influencer : Influencer) ->Void)?
    var influencer : Influencer? {
        willSet {
            avatarImageView.sd_setImage(with: newValue?.image, placeholderImage: nil, options: .retryFailed, completed: nil)
            nameLabel.text = newValue?.name
            websiteLabel.text = newValue?.handle.description
        }
        didSet {
            collectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    @IBAction func tapAction(_ sender: Any) {
        guard let influencer = influencer else {return}
        editInfluencer?(influencer)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return influencer?.socials?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : InfluencerSocialCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing:InfluencerSocialCell.self), for: indexPath) as! InfluencerSocialCell
        cell.influencerSocial = influencer?.socials?[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let social = influencer?.socials?[indexPath.item] else {return}
        action?(social)
    }
}
class InfluencerSocialCell : UICollectionViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    var influencerSocial : InfluencerSocial? {
        willSet{
                        avatarImageView.sd_setImage(with: newValue?.image, placeholderImage: nil, options: .retryFailed, completed: nil)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
