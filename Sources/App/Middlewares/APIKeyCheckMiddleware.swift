//
//  APIKeyCheckMiddleware.swift
//
//
//  Created by Raphaël Payet on 13/07/2024.
//

import Vapor

/// Middleware to check if the API key is valid
/// It checks the API key in the request headers against the hashed values stored in the database.
/// If the API key is valid, it allows the request to proceed.
/// If the API key is invalid, it throws an unauthorized error.
/// This middleware is used to protect routes that require authentication.
/// It is important to note that this middleware should be used in conjunction with the `APIKey` model,
/// which is responsible for storing the hashed API keys in the database.
struct APIKeyCheckMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Get the API key from the headers
        guard let apiKey = request.headers["api-key"].first else {
            throw Abort(.unauthorized, reason: "unauthorized.missingAPIKey")
        }

        // Find the API key in the database and verify the hashed value
        let apiKeyRecords = try await APIKey.query(on: request.db).all()
        let isValidApiKey = try apiKeyRecords.contains { record in
            try Bcrypt.verify(apiKey, created: record.value)
        }

        guard isValidApiKey else {
            throw Abort(.unauthorized, reason: "unauthorized.invalidApiKey")
        }

        return try await next.respond(to: request)
    }
}
