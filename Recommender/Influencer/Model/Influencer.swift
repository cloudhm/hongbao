//
//  Influencer.swift
//  Recommender
//
//  Created by huangmin on 12/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
import Alamofire
final class Influencer : Decodable {
    var name : String
    var image : URL
    var handle : URL
    var socials : [InfluencerSocial]?
    enum InfluencerKeys : String, CodingKey {
        case name
        case image
        case handle
        case socials
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: InfluencerKeys.self)
        name = try values.decode(String.self, forKey: .name)
        image = try values.decode(URL.self, forKey: .image)
        handle = try values.decode(URL.self, forKey: .handle)
        socials = try values.decodeIfPresent(Array.self, forKey: .socials)
    }
}
