//
//  ImplantControllerTests.swift
//  
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

final class ImplantControllerTests: XCTestCase {
    var app: Application!
    var apiKey: APIKey!
    var token: Token!
    let baseURL = "api/implants"
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
        apiKey = try await APIKey.saveAPIKey(on: app.db)
        token = try await Token.saveToken(on: app.db)
    }
    
    override func tearDown() async throws {
        // Clean db
        try await apiKey?.delete(force: true, on: app.db)
        try await token?.delete(force: true, on: app.db)
        try await Treatment.query(on: app.db).all().delete(force: true, on: app.db)
        try await SurgeryPlan.query(on: app.db).all().delete(force: true, on: app.db)
        try await Implant.query(on: app.db).all().delete(force: true, on: app.db)
        try await Material.query(on: app.db).all().delete(force: true, on: app.db)
        try await Patient.query(on: app.db).all().delete(force: true, on: app.db)
        try await Document.query(on: app.db).all().delete(force: true, on: app.db)
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    // Expected Properties
    let expectedReference = "K43608"
    let expectedInternalDiam = Float(514)
    let expectedAbutmentContactHeight = Float(513)
    let expectedDiameter = Float(512)
    let expectedHneck = Float(511)
    let expectedLength = Float(510)
    let expectedMatName = "expectedMatName"
    let expectedUpCenter = [Float(16), Float(76), Float(5)]
    let expectedCenterZ = [Float(1), Float(7), Float(6)]
    let expectedUpIndex = [Float(160), Float(760), Float(8)]
    let expectedModelID = "4F2120E3-1451-49C3-8C89-A158C64452B7"
    
    // Material
    let expectedMaterialMatName = "expectedMaterialMatName"
    let expectedMaterialE = Float(87.09)
    let expectedMaterialNu = Float(541)
    let expectedMaterialSigmaDam = Float(87)
    let expectedMaterialSigmaFa = Float(090)
    
    // Invalid data
    let invalidUpCenter = [Float(1), Float(2)]
    let invalidUpIndex = [Float(1), Float(2)]
    let invalidCenterZ = [Float(1), Float(2)]
    let invalidDepth = [Float(1), Float(2.8727)]
}
