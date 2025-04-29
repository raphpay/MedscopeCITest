//
//  APIKeyController.swift
//
//
//  Created by Raphaël Payet on 13/07/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

struct APIKeyController: RouteCollection {
    /// Defines the routes for the APIKeyController.
    func boot(routes: RoutesBuilder) throws {
        // Define the routes for APIKey management
        // Exclude from OpenAPI documentation
        let apiKeys = routes.grouped("api", "apiKeys")
        apiKeys.post(use: create)
            .excludeFromOpenAPI()
        apiKeys.delete(":apiKeyID", use: delete)
            .excludeFromOpenAPI()
        apiKeys.get(use: getAll)
            .excludeFromOpenAPI()
    }

    // MARK: - CREATE
    /// Creates a new APIKey.
    ///
    /// This function validates the input parameters and creates a new APIKey with the given name and value. It then returns the generated value.
    ///
    /// - Parameter req: The HTTP request containing the APIKey information.
    /// - Returns: A `Future` that resolves with a `APIKey.Output` containing the name and value of the created APIKey.
    @Sendable
    func create(req: Request) async throws -> APIKey.Output {
        let input = try req.content.decode(APIKey.Input.self)
        let value = try await create(input, on: req.db)

        let output = APIKey.Output(name: input.name, value: value)
        return output
    }

    // MARK: - READ
    /// Retrieves all APIKeys.
    ///
    /// This function fetches all APIKeys from the database and returns them as an array of `APIKey` objects.
    /// - Parameter req: The HTTP request containing the database connection.
    /// - Returns: An array of `APIKey` objects.
    /// - Throws: An error if the database query fails.
    @Sendable
    func getAll(req: Request) async throws -> [APIKey] {
        try await APIKey.query(on: req.db).all()
    }

    @Sendable
    /// Deletes an APIKey.
    ///
    /// This function deletes the APIKey with the specified ID from the database.
    ///  - Parameter req: The HTTP request containing the APIKey ID.
    ///  - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    ///  - Throws: An error if the APIKey cannot be found or if the database deletion fails.
    func delete(req: Request) async throws -> HTTPResponseStatus {
        guard let apiKey = try await APIKey.find(req.parameters.get("apiKeyID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.apiKey")
        }

        try await apiKey.delete(force: true, on: req.db)

        return .noContent
    }
}

// MARK: - Utils
extension APIKeyController {
    private func validate(_ input: APIKey.Input, on database: Database) async throws {
        let count = try await APIKey.query(on: database).all().count
        guard count < 3 else {
            throw Abort(.unauthorized, reason: "unauthorized.maximumApiKeysReached")
        }

        if try await APIKey.query(on: database).filter(\.$name == input.name).first() != nil {
            throw Abort(.unauthorized, reason: "unauthorized.apiKeyAlreadyExists")
        }
    }

    func create(_ input: APIKey.Input, on database: Database) async throws -> String {
        try await validate(input, on: database)

        let value = input.generate()

        let apiKeyHashedValue = try Bcrypt.hash(value)
        let apiKey = APIKey(name: input.name, value: apiKeyHashedValue)
        try await apiKey.save(on: database)

        return value
    }
}
