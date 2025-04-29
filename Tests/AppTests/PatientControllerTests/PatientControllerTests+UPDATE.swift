//
//  PatientControllerTests+UPDATE.swift
//
//
//  Created by Raphaël Payet on 24/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Update
extension PatientControllerTests {
    /// Tests the update of a patient
    /// - Given: A valid input
    /// - When: The patient is updated
    /// - Then: The patient is updated
    func testUpdateSuccess() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let userID = try adminUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        let updatedName = "updatedName"
        let updatedFirstName = "updatedFirstName"
        let updatedBirthdate = "2007-02-08T00:00:00.000Z"
        let updatedGender: Patient.Gender = .female
        let updatedLaGalaxyID = "updatedLaGalaxyID"

        let updateInput = Patient.UpdateInput(name: updatedName, firstName: updatedFirstName,
                                              birthdate: updatedBirthdate, gender: updatedGender,
                                              userID: nil, laGalaxyID: updatedLaGalaxyID)

        try await app.test(.PUT, "\(baseURL)/\(patientID)", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let updatedPatient = try res.content.decode(Patient.self)
				XCTAssertEqual(updatedPatient.name.trimAndLowercase(), updatedName.trimAndLowercase())
				XCTAssertEqual(updatedPatient.firstName.trimAndLowercase(), updatedFirstName.trimAndLowercase())
                XCTAssertEqual(updatedPatient.birthdate, updatedBirthdate)
                XCTAssertEqual(updatedPatient.gender, updatedGender)
                XCTAssertEqual(updatedPatient.laGalaxyID, updatedLaGalaxyID)
            } catch  { }
        })
    }

    /// Tests the update of a patient with an inexistant patient
    /// - Given: An invalid patient UUID
    /// - When: The patient is updated
    /// - Then: The update fails with a not found error
    func testUpdateWithInexistantPatientFails() async throws {
        let updatedName = "Updated Name"
        let updateInput = Patient.UpdateInput(name: updatedName, firstName: nil,
                                              birthdate: nil, gender: nil,
                                              userID: nil, laGalaxyID: nil)
        try await app.test(.PUT, "\(baseURL)/\(UUID())", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.patient"))
        })
    }

    /// Tests the update of a patient with an unauthorized user
    /// - Given: A valid patient, and an unauthorized user
    /// - When: The patient is updated
    /// - Then: The update fails with an unauthorized error
    func testUpdateWithLongNameFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let userID = try adminUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        let incorrectName = "incorrectUsernameojoiefhiouheziuhfuiezhfuihezuifhuiehfuiehuifh"

        let updateInput = Patient.UpdateInput(name: incorrectName, firstName: nil,
                                              birthdate: nil, gender: nil,
                                              userID: nil, laGalaxyID: nil)

        try await app.test(.PUT, "\(baseURL)/\(patientID)", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.nameLength"))
        })
    }

    /// Tests the update of a patient with an unauthorized user
    /// - Given: A valid patient, and an unauthorized user
    /// - When: The patient is updated
    /// - Then: The update fails with an unauthorized error
    func testUpdateWithLongFirstNameFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let userID = try adminUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        let incorrectFirstName = "incorrectUsernameojoiefhiouheziuhfuiezhfuihezuifhuiehfuiehuifh"

        let updateInput = Patient.UpdateInput(name: nil, firstName: incorrectFirstName,
                                              birthdate: nil, gender: nil,
                                              userID: nil, laGalaxyID: nil)

        try await app.test(.PUT, "\(baseURL)/\(patientID)", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.firstNameLength"))
        })
    }

    /// Tests the update of a patient with an unauthorized user
    /// - Given: A valid patient, and an unauthorized user
    /// - When: The patient is updated
    /// - Then: The update fails with an unauthorized error
    func testUpdateWithInvalidBirthdateFormatFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let userID = try adminUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        let incorrectBirthdate = "notADate"

        let updateInput = Patient.UpdateInput(name: nil, firstName: nil,
                                              birthdate: incorrectBirthdate, gender: nil,
                                              userID: nil, laGalaxyID: nil)

        try await app.test(.PUT, "\(baseURL)/\(patientID)", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidDateFormat"))
        })
    }

    /// Tests the update of a patient with an unauthorized user
    /// - Given: A valid patient, and an unauthorized user
    /// - When: The patient is updated
    /// - Then: The update fails with an unauthorized error
    func testUpdateWithInvalidAgeFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let userID = try adminUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        let incorrectBirthdate = "2030-02-08T00:00:00.000Z"

        let updateInput = Patient.UpdateInput(name: nil, firstName: nil,
                                              birthdate: incorrectBirthdate, gender: nil,
                                              userID: nil, laGalaxyID: nil)

        try await app.test(.PUT, "\(baseURL)/\(patientID)", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidAge"))
        })
    }

    /// Tests the update of a patient with an unauthorized user
    /// - Given: A valid patient, and an unauthorized user
    /// - When: The patient is updated
    /// - Then: The update fails with an unauthorized error
    func testUpdateWithInexistantUserFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let userID = try adminUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        let updatedName = "updatedName"

        let updateInput = Patient.UpdateInput(name: updatedName, firstName: nil,
                                              birthdate: nil, gender: nil,
                                              userID: UUID(), laGalaxyID: nil)

        try await app.test(.PUT, "\(baseURL)/\(patientID)", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.userDoesntExist"))
        })
    }

    /// Tests the update of a patient with an unauthorized user
    /// - Given: A valid patient, and an unauthorized user
    /// - When: The patient is updated
    /// - Then: The update fails with an unauthorized error
    func testUpdateWithAlreadyExistingPatientFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let userID = try adminUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        let updatedName = expectedName
        let updatedFirstName = expectedFirstName
        let updatedBirthdate = expectedBirthdate
        let updatedUserID = userID

        let updateInput = Patient.UpdateInput(name: updatedName, firstName: updatedFirstName,
                                              birthdate: updatedBirthdate, gender: nil,
                                              userID: nil, laGalaxyID: nil)

        try await app.test(.PUT, "\(baseURL)/\(patientID)", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .conflict)
            XCTAssertTrue(res.body.string.contains("conflict.patientAlreadyExists"))
        })
    }
}
