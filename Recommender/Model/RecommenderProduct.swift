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
    var min_price : Decimal?
    var image : URL?
    var top : Bool?
    enum RecommenderProductKeys : String, CodingKey {
        case id
        case title
        case handle
        case min_price = "minPriceCent"
        case image
        case top
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: RecommenderProductKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        handle = try values.decodeIfPresent(String.self, forKey: .handle)
        let price = try values.decodeIfPresent(Decimal.self, forKey: .min_price)
        min_price = price?.dividing(by: Decimal(100))
        image = try values.decodeIfPresent(URL.self, forKey: .image)
        top = try values.decodeIfPresent(Bool.self, forKey: .top)
    }
}
extension RecommenderProduct : Equatable {
    public static func ==(lhs: RecommenderProduct, rhs: RecommenderProduct) -> Bool {
        return lhs.id == rhs.id
    }
}
