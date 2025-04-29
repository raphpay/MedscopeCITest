//
//  TokenControllerTests+LOGIN.swift
//  Medscope
//
//  Created by Raphaël Payet on 11/12/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Login
extension TokenControllerTests {
    /// Test the login of a user
    /// - Given: A user with a valid email and password
    /// - When: sends a POST request to the login endpoint with Basic Authorization header
    /// - Then: The user is logged in successfully and receives a token
    func testLoginSucceed() async throws {
        let _ = try await UserControllerTests().createExpectedUser(on: app.db)

        let mailAddress = UserControllerTests().expectedMailAddress
        let password = UserControllerTests().expectedPassword

        try await app.test(.POST, "\(baseURL)/login", beforeRequest: { req in
            // Set Basic Authorization header
            req.headers.basicAuthorization = BasicAuthorization(username: mailAddress, password: password)
            // Add API key header
            req.headers.add(name: "api-key", value: apiKey.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
        })
    }

    /// Test the login of a user without Basic Authorization header
    /// - Given: A user with a valid email and password
    /// - When: sends a POST request to the login endpoint without Basic Authorization header
    /// - Then: The user receives a 401 Unauthorized error
    /// - Note: The test checks that the response contains the expected error message
    func testLoginWithoutAuthorizationHeaderFails() async throws {
        let _ = try await UserControllerTests().createExpectedUser(on: app.db)

        try await app.test(.POST, "\(baseURL)/login", beforeRequest: { req in
            // Add API key header
            req.headers.add(name: "api-key", value: apiKey.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.missingAuthorizationHeader"))
        })
    }

    /// Test the login of a user with an invalid API key
    /// - Given: A user with a valid email and password
    /// - When: sends a POST request to the login endpoint with an invalid API key
    /// - Then: The user receives a 401 Unauthorized error
    func testLoginWithInexistantUserFails() async throws {
        let mailAddress = UserControllerTests().expectedMailAddress
        let password = UserControllerTests().expectedPassword

        try await app.test(.POST, "\(baseURL)/login", beforeRequest: { req in
            // Set Basic Authorization header
            req.headers.basicAuthorization = BasicAuthorization(username: mailAddress, password: password)
            // Add API key header
            req.headers.add(name: "api-key", value: apiKey.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        })
    }

    /// Test the login of a user with too many failed attempts
    /// - Given: A user with a valid email and password
    /// - When: sends a POST request to the login endpoint with too many failed attempts
    /// - Then: The user receives a 403 Forbidden error
    func testLoginTooManyFailedAttempts() async throws {
        // Step 1: Create a test user in the database
        let user = try await UserControllerTests().createExpectedUser(on: app.db)

        // Step 2: Mock the failed attempts and last failed login timestamp
        let maxAttempts = 5
        user.loginFailedAttempts = maxAttempts

        // Set a recent timestamp (e.g., 1 hour ago) so the user is still locked out
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]
        let recentTimestamp = formatter.string(from: Date().addingTimeInterval(-3600)) // 1 hour ago
        user.lastLoginFailedAttempt = recentTimestamp

        try await user.update(on: app.db) // Save the updated user to the database

        // Step 3: Define test credentials
        let mailAddress = UserControllerTests().expectedMailAddress
        let password = UserControllerTests().expectedPassword

        // Step 4: Make the POST login request
        try await app.test(.POST, "\(baseURL)/login", beforeRequest: { req in
            // Add Basic Authorization header
            req.headers.basicAuthorization = BasicAuthorization(username: mailAddress, password: password)
            // Add API key header
            req.headers.add(name: "api-key", value: apiKey.value)
        }, afterResponse: { res async in
            // Step 5: Verify the response throws the expected 403 Forbidden error
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.tooManyFailedAttempts"))
        })
    }

    /// Test the login of a user with an invalid last failed timestamp
    /// - Given: A user with a valid email and password
    /// - When: sends a POST request to the login endpoint with an invalid last failed timestamp
    /// - Then: The user receives a 403 Forbidden error
    func testLoginInvalidLastFailedTimestamp() async throws {
        // Step 1: Create a test user in the database
        let user = try await UserControllerTests().createExpectedUser(on: app.db)

        // Step 2: Mock the failed attempts and set an invalid last failed timestamp
        let maxAttempts = 5
        user.loginFailedAttempts = maxAttempts
        user.lastLoginFailedAttempt = "INVALID_TIMESTAMP" // Set an invalid timestamp format

        try await user.save(on: app.db) // Save the updated user to the database

        // Step 3: Define test credentials
        let mailAddress = UserControllerTests().expectedMailAddress
        let password = UserControllerTests().expectedPassword

        // Step 4: Make the POST login request

        try await app.test(.POST, "\(baseURL)/login", beforeRequest: { req in
            // Add Basic Authorization header
            req.headers.basicAuthorization = BasicAuthorization(username: mailAddress, password: password)
            // Add API key header
            req.headers.add(name: "api-key", value: apiKey.value)
        }, afterResponse: { res async in
            // Step 5: Verify the response throws the expected 403 Forbidden error
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.invalidLastFailedTimestamp"))
        })
    }

    /// Test the login of a user with invalid credentials
    /// - Given: A user with a valid email and password
    /// - When: sends a POST request to the login endpoint with invalid credentials
    /// - Then: The user receives a 401 Unauthorized error
    func testLoginWithInvalidCredentialsFails() async throws {
        let _ = try await UserControllerTests().createExpectedUser(on: app.db)

        let mailAddress = UserControllerTests().expectedMailAddress
        let password = "wrongPassword"

        try await app.test(.POST, "\(baseURL)/login", beforeRequest: { req in
            // Set Basic Authorization header
            req.headers.basicAuthorization = BasicAuthorization(username: mailAddress, password: password)
            // Add API key header
            req.headers.add(name: "api-key", value: apiKey.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.invalidCredentials"))
        })
    }
}
