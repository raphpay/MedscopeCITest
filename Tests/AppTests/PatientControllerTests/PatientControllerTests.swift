//
//  PatientControllerTests.swift
//
//
//  Created by Raphaël Payet on 24/07/2024.
//


@testable import App
import XCTVapor
import Fluent

final class PatientControllerTests: XCTestCase {
    var app: Application!
    var apiKey: APIKey!
    var token: Token!
    let baseURL = "api/patients"
    
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
        try await token.delete(force: true, on: app.db)
        try await User.query(on: app.db).all().delete(force: true, on: app.db)
        try await Token.query(on: app.db).all().delete(force: true, on: app.db)
        try await Patient.query(on: app.db).all().delete(force: true, on: app.db)
        try await Treatment.query(on: app.db).all().delete(force: true, on: app.db)
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    // Expected Properties
    let expectedName = "expectedName"
    let expectedFirstName = "expectedFirstName"
    let expectedBirthdate = "2007-01-08T00:00:00.000Z"
    let expectedGender = Patient.Gender.male
    let expectedLaGalaxyID = "expectedLaGalaxyID"
    let expectedMedscopeID = "MEDP0001"
    // Invalid
    let invalidDate = "2007-01-08"
    let wrongTreatmentDate = "2007-01-09T00:00:00Z"
    // Treatment
    let expectedTreatmentDate = "2007-01-08T00:00:00Z"
    let expectedTreatmentAffectedBone = Treatment.AffectedBone.both
}
