//
//  ImplantControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Delete all
extension ImplantControllerTests {
    /// Tests the deletion of all implants
    /// - Given: A valid document ID
    /// - When: The implants are deleted
    /// - Then: The implants are deleted
    /// Note: The user should be an admin.
    func testDeleteAllWithDataSucceed() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let _ = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        try await app.test(.DELETE, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)

            do {
                let implants = try await Implant.query(on: app.db).all()
                XCTAssertEqual(implants.count, 0)
            } catch { }
        }
    }

    /// Tests the deletion of all implants without any data
    /// - Given: An inexistant document ID
    /// - When: The implants are deleted
    /// - Then: The implants are deleted
    /// Note: The user should be an admin.
    func testDeleteAllWithoutDataSucceed() async throws {
        try await app.test(.DELETE, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)

            do {
                let implants = try await Implant.query(on: app.db).all()
                XCTAssertEqual(implants.count, 0)
            } catch { }
        }
    }

    /// Tests the deletion of all implants with an incorrect user role
    /// - Given: A valid document ID
    /// - When: The implants are deleted
    /// - Then: The deletion fails with a unauthorized error
    /// - Note: The user should be an admin.
    func testDeleteAllWithoutAuthorizationFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .user, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)

        try await app.test(.DELETE, baseURL, beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
}

// MARK: - Delete
extension ImplantControllerTests {
    /// Tests the deletion of an implant
    /// - Given: A valid implant ID
    /// - When: The implant is deleted
    /// - Then: The implant is deleted successfully
    /// - Note: The user should be an admin.
    func testDeleteSucceed() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)
        let implantID = try implant.requireID()

        try await app.test(.DELETE, "\(baseURL)/\(implantID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)

            do {
                let implants = try await Implant.query(on: app.db).all()
                XCTAssertEqual(implants.count, 0)
            } catch { }
        }
    }

    /// Tests the deletion of an implant with an inexistant implant ID
    /// - Given: An inexistant implant ID
    /// - When: The implant is deleted
    /// - Then: The deletion fails with a not found error
    /// - Note: The implant ID should be a valid UUID and the implant should exist in the database.
    func testDeleteWithInexistantImplantFails() async throws {
        let falseImplantID = UUID()
        try await app.test(.DELETE, "\(baseURL)/\(falseImplantID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.implant"))
        }
    }

    /// Tests the deletion of an implant with an unauthorized user
    /// - Given: A valid implant ID
    /// - When: The implant is deleted
    /// - Then: The deletion fails with a unauthorized error
    /// - Note: The user should not be an admin.
    func testDeleteWithUnauthorizedUserFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .companyOperator, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)
        let implantID = try implant.requireID()

        try await app.test(.DELETE, "\(baseURL)/\(implantID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }
}
