//
//  File.swift
//
//
//  Created by Raphaël Payet on 30/07/2024.
//

import Fluent

extension Token {
    /// Generate a new token for a user
    /// - Parameter user: The user for which to generate a token
    /// - Returns: A new token for the user
    /// - Throws: An error if the token generation fails
    static func generate(for user: User) throws -> Token {
        let random = [UInt8].random(count: 16).base64
        return try Token(value: random, userID: user.requireID())
    }
}

/// A token used for authentication
/// - Note: This struct represents a token used for authentication.
///    It conforms to the `ModelTokenAuthenticatable` protocol, which provides methods for validating and authenticating tokens.
extension Token: ModelTokenAuthenticatable {
    static let valueKey = \Token.$value
    static let userKey = \Token.$user

    typealias User = App.User

    var isValid: Bool {
        true
    }
}

extension PasswordResetToken {
    /// Generate a new token for a user
    /// - Parameter user: The user for which to generate a token
    /// - Returns: A new token for the user
    static func generate() -> String {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<6).map { _ in letters.randomElement()! })
    }
}
