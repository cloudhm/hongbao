//
//  RecommenderViewController.swift
//  Recommender
//
//  Created by huangmin on 07/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire
import MJRefresh
import MBProgressHUD
class RecommenderViewController: UITableViewController {
    // MARK: declare variables
    var recommenderProducts : [RecommenderProduct] = []
    var dataRequest : DataRequest? {
        didSet{
            dataRequest?.cancel()
        }
    }
    var loading : Bool = false
    var currentPage : Int = 0
    let size : Int = 10
    var last : Bool = false
    // MARK: initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView()
        tableView.tableHeaderView = view
        tableView.tableFooterView = view
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
        tableView.mj_header.beginRefreshing()
        configureNavigationItem()
    }
    private func configureNavigationItem(){
        navigationItem.title = "Recommender Server"
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommenderProducts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : RecommenderCell = tableView.dequeueReusableCell(withIdentifier: String(describing:RecommenderCell.self), for: indexPath) as! RecommenderCell
        cell.recommenderProduct = recommenderProducts[indexPath.row]
        cell.action = { [weak self] (recommenderProduct, isOn) in
            self?.putProductPropertyTop(recommenderProduct, isOn)
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let safari = SFSafariViewController(url: URL(string: "https://whatsmode.com/products/"+(recommenderProducts[indexPath.row].handle ?? ""))!)
        navigationController?.present(safari, animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.mj_header.isRefreshing || loading {
            return
        }
        if last {
            return
        }
        if recommenderProducts.count < size {
            return
        }
        if (recommenderProducts.count - indexPath.row) < size {
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
        dataRequest = RESTfulAPI.getProducts(page, size) { [weak self] (recommenderProducts, last) in
            self?.tableView.mj_header.endRefreshing()
            guard let recommenderProducts = recommenderProducts,
                let last = last else {
                self?.loading = false
                return
            }
            self?.last = last
            if refresh {
                self?.recommenderProducts = recommenderProducts
            } else {
                self?.recommenderProducts += recommenderProducts
            }
            self?.tableView.reloadData()
            self?.loading = false
        }
    }
    private func putProductPropertyTop(_ recommenderProduct : RecommenderProduct?, _ isOn : Bool) {
        guard let recommenderProduct = recommenderProduct else { return }
        MBProgressHUD.showAnimationView(self.navigationController?.view)
        _ = RESTfulAPI.putProduct("\(recommenderProduct.id)", isOn) { [weak self] recommenderProduct in
            MBProgressHUD.hide(self?.navigationController?.view)
            guard let recommenderProduct = recommenderProduct,
            let index = self?.recommenderProducts.index(of: recommenderProduct) else {
                self?.tableView.reloadData()
                return
            }
            if index != NSNotFound {
                self?.recommenderProducts[index] = recommenderProduct
            }
            self?.tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MBProgressHUD.showAnimationView(self.navigationController?.view)
            _ = RESTfulAPI.delProduct("\(recommenderProducts[indexPath.row].id)") { [weak self] error in
                MBProgressHUD.hide(self?.navigationController?.view)
                guard let error = error else {
                    self?.recommenderProducts.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .right)
                    return
                }
                let controller = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                controller.addAction(okAction)
                self?.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }
}
