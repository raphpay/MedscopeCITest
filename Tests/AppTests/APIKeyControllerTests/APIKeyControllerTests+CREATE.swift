//
//  APIKeyControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Create
extension APIKeyControllerTests {
    /// Test the creation of an API key
    /// - Given: A valid API key name
    /// - When: The API key is created
    /// - Then: The API key is created successfully
    /// - Note: The API key name should be unique and not exceed the maximum limit
    func testCreateSucceed() async throws {
        let input = APIKey.Input(name: expectedName)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let apiKey = try res.content.decode(APIKey.self)
                XCTAssertEqual(apiKey.name, expectedName)
            } catch { }
        }
    }

    /// Test the creation of an API key with a name exceeding the maximum limit
    /// - Given: A valid API key name
    /// - When: The API key is created
    /// - Then: The API key creation fails with an unauthorized error
    /// - Note: The API key name should be unique and not exceed the maximum limit.
    ///   The maximum limit is set to 3 API keys
    func testCreateWithExceedingLimitFails() async throws {
        let _ = try await APIKey.create(name: expectedName, on: app.db)
        let _ = try await APIKey.create(name: "expectedNameTwo", on: app.db)
        let _ = try await APIKey.create(name: "expectedNameThree", on: app.db)

        let input = APIKey.Input(name: "expectedNameFour")

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.maximumApiKeysReached"))
        }
    }

    /// Test the creation of an API key with an already existing name
    /// - Given: A valid API key name
    /// - When: The API key is created
    /// - Then: The API key creation fails with an unauthorized error
    /// - Note: The API key name should be unique.
    func testCreateWithSameNameFails() async throws {
        let _ = try await APIKey.create(name: expectedName, on: app.db)
        let input = APIKey.Input(name: expectedName)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.apiKeyAlreadyExists"))
        }
    }
}
