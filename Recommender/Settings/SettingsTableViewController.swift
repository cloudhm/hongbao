//
//  SettingsTableViewController.swift
//  Recommender
//
//  Created by huangmin on 12/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    var settingsBeans : [SettingsBean] = SettingsManager.shared.settingsBeans
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "设置"
        let view = UIView()
        tableView.tableHeaderView = view
        tableView.tableFooterView = view
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsBeans.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SettingsCell = tableView.dequeueReusableCell(withIdentifier: String(describing:SettingsCell.self), for: indexPath) as! SettingsCell
        cell.settingsBean = settingsBeans[indexPath.row]
        cell.saveAction = { [weak self] in
            SettingsBean.flushedSettingConfigurationsToPlist(self?.settingsBeans)
            self?.view.endEditing(true)
        }
        return cell
    }
    @IBAction func tapAction(_ sender: Any) {
        SettingsManager.shared.reset()
        settingsBeans = SettingsManager.shared.settingsBeans
        tableView.reloadData()
    }
}
