//
//  ShopifyProductsTableViewController.swift
//  Recommender
//
//  Created by huangmin on 04/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit
import MobileBuySDK
import MJRefresh
import SafariServices
class ShopifyProductsTableViewController: UITableViewController {
    var pageInfo : Storefront.PageInfo?
    var productEdges : [Storefront.ProductEdge] = []
    var task : Task? {
        didSet{
            oldValue?.cancel()
        }
    }
    var loading : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        let view = UIView()
        tableView.tableHeaderView = view
        tableView.tableFooterView = view
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
        tableView.mj_header.beginRefreshing()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DeferredHandle.shared.action()
    }
    private func configureNavigationItem(){
        navigationItem.title = "Shopify商品库"
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return productEdges.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ShopifyProductCell.self), for: indexPath) as! ShopifyProductCell
        cell.product = productEdges[indexPath.row].node
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let safari = SFSafariViewController(url: URL(string: "https://whatsmode.com/products/"+productEdges[indexPath.row].node.handle)!)
        navigationController?.present(safari, animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !(pageInfo?.hasNextPage ?? false) {
            return
        }
        if tableView.mj_header.isRefreshing || loading {
            return
        }
        if (productEdges.count - indexPath.row) < 50 {
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
        let cursor = refresh ? nil : productEdges.last?.cursor
        task = Client.shared.queryProductListBy(cursor, refresh) { [weak self] (productConnection, errMsg) in
            self?.tableView.mj_header.endRefreshing()
            guard let productConnection = productConnection else {
                self?.loading = false
                return
            }
            self?.pageInfo = productConnection.pageInfo
            if refresh {
                self?.productEdges = productConnection.edges
            } else {
                self?.productEdges += productConnection.edges
            }
            self?.tableView.reloadData()
            self?.loading = false
        }
    }
    @IBAction func showTips(_ sender: Any) {
        let controller = UIAlertController.init(title: "提示", message: "Support as below:\n1) ids.txt which is a utf8 plain file(eg: 1,2,3,4,5)\n2) ids.csv which only one column id\n3)products_export.csv which is exported from shopify dashboard, please remove `Body` column", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        controller.addAction(okAction)
        navigationController?.present(controller, animated: true, completion: nil)
    }
}

