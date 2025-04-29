//
//  MaterialControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Delete
extension MaterialControllerTests {
    /// Tests the deletion of all materials
    /// - Given: A valid material
    /// - When: The materials are deleted
    /// - Then: The materials are deleted
    /// Note: The user should be an admin.
    func testDeleteAllSucceed() async throws {
        let _ = try await MaterialControllerTests().createExpectedMaterial(on: app.db)

        try await app.test(.DELETE, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)

            do {
                let materials = try await Material.query(on: app.db).all()
                XCTAssertEqual(materials.count, 0)
            } catch { }
        }
    }

    /// Tests the deletion of all materials with an unauthorized user
    /// - Given: A valid material
    /// - When: The materials are deleted
    /// - Then: The deletion fails with an unauthorized error
    /// Note: The user should be an admin.
    func testDeleteAllWithUnauthorizedUserFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .companyOperator, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)

        try await app.test(.DELETE, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }
}
