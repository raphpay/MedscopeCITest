//
//  DocumentControllerTests.swift
//
//
//  Created by Raphaël Payet on 22/07/2024.
//

@testable import App
import XCTVapor
import Fluent

final class DocumentControllerTests: XCTestCase {
    var app: Application!
    var apiKey: APIKey!
    var token: Token!
    let baseURL = "api/documents"

    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
        token = try await Token.saveToken(on: app.db)
        apiKey = try await APIKey.saveAPIKey(on: app.db)
    }

    override func tearDown() async throws {
        // Clean db
        try await APIKey.query(on: app.db).all().delete(force: true, on: app.db)
        try await Token.query(on: app.db).all().delete(force: true, on: app.db)
        try await Document.query(on: app.db).all().delete(force: true, on: app.db)
        try await SurgeryPlan.query(on: app.db).all().delete(force: true, on: app.db)
        try await Treatment.query(on: app.db).all().delete(force: true, on: app.db)
        try await Patient.query(on: app.db).all().delete(force: true, on: app.db)
        try await FileDownload.query(on: app.db).all().delete(force: true, on: app.db)
        // Clean the upload directory
        let directoryPath = app.directory.resourcesDirectory + "Uploads/"
        try cleanDirectory(atPath: directoryPath)
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }

    /// Cleans the directory at the given path by removing all files.
    /// - Parameter path: The path to the directory to clean.
    /// - Throws: An error if the directory cannot be cleaned.
    /// - Note: This function uses the `FileManager` to check if the directory exists and remove all files within it.
    private func cleanDirectory(atPath path: String) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            let fileURLs = try fileManager.contentsOfDirectory(atPath: path).map { path + $0 }
            for fileURL in fileURLs {
                try fileManager.removeItem(atPath: fileURL)
            }
        }
    }

    // Expected Properties
    let expectedFileName = "testfile.json"
    let expectedFilePath = "test/path/"
    let expectedJsonObject: [String: Any] = ["key1": "value1", "key2": 2, "key3": true]
}
