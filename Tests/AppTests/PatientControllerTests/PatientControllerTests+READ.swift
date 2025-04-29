//
//  PatientControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 24/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Get All
extension PatientControllerTests {
    /// Tests the retrieval of all patients
    /// - Given: A valid patient input
    /// - When: The patients are retrieved
    /// - Then: The patients are retrieved
    func testGetAllSucceed() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let userID = try adminUser.requireID()
        let _ = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)

        try await app.test(.GET, baseURL) { req in
            req.headers.add(name: "api-key", value: apiKey.value)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let patients = try res.content.decode([Patient].self)
                XCTAssertEqual(patients.count, 1)
                XCTAssertEqual(patients[0].name, expectedName.trimAndLowercase())
                XCTAssertEqual(patients[0].firstName, expectedFirstName.trimAndLowercase())
                XCTAssertEqual(patients[0].birthdate, expectedBirthdate)
                if let laGalaxyID = patients[0].laGalaxyID {
                    XCTAssertEqual(laGalaxyID, expectedLaGalaxyID)
                }
                XCTAssertEqual(patients[0].$user.id, userID)
            } catch { }
        }
    }
}

// MARK: - Get Patient
extension PatientControllerTests {
    /// Tests the retrieval of a patient
    /// - Given: A valid patient input
    /// - When: The patient is retrieved
    /// - Then: The patient is retrieved
    /// - Note: The user should be an admin.
    func testGetPatient() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let userID = try adminUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        try await app.test(.GET, "\(baseURL)/\(patientID)") { req in
            req.headers.add(name: "api-key", value: apiKey.value)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let createdPatient = try res.content.decode(Patient.self)
                XCTAssertEqual(createdPatient.name, expectedName.trimAndLowercase())
                XCTAssertEqual(createdPatient.firstName, expectedFirstName.trimAndLowercase())
                XCTAssertEqual(createdPatient.birthdate, expectedBirthdate)
                if let laGalaxyID = createdPatient.laGalaxyID {
                    XCTAssertEqual(laGalaxyID, expectedLaGalaxyID)
                }
                XCTAssertEqual(createdPatient.$user.id, userID)
            } catch { }
        }
    }

    /// Tests the retrieval of a patient with an incorrect ID
    /// - Given: A valid patient input
    /// - When: The patient is retrieved
    /// - Then: The retrieval fails with a bad request error
    func testGetPatientWithWrongIDFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)

        try await app.test(.GET, "\(baseURL)/patientID") { req in
            req.headers.add(name: "api-key", value: apiKey.value)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingPatientID"))
        }
    }

    /// Tests the retrieval of a patient with an inexistant ID
    /// - Given: A valid patient input
    /// - When: The patient is retrieved
    /// - Then: The retrieval fails with a not found error
    func testGetPatientWithInexistantPatientFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)

        let falsePatientID = UUID()

        try await app.test(.GET, "\(baseURL)/\(falsePatientID)") { req in
            req.headers.add(name: "api-key", value: apiKey.value)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.patient"))
        }
    }
}

// MARK: - Get Treatments
extension PatientControllerTests {
    /// Tests the retrieval of treatments
    /// - Given: A valid patient input
    /// - When: The treatments are retrieved
    /// - Then: The treatments are retrieved
    func testGetTreatmentsSucceed() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let userID = try adminUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        let _ = try await Treatment.create(date: expectedTreatmentDate, affectedBone: expectedTreatmentAffectedBone, patientID: patientID, dicomID: UUID(), model3Ds: [UUID()], on: app.db)

        try await app.test(.GET, "\(baseURL)/treatment/\(patientID)") { req in
            req.headers.add(name: "api-key", value: apiKey.value)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let treatments = try res.content.decode([Treatment].self)
                XCTAssertEqual(treatments.count, 1)
                XCTAssertEqual(treatments[0].$patient.id, patientID)
                XCTAssertEqual(treatments[0].date, expectedTreatmentDate)
                XCTAssertEqual(treatments[0].affectedBone, expectedTreatmentAffectedBone)
            } catch { }
        }
    }

    /// Tests the retrieval of treatments with an incorrect ID
    /// - Given: An invalid patient input
    /// - When: The treatments are retrieved
    /// - Then: The retrieval fails with a bad request error
    func testGetTreatmentsWithWrongPatientIDFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)

        try await app.test(.GET, "\(baseURL)/treatment/patientID") { req in
            req.headers.add(name: "api-key", value: apiKey.value)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingPatientID"))
        }
    }

    /// Tests the retrieval of treatments with an inexistant ID
    /// - Given: An invalid patient input
    /// - When: The treatments are retrieved
    /// - Then: The retrieval fails with a not found error
    func testGetTreatmentsWithInexistantPatientIDFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)

        let falsePatientID = UUID()
        try await app.test(.GET, "\(baseURL)/treatment/\(falsePatientID)") { req in
            req.headers.add(name: "api-key", value: apiKey.value)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.patient"))
        }
    }
}

