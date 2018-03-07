//
//  RecommenderProduct.swift
//  Recommender
//
//  Created by huangmin on 07/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
final class RecommenderProduct : Decodable {
    var id : Int
    var title : String?
    var handle : String?
    var min_price : String?
    var max_price : String?
    var image : URL?
    var top : Bool?
    enum RecommenderProductKeys : String, CodingKey {
        case id
        case title
        case handle
        case min_price
        case max_price
        case image
        case top
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: RecommenderProductKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        handle = try values.decodeIfPresent(String.self, forKey: .handle)
        min_price = try values.decodeIfPresent(String.self, forKey: .min_price)
        max_price = try values.decodeIfPresent(String.self, forKey: .max_price)
        image = try values.decodeIfPresent(URL.self, forKey: .image)
        top = try values.decodeIfPresent(Bool.self, forKey: .top)
    }
}
extension RecommenderProduct : Equatable {
    public static func ==(lhs: RecommenderProduct, rhs: RecommenderProduct) -> Bool {
        return lhs.id == rhs.id
    }
}
