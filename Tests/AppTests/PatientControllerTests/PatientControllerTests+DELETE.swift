//
//  PatientControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 24/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Delete
extension PatientControllerTests {
    /// Tests the deletion of a patient
    /// - Given: A valid patient
    /// - When: The patient is deleted
    /// - Then: The patient is deleted
    /// Note: The user should be an admin.
    func testDeleteSucceed() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        try await app.test(.DELETE, "\(baseURL)/\(patientID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            do {
                let treatments = try await Treatment.query(on: app.db).all()
                XCTAssertEqual(treatments.count, 0)
            } catch { }
        }
    }

    /// Tests the deletion of a patient with an inexistant patient
    /// - Given: An invalid patient UUID
    /// - When: The patient is deleted
    /// - Then: The deletion fails with a not found error
    /// Note: The user should be an admin.
    func testDeleteInexistantPatientFails() async throws {
        let falsePatientID = UUID()

        try await app.test(.DELETE, "\(baseURL)/\(falsePatientID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.patient"))
        }
    }

    /// Tests the deletion of a patient with an unauthorized user
    /// - Given: A valid patient, and an unauthorized user
    /// - When: The patient is deleted
    /// - Then: The deletion fails with an unauthorized error
    /// Note: The user should be an admin
    func testDeleteWithUnauthorizedUserFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .companyOperator, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)
        let userID = try unauthorizedUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let patientID = try patient.requireID()

        try await app.test(.DELETE, "\(baseURL)/\(patientID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }
}

// MARK: - Delete All
extension PatientControllerTests {
    /// Tests the deletion of all
    /// - Given: A valid patient
    /// - When: The patient are deleted
    /// - Then: The patient are deleted
    func testDeleteAllSucceed() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let _ = try patient.requireID()

        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            do {
                let treatments = try await Treatment.query(on: app.db).all()
                XCTAssertEqual(treatments.count, 0)
            } catch { }
        }
    }

    /// Tests the deletion of all with an unauthorized user
    /// - Given: A valid patient, and an unauthorized user
    /// - When: The patient are deleted
    /// - Then: The deletion fails with an unauthorized error
    /// - Note: The user should be an admin
    func testDeleteAllWithUnauthorizedUserFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .companyOperator, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)
        let userID = try unauthorizedUser.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, on: app.db)
        let _ = try patient.requireID()

        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }
}
