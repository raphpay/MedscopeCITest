//
//  EmailMiddleware.swift
//  Medscope
//
//  Created by Raphaël Payet on 27/09/2024.
//

import Vapor
import SendGridKit

struct EmailMiddleware {
    /// Validate the email addresses in the request
    /// - Parameters:
    ///   - tos: An array of email addresses
    ///   - from: The email address of the sender
    /// - Throws: An error if the email addresses are invalid
    func validate(tos: [String], from: String) throws {
        for email in tos {
            guard email.isValidEmail()  else {
                throw Abort(.badRequest, reason: "badRequest.invalidToEmail")
            }
        }

        guard from.isValidEmail() else {
            throw Abort(.badRequest, reason: "badRequest.invalidFromEmail")
        }
    }

    /// Create an array of `EmailAddress` from an array of email addresses
    /// - Parameter tos: An array of email addresses
    /// - Returns: An array of `EmailAddress`
    func createToArray(tos: [String]) -> [EmailAddress] {
        tos.map { EmailAddress(email: $0) }
    }
}
