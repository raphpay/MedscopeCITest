//
//  ImplantControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Create
extension ImplantControllerTests {
    /// Tests the creation of a new implant
    /// - Given: A valid document ID
    /// - When: The implant is created
    /// - Then: The implant is created
    func testCreateSucceed() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let input = ImplantControllerTests().createExpectedImplantInput(with: documentID, on: app.db)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let implant = try res.content.decode(Implant.self)
                XCTAssertEqual(implant.internalDiam, expectedInternalDiam)
                XCTAssertEqual(implant.matName, expectedMatName)
            } catch { }
        }
    }

    /// Tests the creation of a new implant with an inexistant document
    /// - Given: An inexistant document ID
    /// - When: The implant is created
    /// - Then: The creation fails with a bad request error
    /// Note: The inexistant document ID is generated randomly
    func testCreateWithInexistantDocumentFails() async throws {
        let input = ImplantControllerTests().createExpectedImplantInput(with: UUID(), on: app.db)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.inexistantModel"))
        }
    }

    /// Tests the creation of a new implant with an inexistant document
    /// - Given: An inexistant document ID
    /// - When: The implant is created
    /// - Then: The creation fails with a bad request error
    func testCreateWithIncorrectUpCenterFails() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let input = ImplantControllerTests().createExpectedImplantInput(with: documentID, upCenter: invalidUpCenter, on: app.db)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidUpCenterData"))
        }
    }

    /// Tests the creation of a new implant with an inexistant document
    /// - Given: An inexistant document ID
    /// - When: The implant is created
    /// - Then: The creation fails with a bad request error
    func testCreateWithIncorrectCenterZFails() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let input = ImplantControllerTests().createExpectedImplantInput(with: documentID, centerZ: invalidCenterZ, on: app.db)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidCenterZData"))
        }
    }

    /// Tests the creation of a new implant with an inexistant document
    /// - Given: An inexistant document ID
    /// - When: The implant is created
    /// - Then: The creation fails with a bad request error
    func testCreateWithInvalidUpIndexFails() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let input = ImplantControllerTests().createExpectedImplantInput(with: documentID, upIndex: invalidUpIndex, on: app.db)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidUpIndexData"))
        }
    }

    func test_Create_WithIncorrectInternalDiam_Fails() async throws {

    }
}
