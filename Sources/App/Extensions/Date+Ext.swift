//
//  Date+Ext.swift
//  Medscope
//
//  Created by Raphaël Payet on 09/12/2024.
//

import Foundation

extension Date {
    /// Format the date as a string in the format "yyyy/MM/dd"
    /// - Returns: A string representation of the date in the format "yyyy/MM/dd"
    func formattedAsYearMonthDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: self)
    }
}
