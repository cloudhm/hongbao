//
//  InfluencersTableViewController.swift
//  Recommender
//
//  Created by huangmin on 12/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire
import MJRefresh
import MBProgressHUD
class InfluencersTableViewController: UITableViewController {
    var  influencers : [Influencer] = []
    var dataRequest : DataRequest? {
        didSet{
            oldValue?.cancel()
        }
    }
    var loading : Bool = false
    var currentPage : Int = 0
    let size : Int = 10
    var last : Bool = false
    private var documentInteractionController : UIDocumentInteractionController?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "网红列表"
        let view = UIView()
        tableView.tableHeaderView = view
        tableView.tableFooterView = view
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
        tableView.mj_header.beginRefreshing()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return influencers.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : InfluencerCell = tableView.dequeueReusableCell(withIdentifier: String(describing:InfluencerCell.self), for: indexPath) as! InfluencerCell
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
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.mj_header.isRefreshing || loading {
            return
        }
        if last {
            return
        }
        if influencers.count < size {
            return
        }
        if (influencers.count - indexPath.row) < size {
            loadData(false)
        }
    }
    @objc func refreshData(_ refreshComponent : MJRefreshComponent) {
        loading = false
        loadData(true)
    }
    func loadData(_ refresh : Bool) {
        if loading {
            return
        }
        loading = true
        let page = refresh ? 0 : (currentPage + 1)
        dataRequest = RESTfulAPI.getInfluencers(page, size) { [weak self] (influencers, last) in
            self?.tableView.mj_header.endRefreshing()
            guard let influencers = influencers,
                let last = last else {
                self?.loading = false
                return
            }
            self?.last = last
            self?.currentPage = page
            if refresh {
                self?.influencers = influencers
            } else {
                self?.influencers += influencers
            }
            self?.tableView.reloadData()
            self?.loading = false
        }
    }
    @IBAction func convertCSVToShare(_ sender: UIBarButtonItem) {
        guard let filePath = Influencer.convertToCSV(influencers) else {
            debugPrint("convert failed")
            return
        }
        let url = URL(fileURLWithPath: filePath)
        documentInteractionController = UIDocumentInteractionController()
        documentInteractionController?.uti = "com.microsoft.excel.xls"
        documentInteractionController?.url = url
        documentInteractionController?.delegate = self
        documentInteractionController?.presentOpenInMenu(from: view.bounds, in: view, animated: true)
    }
}
extension InfluencersTableViewController : UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerWillPresentOpenInMenu(_ controller: UIDocumentInteractionController) {
        print("will present")
    }
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        print("did miss")
    }
}

