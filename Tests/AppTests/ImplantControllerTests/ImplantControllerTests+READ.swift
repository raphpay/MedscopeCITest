//
//  ImplantControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Get All
extension ImplantControllerTests {
    /// Tests the retrieval of all implants
    /// - Given: A valid document ID
    /// - When: The implants are retrieved
    /// - Then: The implants are retrieved
    func testGetAllWithDataSucceed() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let _ = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        try await app.test(.GET, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let implants = try res.content.decode([Implant].self)
                XCTAssertEqual(implants.count, 1)
                XCTAssertEqual(implants[0].internalDiam, expectedInternalDiam)
                XCTAssertEqual(implants[0].matName, expectedMatName)
            } catch { }
        }
    }

    /// Tests the retrieval of all implants
    /// - Given: An inexistant document ID
    /// - When: The implants are retrieved
    /// - Then: The implants are retrieved without data
    func testGetAllWithoutDataSucceed() async throws {
        try await app.test(.GET, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let implants = try res.content.decode([Implant].self)
                XCTAssertEqual(implants.count, 0)
            } catch { }
        }
    }
}

// MARK: - Get Material
extension ImplantControllerTests {
    /// Tests the retrieval of a material
    /// - Given: A valid implant ID
    /// - When: The material is retrieved
    /// - Then: The material is retrieved
    /// Note: The implant should exist in the database and the material should exist in the database.
    func testGetMaterialSucceed() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)
        let implantID = try implant.requireID()

        let material = Material(matName: expectedMatName, e: expectedMaterialE, nu: expectedMaterialNu, sigmaDam: expectedMaterialSigmaDam, sigmaFa: expectedMaterialSigmaFa)
        try await material.save(on: app.db)

        try await app.test(.GET, "\(baseURL)/material/\(implantID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let material = try res.content.decode(Material.self)
                XCTAssertEqual(material.matName, expectedMatName)
                XCTAssertEqual(material.sigmaFa, expectedMaterialSigmaFa)
            } catch { }
        }
    }

    /// Tests the retrieval of a material with an incorrect implant ID
    /// - Given: An incorrect implant ID
    /// - When: The material is retrieved
    /// - Then: The retrieval fails with a not found error
    /// Note: The implant ID should be a valid UUID and the implant should exist in the database.
    func testGetMaterialWithWrongImplantIDFails() async throws {
        let falseImplantID = UUID()
        try await app.test(.GET, "\(baseURL)/material/\(falseImplantID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.implant"))
        }
    }

    /// Tests the retrieval of a material with an inexistant material
    /// - Given: An inexistant material
    /// - When: The material is retrieved
    /// - Then: The retrieval fails with a not found error
    /// Note: The material should exist in the database.
    func testGetMaterialWithInexistantMaterialFails() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)
        let implantID = try implant.requireID()

        try await app.test(.GET, "\(baseURL)/material/\(implantID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.material"))
        }
    }
}

// MARK: - Get By Reference
extension ImplantControllerTests {
    /// Tests the retrieval of an implant by its reference
    /// - Given: A valid implant ID
    /// - When: The implant is retrieved
    /// - Then: The implant is retrieved
    func testGetByReferenceSucceed() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)
        let implantID = try implant.requireID()

        try await app.test(.GET, "\(baseURL)/by/reference/\(expectedReference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
				let implant = try res.content.decode(Implant.Output.self)
                XCTAssertEqual(implant.reference, expectedReference)
               XCTAssertEqual(implant.id, implantID)
            } catch {}
        }
    }

    /// Tests the retrieval of an implant by its reference with an inexistant implant
    /// - Given: An inexistant implant
    /// - When: The implant is retrieved
    /// - Then: The retrieval fails with a not found error
    /// Note: The implant should exist in the database.
    func testGetByReferenceWithInexistantImplantFails() async throws {
        let wrongReference = "wrong-reference"

        try await app.test(.GET, "\(baseURL)/by/reference/\(wrongReference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.implant"))
        }
    }
}

// MARK: - Get Model By Reference
extension ImplantControllerTests {
    /// Tests the retrieval of a model by its reference
    /// - Given: A valid document ID
    /// - When: The model is retrieved
    /// - Then: The model is retrieved
    func testGetModelByReferenceSucceed() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let _ = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        try await app.test(.GET, "\(baseURL)/model/by/reference/\(expectedReference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let document = try res.content.decode(Document.self)
                XCTAssertEqual(document.id, documentID)
            } catch {}
        }
    }

    /// Tests the retrieval of a model by its reference with an incorrect reference
    /// - Given: An incorrect reference
    /// - When: The model is retrieved
    /// - Then: The retrieval fails with a not found error
    /// Note: The reference should be a valid string and the document should exist in the database.
    func testGetModelByReferenceWithWrongReferenceFails() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let _ = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)
        let wrongReference = "wrongReference"

        try await app.test(.GET, "\(baseURL)/model/by/reference/\(wrongReference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.implant"))
        }
    }

    /// Tests the retrieval of a model by its reference with an inexistant document
    /// - Given: An inexistant document
    /// - When: The model is retrieved
    /// - Then: The retrieval fails with a not found error
    /// Note: The document should exist in the database.
    func testGetModelByReferenceWithInexistantDocumentFails() async throws {
        let _ = try await ImplantControllerTests().createExpectedImplant(with: UUID(), on: app.db)

        try await app.test(.GET, "\(baseURL)/model/by/reference/\(expectedReference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.document"))
        }
    }
}

// MARK: - Get Download Token For Model
extension ImplantControllerTests {
    /// Tests the retrieval of a download token for a model
    /// - Given: A valid document ID
    /// - When: The download token is retrieved
    /// - Then: The download token is retrieved
    /// Note: The document should exist in the database and the file should exist in the file system.
    func testGetDownloadTokenForModelSucceed() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let _ = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        try await app.test(.GET, "\(baseURL)/download/token/for/model/\(expectedReference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let token = try res.content.decode(String.self)
                XCTAssertFalse(token.isEmpty)
            } catch { }
        }
    }

    /// Tests the retrieval of a download token for a model with an incorrect reference
    /// - Given: An incorrect reference
    /// - When: The download token is retrieved
    /// - Then: The retrieval fails with a not found error
    /// Note: The reference should be a valid string and the document should exist in the database.
    func testGetDownloadTokenForModelWithIncorrectReferenceFails() async throws {
        let wrongReference = "wrong-reference"

        try await app.test(.GET, "\(baseURL)/download/token/for/model/\(wrongReference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.implant"))
        }
    }

    /// Tests the retrieval of a download token for a model with an inexistant document
    /// - Given: An inexistant document
    /// - When: The download token is retrieved
    /// - Then: The retrieval fails with a not found error
    /// Note: The document should exist in the database.
    func testGetDownloadTokenForModelWithInexistantDocumentFails() async throws {
        let _ = try await ImplantControllerTests().createExpectedImplant(with: UUID(), on: app.db)
        try await app.test(.GET, "\(baseURL)/download/token/for/model/\(expectedReference)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.document"))
        }
    }
}
