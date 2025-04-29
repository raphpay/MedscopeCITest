//
//  PatientControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 24/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Create
extension PatientControllerTests {
    /// Tests the creation of a new patient
    /// - Given: A valid user and patient input
    /// - When: The patient is created
    /// - Then: The patient is created
    func testCreateSucceed() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        let input = Patient.Input(name: expectedName, firstName: expectedFirstName, birthdate: expectedBirthdate, gender: expectedGender, userID: userID, laGalaxyID: expectedLaGalaxyID)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let patient = try res.content.decode(Patient.self)
                XCTAssertEqual(patient.name, expectedName.trimAndLowercase())
                XCTAssertEqual(patient.firstName, expectedFirstName.trimAndLowercase())
                XCTAssertEqual(patient.birthdate, expectedBirthdate)
                XCTAssertEqual(patient.laGalaxyID, expectedLaGalaxyID)
                XCTAssertEqual(patient.$user.id, userID)
            } catch { }
        }
    }

    /// Tests the creation of a new patient with an inexistant user
    /// - Given: A valid patient input and an inexistant user
    /// - When: The patient is created
    /// - Then: The creation fails with a bad request error
    func testCreateWithInexistantUserFails() async throws {
        let input = Patient.Input(name: expectedName, firstName: expectedFirstName, birthdate: expectedBirthdate, gender: expectedGender, userID: UUID(), laGalaxyID: expectedLaGalaxyID)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.userDoesntExist"))
        }
    }

    /// Tests the creation of a new patient with an already created patient
    /// - Given: A patient is created, a valid user and patient input are passed
    /// - When: The patient is created
    /// - Then: The patient is retrieved with the correct informations
    func testCreateAlreadyExistantPatientSucceed() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()

        let _ = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let input = Patient.Input(name: expectedName, firstName: expectedFirstName, birthdate: expectedBirthdate, gender: expectedGender, userID: userID, laGalaxyID: expectedLaGalaxyID)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let patient = try res.content.decode(Patient.self)
                XCTAssertEqual(patient.name, expectedName.trimAndLowercase())
                XCTAssertEqual(patient.firstName, expectedFirstName.trimAndLowercase())
                XCTAssertEqual(patient.birthdate, expectedBirthdate)
                XCTAssertEqual(patient.laGalaxyID, expectedLaGalaxyID)
                XCTAssertEqual(patient.$user.id, userID)

                let patients = try await Patient.query(on: app.db).all()
                XCTAssertEqual(patients.count, 1)
            } catch { }
        }
    }
}
