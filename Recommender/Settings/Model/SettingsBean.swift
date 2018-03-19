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
                if settingsBean.title == "网红" {
                    return settingsBean.path()
                }
            case .product:
                if settingsBean.title == "商品" {
                    return settingsBean.path()
                }
            }
        }
        return ""
    }
    func reset(){
        SettingsBean.reset()
        settingsBeans = SettingsBean.fetchSettingConfigurationsFromPlist()
    }
}
final class SettingsBean : Decodable, Encodable {
    var title : String
    var host : String
    var port : String
    var edited : Bool = false // only for UI
    var isHttps : Bool = true
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
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SettingsBeanKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(host, forKey: .host)
        try container.encode(port, forKey: .port)
    }
    static func fetchSettingConfigurationsFromPlist()->[SettingsBean]{
        let exist = FileManager.default.fileExists(atPath: documentPath().path)
        if !exist {
            let dicts : [[String: String]] = [["title":"网红",
                                               "host":"test.whatsmode.com/formula-1.1-storefront",
                                               "port":""],
                                              ["title":"商品",
                                               "host":"test.whatsmode.com/formula-1.1-storefront",
                                               "port":""]]
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
        let encoder = JSONEncoder()
        do  {
            let data = try encoder.encode(settingsBeans)
            let dicts = try JSONSerialization.jsonObject(with: data, options: [])
            guard let array = dicts as? [[String:String]] else { return }
            (array as NSArray).write(to: documentPath(), atomically: true)
        } catch {
            
        }
    }
    static func documentPath()->URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/Settings.plist"
        return URL(fileURLWithPath: path)
    }
    func path()->String{
        let settingsBeanHost = host.trimmingCharacters(in: .whitespacesAndNewlines)
        let settingsBeanPort = port.trimmingCharacters(in: .whitespacesAndNewlines)
        var settingsBeanPath = isHttps ? "https://" : "http://"
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
    static func reset(){
        do  {
            try FileManager.default.removeItem(at: documentPath())
        } catch {
            
        }
    }
}
