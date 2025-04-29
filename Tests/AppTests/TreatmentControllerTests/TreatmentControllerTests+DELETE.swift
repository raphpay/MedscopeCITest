//
//  TreatmentControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 24/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Delete All
extension TreatmentControllerTests {
    /// Tests the deletion of all treatments
    /// - Given: A valid request to delete all treatments
    /// - When: The user sends a DELETE request to the /api/treatments/all endpoint
    /// - Then: All treatments are deleted successfully and the response status is 204 No Content
    func testDeleteAllSucceed() async throws {
        let patient = try await Patient.create(name: expectedPatientName, firstName: expectedPatientFirstName, birthdate: expectedPatientBirthdate, gender: expectedPatientGender, userID: UUID(), medscopeID: expectedPatientMedscopeID, laGalaxyID: expectedPatientLaGalaxyID, on: app.db)
        let patientID = try patient.requireID()
        let _ = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)

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

    /// Tests the deletion of all treatments with an unauthorized user
    /// - Given: A valid request to delete all treatments with an unauthorized user
    /// - When: The user sends a DELETE request to the /api/treatments/all endpoint
    /// - Then: The request fails with a 401 Unauthorized status and an error message indicating the unauthorized role
    func testDeleteAllWithUnauthorizedUserFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .user, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)

        let patient = try await Patient.create(name: expectedPatientName, firstName: expectedPatientFirstName, birthdate: expectedPatientBirthdate, gender: expectedPatientGender, userID: UUID(), medscopeID: expectedPatientMedscopeID, laGalaxyID: expectedPatientLaGalaxyID, on: app.db)
        let patientID = try patient.requireID()
        let _ = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)

        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }
}

// MARK: - Delete
extension TreatmentControllerTests {
    /// Tests the deletion of a treatment
    /// - Given: A valid treatment ID
    /// - When: The user sends a DELETE request to the /api/treatments/{treatmentID} endpoint
    /// - Then: The treatment is deleted successfully and the response status is 204 No Content
    func testDeleteTreatmentSucceed() async throws {
        let patient = try await Patient.create(name: expectedPatientName, firstName: expectedPatientFirstName, birthdate: expectedPatientBirthdate, gender: expectedPatientGender, userID: UUID(), medscopeID: expectedPatientMedscopeID, laGalaxyID: expectedPatientLaGalaxyID, on: app.db)
        let patientID = try patient.requireID()
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()

        try await app.test(.DELETE, "\(baseURL)/\(treatmentID)", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .noContent)
        })
    }

    /// Tests the deletion of a treatment with an incorrect ID
    /// - Given: An incorrect treatment ID
    /// - When: The user sends a DELETE request to the /api/treatments/{treatmentID} endpoint
    /// - Then: The request fails with a 400 Bad Request status and an error message indicating the missing treatment ID
    func testDeleteWithIncorrectIDFails() async throws {
        try await app.test(.DELETE, "\(baseURL)/treatmentID") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingTreatmentID"))
        }
    }

    /// Tests the deletion of a treatment with an invalid ID
    /// - Given: An invalid treatment ID
    /// - When: The user sends a DELETE request to the /api/treatments/{treatmentID} endpoint
    /// - Then: The request fails with a 400 Bad Request status and an error message indicating the invalid treatment ID
    func testDeleteWithInexistantTreatmentFails() async throws {
        let falseTreatmentID = UUID()
        try await app.test(.DELETE, "\(baseURL)/\(falseTreatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.treatment"))
        }
    }

    /// Tests the deletion of a treatment with an unauthorized user
    /// - Given: A valid treatment ID with an unauthorized user
    /// - When: The user sends a DELETE request to the /api/treatments/{treatmentID} endpoint
    /// - Then: The request fails with a 401 Unauthorized status and an error message indicating the unauthorized role
    func testDeleteWithUnauthorizedUserFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .user, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)

        try await app.test(.DELETE, "\(baseURL)/treatmentID") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }
}
