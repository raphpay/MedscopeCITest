//
//  TreatmentControllerTests.swift
//
//
//  Created by Raphaël Payet on 23/07/2024.
//

@testable import App
import XCTVapor
import Fluent

final class TreatmentControllerTests: XCTestCase {
    var app: Application!
    var apiKey: APIKey!
    var token: Token!
    let baseURL = "api/treatments"
    
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
        try await Patient.query(on: app.db).all().delete(force: true, on: app.db)
        try await Document.query(on: app.db).all().delete(force: true, on: app.db)
        try await Treatment.query(on: app.db).all().delete(force: true, on: app.db)
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    // Expected Properties
    let expectedAffectedBone = Treatment.AffectedBone.both
    let expectedDate = "2007-01-08T00:00:00.000Z"
    let expectedPatientID = UUID()
    let expectedDicomFileID = UUID()
    // Invalid properties
    let invalidDate = "2007-01-08"
    // Patient
    let expectedPatientName = "expectedName"
    let expectedPatientFirstName = "expectedFirstName"
    let expectedPatientBirthdate = "2007-01-08T00:00:00.000Z"
    let expectedPatientGender = Patient.Gender.male
    let expectedPatientLaGalaxyID = "expectedPatientLaGalaxyID"
    let expectedPatientMedscopeID = "MEDP0001"
}
