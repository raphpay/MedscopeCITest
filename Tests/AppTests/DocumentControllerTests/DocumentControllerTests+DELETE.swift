//
//  DocumentControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 25/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Delete
extension DocumentControllerTests {
    /// Test the deletion of a document
    /// - Given: A valid document ID
    /// - When: The document is deleted
    /// - Then: The document is deleted successfully
    /// - Note: The document ID should be a valid UUID and the document should exist in the database.
    ///   The file associated with the document should also be deleted from the file system.
    func testDeleteSucceed() async throws {
        let fileContent = try JSONSerialization.data(withJSONObject: expectedJsonObject, options: .prettyPrinted)
        let filePath = app.directory.resourcesDirectory + "Uploads/" + expectedFilePath

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        try DocumentControllerTests().createExpectedFile(with: fileContent, at: filePath)
        let documentID = try document.requireID()

        try await app.test(.DELETE, "\(baseURL)/\(documentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            do {
                let documents = try await Document.query(on: app.db).all()
                XCTAssertEqual(documents.count, 0)
                XCTAssertFalse(FileManager.default.fileExists(atPath: filePath))
            } catch { }
        }
    }

    /// Test the deletion of a document with an incorrect ID
    /// - Given: An incorrect document ID
    /// - When: The document is deleted
    /// - Then: The deletion fails with a bad request error
    /// - Note: The document ID should be a valid UUID and the document should exist in the database.
    func testDeleteWithIncorrectIDFails() async throws {
        try await app.test(.DELETE, "\(baseURL)/documentID") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectDocumentID"))
        }
    }

    /// Test the deletion of a document with an inexistant ID
    /// - Given: An inexistant document ID
    /// - When: The document is deleted
    /// - Then: The deletion fails with a not found error
    /// - Note: The document ID should be a valid UUID and the document should exist in the database.
    func testDeleteWithInexistantDocumentFails() async throws {
        let falseDocumentID = UUID()
        try await app.test(.DELETE, "\(baseURL)/\(falseDocumentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.document"))
        }
    }

    /// Test the deletion of a document with an unauthorized user
    /// - Given: An unauthorized user
    /// - When: The document is deleted
    /// - Then: The deletion fails with an unauthorized error
    /// - Note: The user should have the required permissions to delete the document.
    ///   The user should be an admin.
    func testDeleteWithUnauthorizedUserFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .companyOperator, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)

        let fileContent = try JSONSerialization.data(withJSONObject: expectedJsonObject, options: .prettyPrinted)
        let filePath = app.directory.resourcesDirectory + "Uploads/" + expectedFilePath

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        try DocumentControllerTests().createExpectedFile(with: fileContent, at: filePath)
        let documentID = try document.requireID()

        try await app.test(.DELETE, "\(baseURL)/\(documentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }
}

// MARK: - Delete All
extension DocumentControllerTests {
    /// Test the deletion of all documents
    /// - Given: A valid request to delete all documents
    /// - When: The documents are deleted
    /// - Then: All documents are deleted successfully
    /// - Note: The documents should be deleted from the database and the associated files should be removed from the file system.
    func testDeleteAllSucceed() async throws {
        let fileContent = try JSONSerialization.data(withJSONObject: expectedJsonObject, options: .prettyPrinted)
        let filePath = app.directory.resourcesDirectory + "Uploads/" + expectedFilePath

        let _ = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        try DocumentControllerTests().createExpectedFile(with: fileContent, at: filePath)

        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            do {
                let documents = try await Document.query(on: app.db).all()
                XCTAssertEqual(documents.count, 0)
                XCTAssertFalse(FileManager.default.fileExists(atPath: filePath))
            } catch { }
        }
    }

    /// Test the deletion of all documents with an unauthorized user
    /// - Given: An unauthorized user
    /// - When: The documents are deleted
    /// - Then: The deletion fails with an unauthorized error
    /// - Note: The user should have the required permissions to delete all documents.
    ///  The user should be an admin.
    func testDeleteAllWithUnauthorizedUserFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .companyOperator, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)

        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }
}

// MARK: - Delete all at directory
extension DocumentControllerTests {
    /// Test the deletion of all documents at a specific directory
    /// - Given: A valid request to delete all documents at a specific directory
    /// - When: The documents are deleted
    /// - Then: All documents at the specified directory are deleted successfully
    /// - Note: The documents should be deleted from the database and the associated files should be removed from the file system.
    ///  The directory should be specified in the request body.
    func testDeleteAllAtDirectorySucceed() async throws {
        let fileContent = try JSONSerialization.data(withJSONObject: expectedJsonObject, options: .prettyPrinted)
        let filePath = app.directory.resourcesDirectory + "Uploads/" + expectedFilePath

        let _ = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        try DocumentControllerTests().createExpectedFile(with: fileContent, at: filePath)

        let input = Document.DirectoryInput(name: expectedFileName, path: expectedFilePath)

        try await app.test(.DELETE, "\(baseURL)/all/at/directory") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(input)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            do {
                let documents = try await Document.query(on: app.db).all()
                XCTAssertEqual(documents.count, 0)
                XCTAssertFalse(FileManager.default.fileExists(atPath: filePath))
            } catch { }
        }
    }
}
