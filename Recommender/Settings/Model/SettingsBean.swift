//
//  SettingsBean.swift
//  Recommender
//
//  Created by huangmin on 12/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
enum SettingsBeanType {
    case influencer
    case product
}
class SettingsManager {
    static let shared = SettingsManager()
    var settingsBeans : [SettingsBean] = SettingsBean.fetchSettingConfigurationsFromPlist()
    func getURL(_ settingsBeanType : SettingsBeanType) -> String {
        for settingsBean in settingsBeans {
            switch settingsBeanType {
            case .influencer:
                if settingsBean.title == "Influencer" {
                    return settingsBean.path()
                }
            case .product:
                if settingsBean.title == "Product" {
                    return settingsBean.path()
                }
            }
        }
        return ""
    }
}
final class SettingsBean : Decodable, Encodable {
    var title : String
    var host : String
    var port : String
    var edited : Bool = false // only for UI
    enum SettingsBeanKeys : String, CodingKey {
        case title
        case host
        case port
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: SettingsBeanKeys.self)
        title = try values.decode(String.self, forKey: .title)
        host = try values.decode(String.self, forKey: .host)
        port = try values.decode(String.self, forKey: .port)
    }
    static func fetchSettingConfigurationsFromPlist()->[SettingsBean]{
        let exist = FileManager.default.fileExists(atPath: documentPath().path)
        if !exist {
            let dicts : [[String: String]] = [["title":"Influencer","host":"192.168.20.43","port":"3000"],["title":"Product","host":"192.168.20.43","port":"3000"]]
            (dicts as NSArray).write(to: documentPath(), atomically: true)
        }
        let array = NSArray(contentsOf: documentPath())! as Array
        let decoder = JSONDecoder()
        return (array.map{
            do {
                return try decoder.decode(SettingsBean.self, from: JSONSerialization.data(withJSONObject: $0, options: []))
            }catch {
                return nil
            }
            } as [SettingsBean?]).flatMap{$0}
    }
    static func flushedSettingConfigurationsToPlist(_ settingsBeans : [SettingsBean]?) {
        guard let settingsBeans = settingsBeans else { return }
        var dicts : [[String : String]] = []
        for settingsBean in settingsBeans {
            var dict : [String : String] = [:]
            dict[SettingsBeanKeys.title.rawValue] = settingsBean.title
            dict[SettingsBeanKeys.host.rawValue] = settingsBean.host
            dict[SettingsBeanKeys.port.rawValue] = settingsBean.port
            dicts.append(dict)
        }
        (dicts as NSArray).write(to: documentPath(), atomically: true)
    }
    static func documentPath()->URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/Settings.plist"
        return URL(fileURLWithPath: path)
    }
    func path()->String{
        let settingsBeanHost = host.trimmingCharacters(in: .whitespacesAndNewlines)
        let settingsBeanPort = port.trimmingCharacters(in: .whitespacesAndNewlines)
        var settingsBeanPath = "http://"
        if settingsBeanHost.count > 0 {
            settingsBeanPath += settingsBeanHost
        }
        if settingsBeanPort.count > 0 {
            settingsBeanPath += (":" + settingsBeanPort + "/")
        } else {
            settingsBeanPath += "/"
        }
        return settingsBeanPath
    }
}
