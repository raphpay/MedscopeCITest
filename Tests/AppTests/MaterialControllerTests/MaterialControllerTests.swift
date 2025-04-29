//
//  MaterialControllerTests.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

final class MaterialControllerTests: XCTestCase {
    var app: Application!
    var token: Token!
    var apiKey: APIKey!
    let baseURL = "api/materials"
    
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
        try await Material.query(on: app.db).all().delete(force: true, on: app.db)
        try await Implant.query(on: app.db).all().delete(force: true, on: app.db)
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    // Expected Properties
    let expectedMatName = "expectedMatName"
    let expectedE = Float(87.09)
    let expectedNu = Float(541)
    let expectedSigmaDam = Float(87)
    let expectedSigmaFa = Float(090)
    
    // Implant
    let expectedInternalDiam = Float(514)
    let expectedAbutmentContactHeight = Float(513)
    let expectedDiameter = Float(512)
    let expectedHneck = Float(511)
    let expectedLength = Float(510)
    let expectedMatNameImplant = "expectedMatNameImplant"
    let expectedUpCenter = [Float(16), Float(76)]
    let expectedCenterZ = [Float(1), Float(7)]
    let expectedUpIndex = [Float(160), Float(760)]
}
