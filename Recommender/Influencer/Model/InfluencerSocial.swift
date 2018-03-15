//
//  InfluencerSocial.swift
//  Recommender
//
//  Created by huangmin on 12/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
final class InfluencerSocial : Decodable, Encodable {
    var image : URL?
    var handle : URL?
    var type : String?
    var id : Int?
    var archived : Bool?
    enum InfluencerSocialKeys : String, CodingKey {
        case image
        case handle
        case type = "socialType"
        case id
        case archived
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: InfluencerSocialKeys.self)
        image = try values.decodeIfPresent(URL.self, forKey: .image)
        handle = try values.decodeIfPresent(URL.self, forKey: .handle)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        archived = try values.decodeIfPresent(Bool.self, forKey: .archived) ?? false
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InfluencerSocialKeys.self)
        try container.encodeIfPresent(handle, forKey: .handle)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(archived ?? false, forKey: .archived)
    }
    enum InfluencerSocialType : String {
        case instagram = "INSTAGRAM"
        case facebook = "FACEBOOK"
        case youtube = "YOUTUBE"
        func socialInfo()->[String: String] {
            return [InfluencerSocialKeys.type.rawValue : rawValue]
        }
        static func inferSocialType(_ url : URL) -> InfluencerSocialType? {
            if url.host?.contains("facebook") ?? false {
                return .facebook
            } else if url.host?.contains("instagram") ?? false {
                return .instagram
            } else if url.host?.contains("youtube") ?? false {
                return .youtube
            }
            return nil
        }
    }
}
