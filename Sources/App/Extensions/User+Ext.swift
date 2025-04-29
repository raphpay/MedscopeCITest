//
//  User+Ext.swift
//
//
//  Created by Raphaël Payet on 30/07/2024.
//

import Fluent
import Vapor

extension User {
    /// Verify if a user with a given mail address exists
    /// - Parameter mailAddress: The mail address to check
    /// - Returns: A boolean indicating if a user with the given mail address exists
    /// - Throws: An error if the mail address is not valid
    static func verifyUniqueMailAddress(_ mailAddress: String, on req: Request) async throws -> String {
        let user = try await User.query(on: req.db)
            .filter(\.$mailAddress == mailAddress)
            .first()

        guard user == nil else {
            // If a user with the email already exists, throw an error
            throw Abort(.badRequest, reason: "badRequest.emailAlreadyExists")
        }
        // If the email is unique, return it
        return mailAddress
    }
}

/// A user model that conforms to the `ModelAuthenticatable` protocol
/// - Note: This struct conforms to the `ModelAuthenticatable` protocol, which provides methods for verifying and authenticating users.
extension User: ModelAuthenticatable {
    static let usernameKey = \User.$mailAddress
    static let passwordHashKey = \User.$password

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
