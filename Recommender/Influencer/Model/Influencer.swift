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
    static func convertInfluencersJSON(_ list : [[String]]) -> [[String : Any]] {
        func socialJSON(_ line : [String], _ index : Int?, _ socialType : InfluencerSocial.InfluencerSocialType)->[String : Any]? {
            guard let index = index, let handle = URL(string: line[index]) else {return nil}
            var socailJSON : [String : Any] = [:]
            socailJSON[InfluencerSocial.InfluencerSocialKeys.handle.rawValue] = handle.description
            socailJSON.merge(socialType.socialInfo()) {(_, new) in new}
            return socailJSON
        }
        guard let fields : [String] = list.first else {
            return []
        }
        var influencersJSON : [[String:Any]] = []
        var indexOfName : Int?
        var indexOfImage : Int?
        var indexOfHandle : Int?
        var indexOfInstagram : Int?
        var indexOfFacebook : Int?
        var indexOfYoutube : Int?
        var indexOfTags : Int?
        for (index, field) in fields.enumerated() {
            if !(field.range(of: InfluencerKeys.name.rawValue, options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfName = index
            } else if !(field.range(of: InfluencerKeys.image.rawValue, options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfImage = index
            } else if !(field.range(of: InfluencerKeys.handle.rawValue, options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfHandle = index
            } else if !(field.range(of: InfluencerKeys.tags.rawValue, options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfTags = index
            } else if !(field.range(of: InfluencerSocial.InfluencerSocialType.instagram.rawValue, options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfInstagram = index
            } else if !(field.range(of: InfluencerSocial.InfluencerSocialType.facebook.rawValue, options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfFacebook = index
            } else if !(field.range(of: InfluencerSocial.InfluencerSocialType.youtube.rawValue, options: .caseInsensitive)?.isEmpty ?? true) {
                indexOfYoutube = index
            }
        }
        if indexOfName == nil || indexOfImage == nil || indexOfHandle == nil {
            return []
        }
        for (index, line) in list.enumerated() {
            if index > 0 {
                var influencerJSON : [String : Any] = [:]
                influencerJSON[InfluencerKeys.name.rawValue] = line[indexOfName!]
                influencerJSON[InfluencerKeys.image.rawValue] = line[indexOfImage!]
                influencerJSON[InfluencerKeys.handle.rawValue] = line[indexOfHandle!]
                if indexOfTags != nil {
                    influencerJSON[InfluencerKeys.tags.rawValue] = line[indexOfTags!]
                }
                var influencerSocialsJSON : [[String : Any]] = []
                let instagramSocial = socialJSON(line, indexOfInstagram, .instagram)
                if instagramSocial != nil {
                    influencerSocialsJSON.append(instagramSocial!)
                }
                let facebookSocial = socialJSON(line, indexOfFacebook, .facebook)
                if facebookSocial != nil {
                    influencerSocialsJSON.append(facebookSocial!)
                }
                let youtubeSocial = socialJSON(line, indexOfYoutube, .youtube)
                if youtubeSocial != nil {
                    influencerSocialsJSON.append(youtubeSocial!)
                }
                if influencerSocialsJSON.count > 0 {
                    influencerJSON[InfluencerKeys.socials.rawValue] = influencerSocialsJSON
                }
                influencersJSON.append(influencerJSON)
            }
        }
        return influencersJSON
    }
}
