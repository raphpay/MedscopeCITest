//
//  Float+Ext.swift
//
//
//  Created by Raphaël Payet on 26/06/2024.
//

import Foundation

extension Float {
    /// Check if a float has at most two decimal places
    /// - Returns: A boolean indicating if the float has at most two decimal places
    var hasAtMostTwoDecimalPlaces: Bool {
        let numberString = String(self)
        let decimalCount = numberString.split(separator: ".").last?.count ?? 0
        return decimalCount <= 2
    }
}
