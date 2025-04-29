//
//  Patient+Gender.swift
//
//
//  Created by Raphaël Payet on 21/06/2024.
//

import Foundation

extension Patient {
    /// The gender of a Patient
    /// - Note: This enum represents the gender of a Patient.
    ///    The `female` case represents a female gender.
    ///    The `male` case represents a male gender.
    enum Gender: String, Codable {
        case female, male
    }
}
