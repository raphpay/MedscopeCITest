//
//  VersionLogTests.swift
//  Medscope
//
//  Created by Raphaël Payet on 14/10/2024.
//

@testable import App
import XCTVapor
import Fluent

final class VersionLogControllerTests: XCTestCase {
    var app: Application!
    var apiKey: APIKey!
    var token: Token!
    let baseURL = "api/versionLogs"
    
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
        try await User.query(on: app.db).all().delete(force: true, on: app.db)
        try await Token.query(on: app.db).all().delete(force: true, on: app.db)
        
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    // Expected Properties
    let expectedInterfaceVersion = "0.1.001"
    let expectedAPIVersion = "0.2.002"
    let expectedCalculatorVersion = "0.3.003"
    let expectedSubmissionPlatformVersion = "0.4.004"
    let expectedPackage = 0
    let expectedUDI = "1234MEDSCOPEYT"
}
