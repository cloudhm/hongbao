//
//  InfluencerDetailTableViewController.swift
//  Recommender
//
//  Created by huangmin on 13/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire
import MBProgressHUD
/**
 * tips:
 * 1. merge action, only merge newElements into oldElements, cannot support to remove some properties
 * 2. social disable, please invoke delete related method
 */
class InfluencerDetailTableViewController: UITableViewController {
    var influencer : Influencer? {
        willSet {
            guard let newInfluencer = newValue else {
                return
            }
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(newInfluencer)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let influencerInfoJSON = json as? [String : Any] else {
                    return
                }
                self.influencerInfoJSON = influencerInfoJSON
                guard let influencerSocialsJSON = influencerInfoJSON[Influencer.InfluencerKeys.socials.rawValue] as? [[String : Any]] else {
                    return
                }
                self.influecerSocialsJSON = influencerSocialsJSON
            } catch {
                
            }
        }
    }
    var influencerInfoJSON : [String : Any] = [:]
    var influecerSocialsJSON : [[String : Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Edit Influencer"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submit))
        let view = UIView()
        tableView.tableHeaderView = view
        tableView.tableFooterView = view
        tableView.register(InfluencerHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing:InfluencerHeaderView.self))
    }
    @objc func submit(_ sender : UIBarButtonItem) {
        view.endEditing(true)
        tableView.reloadData()
        debugPrint(influencerInfoJSON)
        debugPrint(influecerSocialsJSON)
        influecerSocialsJSON = (influecerSocialsJSON.map{
            if ($0[InfluencerSocial.InfluencerSocialKeys.type.rawValue] != nil || $0[InfluencerSocial.InfluencerSocialKeys.handle.rawValue] != nil) {
                return $0
            }
            return nil
            } as [[String : Any]?]).flatMap{$0}
        tableView.reloadData()
        influencerInfoJSON[Influencer.InfluencerKeys.socials.rawValue] = influecerSocialsJSON
        // put
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return influecerSocialsJSON.count
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell : InfluencerInfoCell = tableView.dequeueReusableCell(withIdentifier: String(describing:InfluencerInfoCell.self), for: indexPath) as! InfluencerInfoCell
            cell.influencerInfo = influencerInfoJSON
            cell.action = { [weak self] handle in
                guard let handle = handle else {
                    let controller = UIAlertController(title: "Error", message: "url invalidate", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    controller.addAction(okAction)
                    self?.navigationController?.present(controller, animated: true, completion: nil)
                    return
                }
                let safari = SFSafariViewController(url: handle)
                self?.navigationController?.present(safari, animated: true, completion: nil)
            }
            cell.updatedAction = { [weak self] influencerInfoJSON in
                self?.influencerInfoJSON.merge(influencerInfoJSON){(_, new) in new}
            }
            return cell
        } else if indexPath.section == 1 {
            let cell : InfluencerSocialTableViewCell =  tableView.dequeueReusableCell(withIdentifier: String(describing:InfluencerSocialTableViewCell.self), for: indexPath) as! InfluencerSocialTableViewCell
            cell.influencerSocialJSON = influecerSocialsJSON[indexPath.row]
            cell.browseAction = { [weak self] handle in
                guard let handle = handle else {
                    let controller = UIAlertController(title: "Error", message: "url invalidate", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    controller.addAction(okAction)
                    self?.navigationController?.present(controller, animated: true, completion: nil)
                    return
                }
                let safari = SFSafariViewController(url: handle)
                self?.navigationController?.present(safari, animated: true, completion: nil)
            }
            cell.socialChooseAction = { [weak self] sender in
                let controller = UIAlertController(title: "Choose", message: nil, preferredStyle: .actionSheet)
                let instagramAction = UIAlertAction(title: "Instagram", style: .default, handler: {[weak self] (action) in
                    let influencerSocialType : InfluencerSocial.InfluencerSocialType = InfluencerSocial.InfluencerSocialType.instagram
                    sender.setTitle(influencerSocialType.rawValue, for: .normal)
                    self?.influecerSocialsJSON[indexPath.row].merge(influencerSocialType.socialInfo()){(_, new) in new}
                })
                let facebookAction = UIAlertAction(title: "Facebook", style: .default, handler: { (action) in
                    let influencerSocialType : InfluencerSocial.InfluencerSocialType = InfluencerSocial.InfluencerSocialType.facebook
                    sender.setTitle(influencerSocialType.rawValue, for: .normal)
                    self?.influecerSocialsJSON[indexPath.row].merge(influencerSocialType.socialInfo()){(_, new) in new}
                })
                let youtubeAction = UIAlertAction(title: "Youtube", style: .default, handler: { (action) in
                    let influencerSocialType : InfluencerSocial.InfluencerSocialType = InfluencerSocial.InfluencerSocialType.youtube
                    sender.setTitle(influencerSocialType.rawValue, for: .normal)
                    self?.influecerSocialsJSON[indexPath.row].merge(influencerSocialType.socialInfo()){(_, new) in new}
                })
                let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
                controller.addAction(instagramAction)
                controller.addAction(facebookAction)
                controller.addAction(youtubeAction)
                controller.addAction(cancelAction)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let popPresenter = controller.popoverPresentationController
                    popPresenter?.sourceView = sender
                    popPresenter?.sourceRect = sender.frame
                    self?.present(controller, animated: true, completion: nil)
                } else {
                    self?.navigationController?.present(controller, animated: true, completion: nil)
                }
            }
            cell.updateAction = { [weak self] influencerInfoJSON in
                self?.influecerSocialsJSON[indexPath.row] = influencerInfoJSON
            }
            return cell
        } else {
            let cell : InfluencerAddTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing:InfluencerAddTableViewCell.self), for: indexPath) as! InfluencerAddTableViewCell
            return cell
        }

    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view : InfluencerHeaderView? = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing:InfluencerHeaderView.self)) as? InfluencerHeaderView
        if view == nil {
            view = InfluencerHeaderView.init(reuseIdentifier: String(describing:InfluencerHeaderView.self))
        }
        if section == 0 {
            view?.titleLabel.text = "Basic Info"
        } else if section == 1{
            view?.titleLabel.text = "Socials"
        }
        return view
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1{
            return 40.0
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            influecerSocialsJSON.append([:])
            tableView.reloadData()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
