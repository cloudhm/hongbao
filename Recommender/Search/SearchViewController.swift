//
//  SearchViewController.swift
//  Recommender
//
//  Created by huangmin on 07/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit
import MobileBuySDK
import SafariServices
import MBProgressHUD
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    // MARK: declare variables
    var preText : String?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var productEdges : [Storefront.ProductEdge] = []
    var pageInfo : Storefront.PageInfo?
    var task : Task? {
        didSet {
            oldValue?.cancel()
        }
    }
    var loading : Bool = false
    // MARK: initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView()
        tableView.tableHeaderView = view
        tableView.tableFooterView = view
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: String(describing: SearchCell.self), bundle: nil), forCellReuseIdentifier: String(describing: SearchCell.self))
        configureNavigationItem()
        searchBar.text = preText
        searchBarSearchButtonClicked(searchBar)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DeferredHandle.shared.action()
    }
    private func configureNavigationItem() {
        let cartBarButtonItem = UIBarButtonItem(title: "仓库", style: .done, target: self, action: #selector(tapAction))
        let addAllBarButtonItem = UIBarButtonItem(title: "全加",style: .done, target: self, action: #selector(addAll))
        navigationItem.rightBarButtonItems = [cartBarButtonItem,addAllBarButtonItem]
    }
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productEdges.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SearchCell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchCell.self)) as! SearchCell
        cell.product = productEdges[indexPath.row].node
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if loading == false {
            return
        }
        if !(pageInfo?.hasNextPage ?? false) {
            return
        }
        if (productEdges.count - indexPath.row) < 10 {
            search(searchBar.text?.trimmingCharacters(in: .whitespaces))
        }
    }
    // MARK: UITableVIewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let safari = SFSafariViewController(url: productEdges[indexPath.row].node.onlineStoreUrl!)
        navigationController?.present(safari, animated: true, completion: nil)
    }
    // MARK: UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        if text.count == 0 {
            return
        }
        productEdges.removeAll()
        pageInfo = nil
        tableView.reloadData()
        loading = false
        task = nil
        search(text)
    }
    private func search(_ text : String?){
        guard let text = text else { return }
        if text.count == 0 { return }
        if loading {
            return
        }
        loading = true
        MBProgressHUD.showAnimationView(self.navigationController?.view)
        _ = Client.shared.queryProducts(text, productEdges.last?.cursor) { [weak self] (productsConnection, errMsg) in
            MBProgressHUD.hide(self?.navigationController?.view)
            if errMsg != nil {
                self?.loading = false
                let controller = UIAlertController(title: "错误", message: errMsg, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
                controller.addAction(okAction)
                self?.navigationController?.present(controller, animated: true, completion: nil)
            } else {
                guard let productsConnection = productsConnection else {
                    self?.loading = false
                    return
                }
                if self?.pageInfo == nil {
                    self?.productEdges = productsConnection.edges
                } else {
                    self?.productEdges += productsConnection.edges
                }
                self?.pageInfo = productsConnection.pageInfo
                self?.tableView.reloadData()
                self?.loading = false
            }
        }
    }
    @objc func tapAction(){
        performSegue(withIdentifier: "searchToCart", sender: nil)
    }
    @objc func addAll(){
        if productEdges.count > 0 {
            for productEdge in productEdges {
                CartController.shared.addToCart(productEdge.node)
            }
            let controller = UIAlertController(title: "提示", message: "所有商品已加入仓库", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            controller.addAction(okAction)
            navigationController?.present(controller, animated: true, completion: nil)
        }
    }
}