// MARK: - Get treatment at date
extension PatientControllerTests {
    /// Tests the retrieval of a treatment at a specific date
    /// - Given: A valid patient input
    /// - When: The treatment is retrieved
    /// - Then: The treatment is retrieved
    func testGetTreatmentAtDateSucceed() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let userID = try adminUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        let _ = try await Treatment.create(date: expectedTreatmentDate, affectedBone: expectedTreatmentAffectedBone, patientID: patientID, dicomID: UUID(), model3Ds: [UUID()], on: app.db)
        let dateInput = Patient.TreatmentDateInput(date: expectedTreatmentDate)

        try await app.test(.GET, "\(baseURL)/treatment/atDate/\(patientID)") { req in
            try req.content.encode(dateInput)
            req.headers.add(name: "api-key", value: apiKey.value)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let treatment = try res.content.decode(Treatment.self)
                XCTAssertEqual(treatment.date, expectedTreatmentDate)
                XCTAssertEqual(treatment.$patient.id, patientID)
            } catch { }
        }
    }

    /// Tests the retrieval of a treatment at a specific date with an incorrect ID
    /// - Given: An invalid patient input
    /// - When: The treatment is retrieved
    /// - Then: The retrieval fails with a bad request error
    /// - Note: The patient ID should be a valid UUID and the treatment should exist in the database.
    func testGetTreatmentAtDateWithWrongIDFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)

        let dateInput = Patient.TreatmentDateInput(date: expectedTreatmentDate)

        try await app.test(.GET, "\(baseURL)/treatment/atDate/patientID") { req in
            try req.content.encode(dateInput)
            req.headers.add(name: "api-key", value: apiKey.value)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingPatientID"))
        }
    }

    /// Tests the retrieval of a treatment at a specific date with an inexistant ID
    /// - Given: An invalid patient input
    /// - When: The treatment is retrieved
    /// - Then: The retrieval fails with a not found error
    /// - Note: The patient ID should be a valid UUID and the treatment should exist in the database.
    func testGetTreatmentAtDateWithInexistantPatientFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)

        let falsePatientID = UUID()
        let dateInput = Patient.TreatmentDateInput(date: expectedTreatmentDate)

        try await app.test(.GET, "\(baseURL)/treatment/atDate/\(falsePatientID)") { req in
            try req.content.encode(dateInput)
            req.headers.add(name: "api-key", value: apiKey.value)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.patient"))
        }
    }

    /// Tests the retrieval of a treatment at a specific date with an inexistant treatment
    /// - Given: An invalid patient input
    /// - When: The treatment is retrieved
    /// - Then: The retrieval fails with a not found error
    /// - Note: The patient ID should be a valid UUID and the treatment should exist in the database.
    func testGetTreatmentAtDateWithInexistantTreatmentFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let userID = try adminUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        let _ = try await Treatment.create(date: expectedTreatmentDate, affectedBone: expectedTreatmentAffectedBone, patientID: patientID, dicomID: UUID(), model3Ds: [UUID()], on: app.db)
        let dateInput = Patient.TreatmentDateInput(date: wrongTreatmentDate)

        try await app.test(.GET, "\(baseURL)/treatment/atDate/\(patientID)") { req in
            try req.content.encode(dateInput)
            req.headers.add(name: "api-key", value: apiKey.value)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertTrue(res.body.string.contains("notFound.treatment"))
        }
    }
}

// MARK: - Get By MedscopeID
extension PatientControllerTests {
    /// Tests the retrieval of a patient by MedscopeID
    /// - Given: A valid patient input
    /// - When: The patient is retrieved
    /// - Then: The patient is retrieved
    /// - Note: The user should be an admin.
    func testGetByMedscopeIDSucceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        let patientMedscopeID = patient.medscopeID

        try await app.test(.GET, "\(baseURL)/medscopeID/\(patientMedscopeID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let patient = try res.content.decode(Patient.self)
                XCTAssertEqual(patient.id, patientID)
                XCTAssertEqual(patient.name, expectedName.trimAndLowercase())
            } catch { }
        }
    }

    /// Tests the retrieval of a patient by MedscopeID with an incorrect ID
    /// - Given: An invalid patient input
    /// - When: The patient is retrieved
    /// - Then: The retrieval fails with a bad request error
    /// - Note: The MedscopeID should be a valid UUID and the patient should exist in the database.
    func testGetByMedscopeIDWithIncorrectIDFails() async throws {
        let wrongPatientMedscopeID = "MEDP01"

        try await app.test(.GET, "\(baseURL)/medscopeID/\(wrongPatientMedscopeID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.medscopeIDBadlyFormatted"))
        }
    }

    /// Tests the retrieval of a patient by MedscopeID with an inexistant ID
    /// - Given: An invalid patient input
    /// - When: The patient is retrieved
    /// - Then: The retrieval fails with a not found error
    /// - Note: The MedscopeID should be a valid UUID and the patient should exist in the database.
    func testGetByMedscopeIDWithInexistantPatientFails() async throws {
        let patientMedscopeID = "MEDP0001"

        try await app.test(.GET, "\(baseURL)/medscopeID/\(patientMedscopeID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.patient"))
        }
    }
}
