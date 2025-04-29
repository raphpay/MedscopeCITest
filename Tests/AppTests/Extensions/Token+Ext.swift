//
//  token+Ext.swift
//
//
//  Created by Raphaël Payet on 01/08/2024.
//

@testable import App
import XCTVapor
import Fluent

extension Token {
    /// Create a new token
    /// - Parameters:
    ///  - adminUser: The admin user to generate the token for
    /// - db: The database connection to use for the creation
    /// - Returns: The created token
    /// - Throws: An error if the token creation fails
    static func create(with adminUser: User, on db: Database) async throws -> Token {
        let token = try Token.generate(for: adminUser)
        try await token.save(on: db)
        return token
    }

    /// Create a new token
    /// - Parameters:
    /// - db: The database connection to use for the creation
    /// - Returns: The created token
    /// - Throws: An error if the token creation fails
    static func saveToken(on db: Database) async throws -> Token {
        let adminUser = try await UserControllerTests().createAdminUser(on: db)
        let token = try Token.generate(for: adminUser)
        try await token.save(on: db)
        return token
    }
}
