//
//  FormControllerTests.swift
//
//
//  Created by Raphaël Payet on 18/07/2024.
//

@testable import App
import XCTVapor
import Fluent

final class FormControllerTests: XCTestCase {
    var app: Application!
    let baseURL = "api/forms"
    var apiKey: APIKey!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
        apiKey = try await APIKey.saveAPIKey(on: app.db)
    }
    
    override func tearDown() async throws {
        try await apiKey?.delete(force: true, on: app.db)
        try await User.query(on: app.db).all().delete(force: true, on: app.db)
        try await Token.query(on: app.db).all().delete(force: true, on: app.db)
        try await Patient.query(on: app.db).all().delete(force: true, on: app.db)
        try await Treatment.query(on: app.db).all().delete(force: true, on: app.db)
        try await Document.query(on: app.db).all().delete(force: true, on: app.db)
        try await SurgeryPlan.query(on: app.db).all().delete(force: true, on: app.db)
        try await Implant.query(on: app.db).all().delete(force: true, on: app.db)
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    // Expected properties
    // User
    let expectedUserName = "expectedAdminName"
    let expectedName = "expectedName"
    let expectedPassword = "expectedPassword1("
    // Patient
    let expectedPatientName = "expectedName"
    let expectedPatientFirstName = "expectedPatientFirstName"
    let expectedPatientGender = Patient.Gender.female
    let expectedPatientLaGalaxyID = "expectedPatientLaGalaxyID"
    // Treatment
    let expectedTreatmentDate = "2007-01-08T00:00:00.000Z"
    let expectedAffectedBone = Treatment.AffectedBone.both
    // Incorrect Properties
    let incorrectPatientBirthdate = "2007-01-08T00:00:00Z"
    let incorrectTreatmentDate = "2007-01-08T00:00:00Z"
    let wrongAgePatientBirthdate = "2027-01-08T00:00:00.000Z"
}
