//
//  MaterialControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Get all
extension MaterialControllerTests {
    /// Tests the retrieval of all materials
    /// - Given: A valid material input
    /// - When: The materials are retrieved
    /// - Then: The materials are retrieved
    func testGetAllSucceed() async throws {
        let _ = try await MaterialControllerTests().createExpectedMaterial(on: app.db)

        try await app.test(.GET, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let materials = try res.content.decode([Material].self)
                XCTAssertEqual(materials.count, 1)
                XCTAssertEqual(materials[0].matName, expectedMatName)
                XCTAssertEqual(materials[0].sigmaFa, expectedSigmaFa)
            } catch { }
        }
    }
}
