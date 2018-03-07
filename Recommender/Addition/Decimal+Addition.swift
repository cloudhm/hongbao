//
//  Decimal+Addition.swift
//  Recommender
//
//  Created by huangmin on 04/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import Foundation
extension Decimal {
    func formatPrice()->String {
        let canonical = NSLocale.canonicalLocaleIdentifier(from: "en_US@currency=USD")
        let locale = Locale(identifier: canonical)
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.currencyCode = locale.currencyCode
        // `$.00` -> `$0.00`
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .none
        return formatter.currencySymbol + formatter.string(from: NSDecimalNumber(decimal: self))!
    }
}
