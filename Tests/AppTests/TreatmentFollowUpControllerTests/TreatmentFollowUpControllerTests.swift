//
//  TreatmentFollowUpControllerTests.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

@testable import App
import XCTVapor
import Fluent

final class TreatmentFollowUpControllerTests: XCTestCase {
    var app: Application!
    var apiKey: APIKey!
    var token: Token!
    let baseURL = "api/treatmentFollowUps"
    var patient: Patient!
    var patientID: Patient.IDValue!
    var treatment: Treatment!
    var treatmentID: Treatment.IDValue!
    var versionLog: VersionLog!
    var operatorUser: User!
    var operatorID: User.IDValue!
    var validator: User!
    var validatorID: User.IDValue!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
        token = try await Token.saveToken(on: app.db)
        apiKey = try await APIKey.saveAPIKey(on: app.db)
        patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        patientID = try patient.requireID()
        treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        treatmentID = try treatment.requireID()
        versionLog = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        operatorUser = try await UserControllerTests().createExpectedUser(on: app.db)
        operatorID = try operatorUser.requireID()
        validator = try await UserControllerTests().createExpectedUser(on: app.db)
        validatorID = try validator.requireID()
    }
    
    override func tearDown() async throws {
        // Clean db
        try await apiKey?.delete(force: true, on: app.db)
        try await token?.delete(force: true, on: app.db)
        try await APIKey.query(on: app.db).all().delete(force: true, on: app.db)
        try await Token.query(on: app.db).all().delete(force: true, on: app.db)
        try await User.query(on: app.db).all().delete(force: true, on: app.db)
        try await Token.query(on: app.db).all().delete(force: true, on: app.db)
        try await Patient.query(on: app.db).all().delete(force: true, on: app.db)
        try await Treatment.query(on: app.db).all().delete(force: true, on: app.db)
        
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    // Expected Properties
    // Creation
    let expectedCreationDate = "2024-09-13T14:33:10.123Z"
    let expectedCreationStatus = TreatmentFollowUp.Status.received
    // Calculation
    let expectedCalculationDate = "2024-09-13T14:33:10.123Z"
    let expectedCalculationStatus = TreatmentFollowUp.Status.inProgress
    // Validation
    let expectedValidationDate = "2024-09-13T14:33:10.123Z"
    let expectedValidationStatus = TreatmentFollowUp.Status.sent
    // Opening
    let expectedFirstOpenDate = "2024-09-13T14:33:10.123Z"
    let expectedFirstOpenStatus = TreatmentFollowUp.Status.open
    // Invalid
    let invalidDate = "invalidDate"
}
