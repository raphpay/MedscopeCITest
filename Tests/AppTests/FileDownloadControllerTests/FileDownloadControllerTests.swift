//
//  FileDownloadControllerTests.swift
//
//
//  Created by Raphaël Payet on 14/07/2024.
//

@testable import App
import XCTVapor
import Fluent

final class FileDownloadControllerTests: XCTestCase {
    var app: Application!
    var apiKey: APIKey!
    var token: Token!
    let baseURL = "api/fileDownloads"
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
        token = try await Token.saveToken(on: app.db)
        apiKey = try await APIKey.saveAPIKey(on: app.db)
    }
    
    override func tearDown() async throws {
        // Clean db
        try await apiKey?.delete(force: true, on: app.db)
        try await token?.delete(force: true, on: app.db)
        try await FileDownload.query(on: app.db).all().delete(force: true, on: app.db)
        
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    // Expected Properties
    let expectedPath = "expected/path/"
}
