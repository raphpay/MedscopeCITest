//
//  APIKeyControllerTests.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

final class APIKeyControllerTests: XCTestCase {
    var app: Application!
    let baseURL = "api/apiKeys"
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
    }
    
    override func tearDown() async throws {
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    // Expected properties
    let expectedName = "expectedName"
}
