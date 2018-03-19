//
//  URL+Addition.swift
//  Foo
//
//  Created by huangmin on 16/03/2018.
//  Copyright © 2018 YedaoDev. All rights reserved.
//

import Foundation
import UIKit
extension URL {
    func cropShopifyImage(_ maxWidth : Int32, _ maxHeight : Int32)-> URL {
        if host?.contains("shopify") ?? false {
            var imageUrlLastComponent = lastPathComponent
            if imageUrlLastComponent.hasSuffix("_2048x." + pathExtension) {
                imageUrlLastComponent = imageUrlLastComponent.replacingOccurrences(of: "_2048x." + pathExtension,
                                                                                   with: "." + pathExtension,
                                                                                   options: .backwards,
                                                                                   range: Range(NSRange(location: imageUrlLastComponent.count-(pathExtension.count + 7),
                                                                                                        length: (pathExtension.count + 7)), in: imageUrlLastComponent))
            }
            let modifiedLastComponent = imageUrlLastComponent.replacingOccurrences(of: "." + pathExtension,
                                                                                   with: "_\(maxWidth)x\(maxHeight)_crop_center@\(Int32(UIScreen.main.scale))x." + pathExtension,
                                                                                   options: .backwards,
                                                                                   range:Range(NSRange(location: imageUrlLastComponent.count-(pathExtension.count + 1),
                                                                                                       length: (pathExtension.count + 1)), in: imageUrlLastComponent))
            let newImageUrlPath = description.replacingOccurrences(of: imageUrlLastComponent, with: modifiedLastComponent, options: .backwards)
            let newUrl = URL(string: newImageUrlPath)
            if newUrl != nil {
                return newUrl!
            }
        }
        return self
    }
}

