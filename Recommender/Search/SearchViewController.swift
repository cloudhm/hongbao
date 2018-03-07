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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var products : [Storefront.Product]?
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
    }
    private func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(tapAction))
    }
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SearchCell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchCell.self)) as! SearchCell
        cell.product = products?[indexPath.row]
        return cell
    }
    // MARK: UITableVIewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let safari = SFSafariViewController(url: URL(string: "https://whatsmode.com/products/"+(products?[indexPath.row].handle ?? ""))!)
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
        let ids : [GraphQL.ID] = (text.split(separator: ",").map{
            GraphQL.ID(rawValue: String($0).getIntNumber()?.encodingProductID())
        } as [GraphQL.ID?]).flatMap{$0}
        if ids.count > 0 {
            MBProgressHUD.showAnimationView(self.navigationController?.view)
            _ = Client.shared.queryProductsByIDs(ids) { [weak self] (products, errMsg) in
                MBProgressHUD.hide(self?.navigationController?.view)
                if errMsg != nil {
                    let controller = UIAlertController(title: "Error", message: errMsg, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    controller.addAction(okAction)
                    self?.navigationController?.present(controller, animated: true, completion: nil)
                } else {
                    self?.products = products
                    self?.tableView.reloadData()
                }
            }
        }
    }
    @objc func tapAction(){
        performSegue(withIdentifier: "searchToCart", sender: nil)
    }
}
