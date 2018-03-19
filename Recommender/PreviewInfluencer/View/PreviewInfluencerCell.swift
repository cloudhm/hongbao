//
//  PreviewInfluencerCell.swift
//  Recommender
//
//  Created by huangmin on 19/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit

class PreviewInfluencerCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var numberLabel: UILabel!
    var action : ((_ influencerSocial : InfluencerSocial) -> Void)?
    var influencer : Influencer? {
        willSet{
            avatarImageView.sd_setImage(with: newValue?.image,
                                        placeholderImage: nil,
                                        options: .retryFailed,
                                        completed: nil)
            nameLabel.text = newValue?.name
            handleLabel.text = newValue?.handle.description
            guard let id = newValue?.id else {
                numberLabel.text = "new"
                return
            }
            numberLabel.text = "\(id)"
        }
        didSet {
            collectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return influencer?.socials?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : PreviewInfluencerSocialCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing:PreviewInfluencerSocialCell.self), for: indexPath) as! PreviewInfluencerSocialCell
        cell.influencerSocial = influencer?.socials?[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let social = influencer?.socials?[indexPath.item] else {return}
        action?(social)
    }
}
