//
//  APIKeyControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//


@testable import App
import XCTVapor
import Fluent

// MARK: - Get all
extension APIKeyControllerTests {
    /// Test the retrieval of all API keys
    /// - Given: A valid API key name
    /// - When: The API keys are retrieved
    /// - Then: The API keys are retrieved successfully
    /// - Note: The API keys should be retrieved from the database
    ///   and the response should be a 200 OK status.
    func testGetAllWithDataSucceed() async throws {
        let _ = try await APIKey.create(name: expectedName, on: app.db)

        try await app.test(.GET, baseURL) { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let apiKeys = try res.content.decode([APIKey].self)
                XCTAssertEqual(apiKeys.count, 1)
            } catch { }
        }
    }

    /// Test the retrieval of all API keys when there are no API keys
    /// - Given: No API keys in the database
    /// - When: The API keys are retrieved
    /// - Then: The API keys are retrieved successfully
    /// - Note: The API keys should be retrieved from the database
    ///   and the response should be a 200 OK status.
    ///   The API keys count should be 0.
    func testGetAllWithoutDataSucceed() async throws {
        try await app.test(.GET, baseURL) { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let apiKeys = try res.content.decode([APIKey].self)
                XCTAssertEqual(apiKeys.count, 0)
            } catch { }
        }
    }
}
