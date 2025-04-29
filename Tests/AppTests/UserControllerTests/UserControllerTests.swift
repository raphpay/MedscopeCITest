//
//  UserControllerTests.swift
//
//
//  Created by Raphaël Payet on 14/07/2024.
//

@testable import App
import XCTVapor
import Fluent

final class UserControllerTests: XCTestCase {
    var app: Application!
    var apiKey: APIKey!
    var token: Token!
    let baseURL = "api/users"
    
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
    // User
    let expectedName = "expectedName"
    let expectedFirstName = "expectedFirstName"
    let expectedAddress = "expectedAddress"
    let expectedMailAddress = "expectedMailAddress@test.com"
    let expectedPassword = "Passwordlong2("
    let expectedRole = User.Role.companyOperator
    let expectedConditionsAccepted = true
    let expectedConditionsAcceptedTimestamp = "2024-09-13T14:33:10.123Z"
    let expectedLoginFailedAttempts = 0
    let expectedLastLoginFailedAttempt = "2024-09-13T14:33:10.123Z"
    // Admin
    let expectedAdminName = "expectedAdminName"
    let expectedAdminFirstName = "expectedAdminFirstName"
    let expectedAdminAddress = "expectedAdminAddress"
    let expectedAdminMailAddress = "expectedAdminMailAddress@test.com"
    let expectedAdminPassword = "expectedAdminPassword2("
    let expectedAdminRole = User.Role.admin
    
    // Patient
    let expectedPatientName = "expectedPatientName"
    let expectedPatientFirstName = "expectedPatientFirstName"
    let expectedBirthdate = "2007-01-08T00:00:00Z"
    let expectedGender = Patient.Gender.male
    let expectedPatientMedscopeID = "MEDP0001"
    let expectedPatientLaGalaxyID = "expectedPatientLaGalaxyID"
    
    // Invalid properties
    // Names
    let longName = "qvZX3mLpN8fRtHyEjKcW9sBnA7dGiUoP1"
    let longFirstName = "bQwF5xYzC2uIoMrDhS6gJ4kTlEaVnLpX9"
    // Address
    let longAddress = "7fRtHyEjKcW9sBnA7dGiUoPqvZX3mLpN8bQwF5xYzC2uIoMrDhS6gJ4kTlEaVnLpX9aSDFGHJKLMNBVCXZPOIUYTREWQ1234567890qwertyuiopasdfghjklzxcvbnmiuhuih"
    let incorrectMail = "test@"
    // Passwords
    let incorrectPasswordLength = "passw"
    let incorrectPasswordUppercase = "password"
    let incorrectPasswordDigit = "Password"
    let incorrectPasswordSymbol = "Password1"
    // Date
    let incorrectConditionsAcceptedTimestamp = "2024-09-13T14::10.12Z"
}
