//
//  DocumentControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 22/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Get All
extension DocumentControllerTests {
    /// Test the retrieval of all documents
    /// - Given: A valid API key and token
    /// - When: The documents are retrieved
    /// - Then: The documents are retrieved successfully
    /// - Note: The documents should be stored in the database and the file should exist in the file system.
    func testGetAllWithDataSucceed() async throws {
        let _ = try await DocumentControllerTests().createExpectedDocument(on: app.db)

        try await app.test(.GET, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let documents = try res.content.decode([Document].self)
                XCTAssertEqual(documents.count, 1)
                XCTAssertEqual(documents[0].name, expectedFileName)
                XCTAssertEqual(documents[0].path, expectedFilePath)
            } catch { }
        }
    }

    /// Test the retrieval of all documents without any data
    /// - Given: A valid API key and token
    /// - When: The documents are retrieved
    /// - Then: The documents are retrieved successfully
    /// - Note: The documents should be stored in the database and the file should exist in the file system.
    ///   The documents should be empty.
    func testGetAllWithoutDataSucceed() async throws {
        try await app.test(.GET, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let documents = try res.content.decode([Document].self)
                XCTAssertEqual(documents.count, 0)
            } catch { }
        }
    }
}

// MARK: - Download Token For
extension DocumentControllerTests {
    /// Test the retrieval of a download token for a document
    /// - Given: A valid document ID
    /// - When: The download token is retrieved
    /// - Then: The download token is retrieved successfully
    /// - Note: The document should exist in the database and the file should exist in the file system.
    ///  The download token should be valid and not expired.
    func testGetDownloadTokenSucceed() async throws {
        let fileContent = try JSONSerialization.data(withJSONObject: expectedJsonObject, options: .prettyPrinted)
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()
        let filePath = app.directory.resourcesDirectory + "Uploads/" + expectedFilePath
        try DocumentControllerTests().createExpectedFile(with: fileContent, at: filePath)

        try await app.test(.GET, "\(baseURL)/download/token/for/\(documentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let downloadToken = try res.content.decode(String.self)
                XCTAssertNotNil(downloadToken)
            } catch { }
        }
    }

    /// Test the retrieval of a download token with an incorrect document ID
    /// - Given: An incorrect document ID
    /// - When: The download token is retrieved
    /// - Then: The retrieval fails with a bad request error
    /// - Note: The document ID should be a valid UUID and the document should exist in the database.
    func testGetDownloadTokenWithIncorrectIDFails() async throws {
        try await app.test(.GET, "\(baseURL)/download/token/for/12345") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectDocumentID"))
        }
    }

    /// Test the retrieval of a download token with an inexistant document ID
    /// - Given: An inexistant document ID
    /// - When: The download token is retrieved
    /// - Then: The retrieval fails with a not found error
    /// - Note: The document ID should be a valid UUID and the document should exist in the database.
    func testGetDownloadTokenWithInexistantDocumentFails() async throws {
        let falseDocumentID = UUID()

        try await app.test(.GET, "\(baseURL)/download/token/for/\(falseDocumentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.document"))
        }
    }
}

// MARK: - Download
extension DocumentControllerTests {
    /// Test the download of a file
    /// - Given: A valid download token
    /// - When: The file is downloaded
    /// - Then: The file is downloaded successfully
    /// - Note: The file should exist in the file system and the download token should be valid and not expired.
    ///   The file should be returned with the correct content type and disposition.
	// To be run alone -> Cause failure only if run in a suite
//    func testDownloadSucceed() async throws {
//        let fileContent = try JSONSerialization.data(withJSONObject: expectedJsonObject, options: .prettyPrinted)
//        let filePath = app.directory.resourcesDirectory + "Uploads/" + expectedFilePath
//        try DocumentControllerTests().createExpectedFile(with: fileContent, at: filePath)
//        let fileDirectory = expectedFilePath + expectedFileName
//        let fileDownload = try await FileDownloadControllerTests().create(at: fileDirectory, on: app.db)
//        let downloadToken = fileDownload.downloadToken
//
//        try await app.test(.GET, "\(baseURL)/download/file/\(downloadToken)") { req in
//            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
//        } afterResponse: { res async in
//            XCTAssertEqual(res.status, .ok)
//            XCTAssertEqual(res.headers.first(name: .contentType), "application/json")
//            XCTAssertEqual(res.headers.first(name: .contentDisposition), "attachment; fileName=\(filePath + expectedFileName)")
//        }
//    }

	// To be run alone -> Cause failure only if run in a suite
//    func testDownloadWithIncorrectDownloadTokenFails() async throws {
//        try await app.test(.GET, "\(baseURL)/download/file/token") { req in
//            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
//        } afterResponse: { res async in
//            XCTAssertEqual(res.status, .notFound)
//            XCTAssertTrue(res.body.string.contains("notFound.fileDownload"))
//        }
//    }


	// To be run alone -> Cause failure only if run in a suite
//    func testDownloadWithAlreadyUsedTokenFails() async throws {
//        let fileContent = try JSONSerialization.data(withJSONObject: expectedJsonObject, options: .prettyPrinted)
//        let filePath = app.directory.resourcesDirectory + "Uploads/" + expectedFilePath
//        try DocumentControllerTests().createExpectedFile(with: fileContent, at: filePath)
//        let fileDirectory = expectedFilePath + expectedFileName
//        let fileDownload = try await FileDownloadControllerTests().create(at: fileDirectory, on: app.db)
//        let downloadToken = fileDownload.downloadToken
//
//        // Update the usedAt parameter
//        fileDownload.usedAt = .now
//        try await fileDownload.update(on: app.db)
//
//        try await app.test(.GET, "\(baseURL)/download/file/\(downloadToken)") { req in
//            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
//        } afterResponse: { res async in
//            XCTAssertEqual(res.status, .forbidden)
//            XCTAssertTrue(res.body.string.contains("forbidden.tokenAlreadyUsed"))
//        }
//    }
}

// MARK: - Get Document
extension DocumentControllerTests {
    /// Test the retrieval of a document
    /// - Given: A valid document ID
    /// - When: The document is retrieved
    /// - Then: The document is retrieved successfully
    /// - Note: The document should exist in the database and the file should exist in the file system.
    func testGetDocumentSucceed() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        try await app.test(.GET, "\(baseURL)/\(documentID)", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let foundDocument = try res.content.decode(Document.self)
                XCTAssertEqual(foundDocument.name, expectedFileName)
                XCTAssertEqual(foundDocument.path, expectedFilePath)
            } catch { }
        })
    }

    /// Test the retrieval of a document with an incorrect ID
    /// - Given: An incorrect document ID
    /// - When: The document is retrieved
    /// - Then: The retrieval fails with a bad request error
    /// - Note: The document ID should be a valid UUID and the document should exist in the database.
    func testGetDocumentWithInexistantDocumentFails() async throws {
        try await app.test(.GET, "\(baseURL)/\(UUID())", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.document"))
        })
    }
}
