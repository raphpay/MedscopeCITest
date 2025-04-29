//
//  TokenControllerTests.swift
//  Medscope
//
//  Created by Raphaël Payet on 11/12/2024.
//

@testable import App
import XCTVapor
import Fluent

final class TokenControllerTests: XCTestCase {
    var app: Application!
    var apiKey: APIKey!
    let baseURL = "api/tokens"
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
        apiKey = try await APIKey.saveAPIKey(on: app.db)
    }
    
    override func tearDown() async throws {
        // Clean db
        try await apiKey?.delete(force: true, on: app.db)
        try await User.query(on: app.db).all().delete(force: true, on: app.db)
        try await Token.query(on: app.db).all().delete(force: true, on: app.db)
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
}
