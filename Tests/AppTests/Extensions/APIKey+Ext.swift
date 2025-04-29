//
//  APIKey+Ext.swift
//
//
//  Created by Raphaël Payet on 25/07/2024.
//

@testable import App
import XCTVapor
import Fluent

extension APIKey {
    /// Create a new API key
    /// - Parameters:
    ///   - name: The name of the API key
    ///   - db: The database connection to use for the creation
    /// - Returns: The created API key
    /// - Throws: An error if the API key creation fails
    static func saveAPIKey(on db: Database) async throws -> APIKey {
        let input = APIKey.Input(name: "test")
        let value = try await APIKeyController().create(input, on: db)
        let apiKey = APIKey(name: input.name, value: value)
        try await apiKey.save(on: db)
        return apiKey
    }

    /// Create a new API key
    /// - Parameters:
    ///   - name: The name of the API key
    ///   - db: The database connection to use for the creation
    /// - Returns: The created API key
    /// - Throws: An error if the API key creation fails
    static func create(name: String, on db: Database) async throws -> APIKey {
        let input = APIKey.Input(name: name)
        let value = input.generate()
        let apiKey = APIKey(name: name, value: value)

        try await apiKey.save(on: db)

        return apiKey
    }
}
