//
//  User+Role.swift
//
//
//  Created by Raphaël Payet on 01/08/2024.
//

import Foundation

extension User {
    /// The role of a User
    /// - Note: This enum represents the role of a User.
    ///    The `admin` case represents an admin role.
    ///    The `companyOperator` case represents a company operator role.
    ///    The `user` case represents a user role.
    enum Role: String, Codable {
        case admin, companyOperator, user
    }
}
