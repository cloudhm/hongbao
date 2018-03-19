//
//  PreviewInfluencerViewController.swift
//  Recommender
//
//  Created by huangmin on 19/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit
import SafariServices
class PreviewInfluencerViewController: UITableViewController {
    var influencers : [Influencer]!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(submit))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return influencers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : PreviewInfluencerCell = tableView.dequeueReusableCell(withIdentifier: String(describing:PreviewInfluencerCell.self), for: indexPath) as! PreviewInfluencerCell
        cell.influencer = influencers[indexPath.row]
        cell.action = { [weak self] influencerSocial in
            guard let handle = influencerSocial.handle else {return}
            let safari = SFSafariViewController(url: handle)
            self?.navigationController?.present(safari, animated: true, completion: nil)
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let safari = SFSafariViewController(url: influencers[indexPath.row].handle)
        navigationController?.present(safari, animated: true, completion: nil)
    }
    @objc func submit(_ sender : UIBarButtonItem) {
        var influencersJSON : [[String : Any]] = []
        let encoder = JSONEncoder()
        for influencer in influencers {
            do {
                let influencerData = try encoder.encode(influencer)
                let json = try JSONSerialization.jsonObject(with: influencerData, options: [])
                guard let influencerJSON = json as? [String : Any] else {
                    continue
                }
                influencersJSON.append(influencerJSON)
            } catch {
                
            }
        }
        DeferredHandle.submitInfluencerAction(influencersJSON)
    }
}
