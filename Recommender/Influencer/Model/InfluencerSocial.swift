//
//  InfluencerSocial.swift
//  Recommender
//
//  Created by huangmin on 12/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
final class InfluencerSocial : Decodable {
    var image : URL
    var handle : URL?
    enum InfluencerSocialKeys : String, CodingKey {
        case image
        case handle
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: InfluencerSocialKeys.self)
        image = try values.decode(URL.self, forKey: .image)
        handle = try values.decodeIfPresent(URL.self, forKey: .handle)
    }
}
