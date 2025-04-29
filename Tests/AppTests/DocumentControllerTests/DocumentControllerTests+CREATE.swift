//
//  DocumentControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 22/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Create
extension DocumentControllerTests {
    /// Tests the creation of a document.
    /// Given: A valid file name, file path, and JSON content.
    /// When: The document is created.
    /// Then: The document is created successfully.
    /// Note: The file should be saved in the specified path and the content should be valid JSON.
    func testCreateSucceed() async throws {
        let fileContent = try JSONSerialization.data(withJSONObject: expectedJsonObject, options: .prettyPrinted)

        try await app.test(.POST, baseURL, beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            req = Utils.prepareDocumentHeaders(fileName: expectedFileName, filePath: expectedFilePath, fileContent: fileContent, req: req)
        }, afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)

            // Verify the file was created
            let fileURL = URL(fileURLWithPath: app.directory.resourcesDirectory)
                .appendingPathComponent("Uploads")
                .appendingPathComponent(expectedFilePath)
                .appendingPathComponent(expectedFileName)
            XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))

            do {
                // Verify the file content
                let content = try Data(contentsOf: fileURL)
                let decodedJson = try JSONSerialization.jsonObject(with: content, options: []) as? [String: Any]
                XCTAssertEqual(decodedJson?["key1"] as? String, "value1")
                XCTAssertEqual(decodedJson?["key2"] as? Int, 2)
                XCTAssertEqual(decodedJson?["key3"] as? Bool, true)


                // Verify the Document was saved in the database
                let document = try res.content.decode(Document.self)
                XCTAssertEqual(document.name, expectedFileName)
                XCTAssertEqual(document.path, expectedFilePath)
            } catch { }
        })
    }

    /// Tests the creation of a document without a file name.
    /// Given: A valid file path and JSON content.
    /// When: The document is created.
    /// Then: The creation fails with a bad request error.
    /// Note: The file name is required for the document creation.
    func testCreateWithoutFileNameFails() async throws {
        let fileContent = try JSONSerialization.data(withJSONObject: expectedJsonObject, options: .prettyPrinted)

        try await app.test(.POST, baseURL, beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            req = Utils.prepareDocumentHeaders(fileName: nil, filePath: expectedFilePath, fileContent: fileContent, req: req)
        }, afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingFileNameHeader"))
        })
    }

    /// Tests the creation of a document without a file path.
    /// Given: A valid file name and JSON content.
    /// When: The document is created.
    /// Then: The creation fails with a bad request error.
    /// Note: The file path is required for the document creation.
    func testCreateWithoutFilePathFails() async throws {
        let fileContent = try JSONSerialization.data(withJSONObject: expectedJsonObject, options: .prettyPrinted)

        try await app.test(.POST, baseURL, beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            req = Utils.prepareDocumentHeaders(fileName: expectedFileName, filePath: nil, fileContent: fileContent, req: req)
        }, afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingFilePathHeader"))
        })
    }
}
