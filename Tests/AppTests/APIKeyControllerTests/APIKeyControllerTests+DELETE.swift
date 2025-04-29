//
//  File.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

import Foundation
//
//  APIKeyControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//


@testable import App
import XCTVapor
import Fluent

// MARK: - Delete
extension APIKeyControllerTests {
    /// Test the deletion of an API key
    /// - Given: A valid API key ID
    /// - When: The API key is deleted
    /// - Then: The API key is deleted successfully
    /// - Note: The API key should be deleted from the database
    ///   and the response should be a 204 No Content status.
    func testDeleteSucceed() async throws {
        let apiKey = try await APIKey.create(name: expectedName, on: app.db)
        let apiKeyID = try apiKey.requireID()

        try await app.test(.DELETE, "\(baseURL)/\(apiKeyID)") { res async in
            XCTAssertEqual(res.status, .noContent)

            do {
                let apiKeys = try await APIKey.query(on: app.db).all()
                XCTAssertEqual(apiKeys.count, 0)
            } catch { }
        }
    }

    /// Test the deletion of an API key that does not exist
    /// - Given: An invalid API key ID
    /// - When: The API key is deleted
    /// - Then: The API key deletion fails with a not found error
    func testDeleteInexistantAPIKeyFails() async throws {
        let falseAPIKeyID = UUID()
        try await app.test(.DELETE, "\(baseURL)/\(falseAPIKeyID)") { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.apiKey"))
        }
    }
}
