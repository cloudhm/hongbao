//
//  CartViewController.swift
//  Recommender
//
//  Created by huangmin on 07/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit
import MobileBuySDK
import SafariServices
import MBProgressHUD
class CartViewController: UITableViewController {
    let uploadMaxCount : Int = 100
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView()
        tableView.tableHeaderView = view
        tableView.tableFooterView = view
        configureNavigationItem()
    }
    private func configureNavigationItem(){
        navigationItem.title = "My Cart(\(CartController.shared.productsVariable.value.count))"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submit))
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CartController.shared.productsVariable.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CartItemCell = tableView.dequeueReusableCell(withIdentifier: String(describing:CartItemCell.self), for: indexPath) as! CartItemCell
        cell.product = CartController.shared.productsVariable.value[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CartController.shared.productsVariable.value.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .right)
            configureNavigationItem()
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let safari = SFSafariViewController(url: URL(string: "https://whatsmode.com/products/"+CartController.shared.productsVariable.value[indexPath.row].handle)!)
        navigationController?.present(safari, animated: true, completion: nil)
    }
    @objc func submit() {
        // API POST
        MBProgressHUD.showAnimationView(self.navigationController?.view)
        var ids : [String] = []
        for (index, product) in CartController.shared.productsVariable.value.enumerated() {
            if index >= uploadMaxCount {
                break
            }
            guard let id = product.id.rawValue.decodingGraphID() else {
                continue
            }
            ids.append("\(id)")
        }
        _ = RESTfulAPI.postProductsIDs(ids) {[weak self] notfoundIDs, error in
            MBProgressHUD.hide(self?.navigationController?.view)
            guard let error = error else {
                guard let notfoundIDs = notfoundIDs else {
                    return
                }
                if notfoundIDs.count > 0 {
                    self?.showAlert("Not found items", notfoundIDs.description)
                    var products : [Storefront.Product] = []
                    for (index, product) in CartController.shared.productsVariable.value.enumerated() {
                        if index >= (self?.uploadMaxCount ?? 1) {
                            break
                        }
                        if notfoundIDs.contains(Int(product.id.rawValue.decodingGraphID()!)) {
                            products.append(product)
                        }
                    }
                    CartController.shared.productsVariable.value.removeSubrange(0 ..< min((self?.uploadMaxCount ?? 1),ids.count))
                    CartController.shared.productsVariable.value = products + CartController.shared.productsVariable.value
                } else {
                    CartController.shared.productsVariable.value.removeSubrange(0 ..< min((self?.uploadMaxCount ?? 1),ids.count))
                    if CartController.shared.productsVariable.value.count > 0 {
                        self?.submit()
                    } else {
                        self?.showAlert("Tips", "uploading task finished")
                    }
                }
                self?.tableView.reloadData()
                self?.configureNavigationItem()
                return
            }
            self?.showAlert("Error", error.localizedDescription)
        }
    }
    func showAlert(_ title : String, _ content : String) {
        let controller = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
}
