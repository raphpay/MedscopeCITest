//
//  ImplantControllerTests+UPDATE.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Update
extension ImplantControllerTests {
    /// Tests the update of an implant
    /// - Given: A valid implant ID
    /// - When: The implant is updated
    /// - Then: The implant is updated successfully
    func testUpdateSucceed() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        let newReference = "newReference"
        let newInternalDiam = Float(100.0)
        let newAbutmentContactHeight = Float(200.0)
        let newMatName = "newMatName"

        let updateInput = Implant.UpdateInput(reference: newReference,
                                              internalDiam: newInternalDiam,
                                              abutmentContactHeight: newAbutmentContactHeight,
                                              diameter: nil,
                                              hneck: nil,
                                              length: nil,
                                              matName: newMatName,
                                              upCenter: nil,
                                              centerZ: nil,
                                              upIndex: nil,
                                              modelID: nil)

        try await app.test(.PUT, "\(baseURL)/\(implant.reference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let updatedImplant = try res.content.decode(Implant.self)
                XCTAssertEqual(updatedImplant.reference, newReference)
                XCTAssertEqual(updatedImplant.internalDiam, newInternalDiam)
                XCTAssertEqual(updatedImplant.abutmentContactHeight, newAbutmentContactHeight)
                XCTAssertEqual(updatedImplant.matName, newMatName)
            } catch { }
        }
    }

    /// Tests the update of an implant with an incorrect reference
    /// - Given: An incorrect reference
    /// - When: The implant is updated
    /// - Then: The update fails with a not found error
    /// - Note: The reference should be a valid string and the implant should exist in the database.
    func testUpdateWithIncorrectReferenceFails() async throws {
        let newReference = "newReference"
        let newInternalDiam = Float(100.0)
        let newAbutmentContactHeight = Float(200.0)
        let newMatName = "newMatName"

        let updateInput = Implant.UpdateInput(reference: newReference,
                                              internalDiam: newInternalDiam,
                                              abutmentContactHeight: newAbutmentContactHeight,
                                              diameter: nil,
                                              hneck: nil,
                                              length: nil,
                                              matName: newMatName,
                                              upCenter: nil,
                                              centerZ: nil,
                                              upIndex: nil,
                                              modelID: nil)

        let wrongReference = "wrongReference"
        try await app.test(.PUT, "\(baseURL)/\(wrongReference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.implant"))
        }
    }

    /// Tests the update of an implant with an inexistant document
    /// - Given: An inexistant document
    /// - When: The implant is updated
    /// - Then: The update fails with a not found error
    /// - Note: The document should exist in the database.
    func testUpdateWithIncorrectDocumentFails() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        let newReference = "newReference"
        let newInternalDiam = Float(100.0)
        let newAbutmentContactHeight = Float(200.0)
        let newMatName = "newMatName"

        let updateInput = Implant.UpdateInput(reference: newReference,
                                              internalDiam: newInternalDiam,
                                              abutmentContactHeight: newAbutmentContactHeight,
                                              diameter: nil,
                                              hneck: nil,
                                              length: nil,
                                              matName: newMatName,
                                              upCenter: nil,
                                              centerZ: nil,
                                              upIndex: nil,
                                              modelID: UUID())

        try await app.test(.PUT, "\(baseURL)/\(implant.reference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.inexistantModel"))
        }
    }

    /// Tests the update of an implant with an incorrect users
    /// - Given: An incorrect user
    /// - When: The implant is updated
    /// - Then: The update fails with a unauthorized error
    func testUpdateWithIncorrectUserAccessFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .user, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        let newReference = "newReference"
        let newInternalDiam = Float(100.0)
        let newAbutmentContactHeight = Float(200.0)
        let newMatName = "newMatName"

        let updateInput = Implant.UpdateInput(reference: newReference,
                                              internalDiam: newInternalDiam,
                                              abutmentContactHeight: newAbutmentContactHeight,
                                              diameter: nil,
                                              hneck: nil,
                                              length: nil,
                                              matName: newMatName,
                                              upCenter: nil,
                                              centerZ: nil,
                                              upIndex: nil,
                                              modelID: nil)

        try await app.test(.PUT, "\(baseURL)/\(implant.reference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }

    /// Tests the update of an implant with an invalid up center
    /// - Given: An incorrect up center parameter
    /// - When: The implant is updated
    /// - Then: The update fails with a bad request error
    func testUpdateWithInvalidUpCenterFails() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        let updateInput = Implant.UpdateInput(reference: nil,
                                              internalDiam: nil,
                                              abutmentContactHeight: nil,
                                              diameter: nil,
                                              hneck: nil,
                                              length: nil,
                                              matName: nil,
                                              upCenter: invalidUpCenter,
                                              centerZ: nil,
                                              upIndex: nil,
                                              modelID: nil)

        try await app.test(.PUT, "\(baseURL)/\(implant.reference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidUpcenterData"))
        }
    }

    /// Tests the update of an implant with an invalid center z
    /// - Given: An incorrect center z parameter
    /// - When: The implant is updated
    /// - Then: The update fails with a bad request error
    func testUpdateWithInvalidCenterZFails() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        let updateInput = Implant.UpdateInput(reference: nil,
                                              internalDiam: nil,
                                              abutmentContactHeight: nil,
                                              diameter: nil,
                                              hneck: nil,
                                              length: nil,
                                              matName: nil,
                                              upCenter: nil,
                                              centerZ: invalidCenterZ,
                                              upIndex: nil,
                                              modelID: nil)

        try await app.test(.PUT, "\(baseURL)/\(implant.reference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidCenterzData"))
        }
    }

    /// Tests the update of an implant with an invalid up index
    /// - Given: An incorrect up index parameter
    /// - When: The implant is updated
    /// - Then: The update fails with a bad request error
    func testUpdateWithInvalidUpIndexFails() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        let updateInput = Implant.UpdateInput(reference: nil,
                                              internalDiam: nil,
                                              abutmentContactHeight: nil,
                                              diameter: nil,
                                              hneck: nil,
                                              length: nil,
                                              matName: nil,
                                              upCenter: nil,
                                              centerZ: nil,
                                              upIndex: invalidUpIndex,
                                              modelID: nil)

        try await app.test(.PUT, "\(baseURL)/\(implant.reference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidUpindexData"))
        }
    }
}
