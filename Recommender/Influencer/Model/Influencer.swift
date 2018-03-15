//
//  Influencer.swift
//  Recommender
//
//  Created by huangmin on 12/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
import Alamofire
final class Influencer : Decodable, Encodable {
    var name : String
    var image : URL
    var handle : URL
    var socials : [InfluencerSocial]?
    var id : Int?
    var tags : String?
    enum InfluencerKeys : String, CodingKey {
        case name
        case image
        case handle
        case socials
        case id
        case tags
    }
    // Decodeable
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: InfluencerKeys.self)
        name = try values.decode(String.self, forKey: .name)
        image = try values.decode(URL.self, forKey: .image)
        handle = try values.decode(URL.self, forKey: .handle)
        socials = try values.decodeIfPresent(Array.self, forKey: .socials)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        tags = try values.decodeIfPresent(String.self, forKey: .tags)
    }
    // Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InfluencerKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(image, forKey: .image)
        try container.encode(handle, forKey: .handle)
        try container.encodeIfPresent(socials, forKey: .socials)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(tags, forKey: .tags)
    }
    /**
     * convert influencers JSON
     */
    static func convertInfluencersJSON(_ list : [[String]]) -> [[String : Any]] {
        func socialJSON(_ line : [String],
                        _ handleIndex : Int?,
                        _ idIndex : Int?)->[String : Any]? {
            guard let handleIndex = handleIndex,
                let handle = URL(string: line[handleIndex]),
                let socialType = InfluencerSocial.InfluencerSocialType.inferSocialType(handle) else {return nil}
            var socailJSON : [String : Any] = [:]
            socailJSON[InfluencerSocial.InfluencerSocialKeys.handle.rawValue] = handle.description
            if idIndex != nil {
                let id = Int(line[idIndex!])
                socailJSON[InfluencerSocial.InfluencerSocialKeys.id.rawValue] = id
            }
            socailJSON.merge(socialType.socialInfo()) {(_, new) in new}
            return socailJSON
        }
        guard let fields : [String] = list.first else {
            return []
        }
        var influencersJSON : [[String:Any]] = []
        var indexOfName : Int?
        var indexOfID : Int?
        var indexOfImage : Int?
        var indexOfHandle : Int?
        var indexOfSocialsHandle : Int?
        var indexOfSocialsID : Int?
        var indexOfTags : Int?
        var indexOfSocialsArchived : Int?
        for (index, field) in fields.enumerated() {
            if !(field.range(of: InfluencerKeys.name.rawValue, options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfName = index
            } else if !(field.range(of: InfluencerKeys.image.rawValue, options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfImage = index
            } else if !(field.range(of: "SOCIALS_HANDLE", options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfSocialsHandle = index
            } else if !(field.range(of: InfluencerKeys.handle.rawValue, options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfHandle = index
            } else if !(field.range(of: InfluencerKeys.tags.rawValue, options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfTags = index
            } else if !(field.range(of: "SOCIALS_ID", options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfSocialsID = index
            } else if !(field.range(of: InfluencerKeys.id.rawValue, options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfID = index
            } else if !(field.range(of: "SOCIALS_ARCHIVED", options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfSocialsArchived = index
            }
        }
        if indexOfName == nil || indexOfImage == nil || indexOfHandle == nil {
            return []
        }
        for (index, line) in list.enumerated() {
            if index > 0 {
                var influencerJSON : [String : Any] = [:]
                var influencerSocialsJSON : [[String : Any]]? = []
                if line[indexOfName!].trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
                    influencerJSON = influencersJSON.last ?? [:]
                    influencerSocialsJSON = influencerJSON[InfluencerKeys.socials.rawValue] as? [[String : Any]] ?? []
                    influencersJSON.removeLast()
                } else {
                    if indexOfID != nil {
                        influencerJSON[InfluencerKeys.id.rawValue] = line[indexOfID!]
                    }
                    influencerJSON[InfluencerKeys.name.rawValue] = line[indexOfName!]
                    influencerJSON[InfluencerKeys.image.rawValue] = line[indexOfImage!]
                    influencerJSON[InfluencerKeys.handle.rawValue] = line[indexOfHandle!]
                }
                if indexOfTags != nil {
                    influencerJSON[InfluencerKeys.tags.rawValue] = line[indexOfTags!]
                }
                var social_JSON = socialJSON(line, indexOfSocialsHandle, indexOfSocialsID)
                if social_JSON != nil {
                    if indexOfSocialsArchived != nil {
                        social_JSON?[InfluencerSocial.InfluencerSocialKeys.archived.rawValue] = line[indexOfSocialsArchived!].range(of: "true", options: .caseInsensitive)?.isEmpty ?? true ? false : true
                    }
                    influencerSocialsJSON?.append(social_JSON!)
                }
                if influencerSocialsJSON?.count ?? 0 > 0 {
                    influencerJSON[InfluencerKeys.socials.rawValue] = influencerSocialsJSON
                }
                influencersJSON.append(influencerJSON)
            }
        }
        return influencersJSON
    }
    /**
     * convert influencer instances to csv file
     */
    static func convertToCSV(_ influencers : [Influencer]) -> String? {
        let exportFilePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/update_influencers.csv"
        let output : OutputStream = OutputStream(toMemory: ())
        let writer : CHCSVWriter = CHCSVWriter(outputStream: output, encoding: String.Encoding.utf8.rawValue, delimiter: ("," as NSString).character(at: 0))
        // fileds: handle, image, name, id, socials_handle, socials_id, socials_archived
        writer.writeField(Influencer.InfluencerKeys.handle.rawValue)
        writer.writeField(Influencer.InfluencerKeys.image.rawValue)
        writer.writeField(Influencer.InfluencerKeys.name.rawValue)
        writer.writeField(Influencer.InfluencerKeys.id.rawValue)
        writer.writeField("socials_handle")
        writer.writeField("socials_id")
        writer.writeField("socials_archived")
        writer.finishLine()
        for influencer in influencers {
            writer.writeField(influencer.handle)
            writer.writeField(influencer.image)
            writer.writeField(influencer.name)
            writer.writeField(influencer.id)
            if influencer.socials?.isEmpty ?? true {
                writer.finishLine()
            } else {
                for (index, influencerSocial) in influencer.socials!.enumerated() {
                    if index > 0 {
                        writer.writeField(nil)
                        writer.writeField(nil)
                        writer.writeField(nil)
                        writer.writeField(nil)
                    }
                    writer.writeField(influencerSocial.handle)
                    writer.writeField(influencerSocial.id)
                    writer.writeField(influencerSocial.archived ?? false ? "true" : nil)
                    writer.finishLine()
                }
            }
        }
        writer.closeStream()
        let buffer : Data? = output.property(forKey: .dataWrittenToMemoryStreamKey) as? Data
        do  {
            try buffer?.write(to: URL(fileURLWithPath: exportFilePath))
            return exportFilePath
        } catch {
            return nil
        }
    }
}
