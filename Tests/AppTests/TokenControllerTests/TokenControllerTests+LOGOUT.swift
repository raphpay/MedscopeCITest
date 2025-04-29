//
//  TokenControllerTests+LOGIN.swift
//  Medscope
//
//  Created by Raphaël Payet on 11/12/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Logout
extension TokenControllerTests {
    /// Test the logout of a user
    /// - Given: A user with a valid token
    /// - When: sends a DELETE request to the logout endpoint with the token ID
    /// - Then: The user is logged out successfully and the token is deleted
    func testLogoutSucceed() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let token = try await Token.create(with: user, on: app.db)
        let tokenID = try token.requireID()

        try await app.test(.DELETE, "\(baseURL)/logout/\(tokenID)", beforeRequest: { req in
            req.headers.add(name: "api-key", value: apiKey.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .noContent)
        })
    }

    /// Test the logout of a user without API key
    /// - Given: A user with a valid token
    /// - When: sends a DELETE request to the logout endpoint without API key
    /// - Then: The user receives a 401 Unauthorized error
    func testLogoutWithInexistantTokenFails() async throws {
        try await app.test(.DELETE, "\(baseURL)/logout/\(UUID())", beforeRequest: { req in
            req.headers.add(name: "api-key", value: apiKey.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.token"))
        })
    }
}
