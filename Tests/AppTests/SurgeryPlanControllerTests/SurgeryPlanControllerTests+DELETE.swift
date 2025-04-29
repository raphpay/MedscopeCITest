//
//  SurgeryPlanControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Delete All
extension SurgeryPlanControllerTests {
    /// Test the deletion of all surgery plans
    /// - Given: a user with the correct role
    /// - When: sends a DELETE request to the endpoint
    /// - Then: all surgery plans are deleted and the response status is 204 No Content
    /// - Note: The test is performed in two cases:
    ///         1. When there is data in the database
    ///         2. When there is no data in the database
    func testDeleteAllWithDataSucceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

		let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()

        let _ = try await SurgeryPlanControllerTests().createExpectedSurgeryPlan(with: treatmentID, on: app.db)

        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)

            do {
                let surgeryPlans = try await SurgeryPlan.query(on: app.db).all()
                XCTAssertEqual(surgeryPlans.count, 0)
            } catch { }
        }
    }

    /// Test the deletion of all surgery plans
    /// - Given: a user with the correct role
    /// - When: sends a DELETE request to the endpoint
    /// - Then: all surgery plans are deleted and the response status is 204 No Content
    /// - Note: The test is performed in two cases:
    ///         1. When there is data in the database
    ///         2. When there is no data in the database
    func testDeleteAllWithoutDataSucceed() async throws {
        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)

            do {
                let surgeryPlans = try await SurgeryPlan.query(on: app.db).all()
                XCTAssertEqual(surgeryPlans.count, 0)
            } catch { }
        }
    }

    /// Test the deletion of all surgery plans with an unauthorized user
    /// - Given: a user with the incorrect role
    /// - When: sends a DELETE request to the endpoint
    /// - Then: the response status is 401 Unauthorized
    func testDeleteAllWithUnauthorizedUserFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .user, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)

        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }
}

// MARK: - Delete
extension SurgeryPlanControllerTests {
    /// Test the deletion of a surgery plan
    /// - Given: a user with the correct role
    /// - When: sends a DELETE request to the endpoint
    /// - Then: the surgery plan is deleted and the response status is 204 No Content
    func testDeleteSucceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()

        let surgeryPlan = try await SurgeryPlanControllerTests().createExpectedSurgeryPlan(with: treatmentID, on: app.db)
        let surgeryPlanID = try surgeryPlan.requireID()

        try await app.test(.DELETE, "\(baseURL)/\(surgeryPlanID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)

            do {
                let surgeryPlans = try await SurgeryPlan.query(on: app.db).all()
                XCTAssertEqual(surgeryPlans.count, 0)
            } catch { }
        }
    }

    /// Test the deletion of a surgery plan with an unauthorized user
    /// - Given: a user with the incorrect role
    /// - When: sends a DELETE request to the endpoint
    /// - Then: the response status is 401 Unauthorized
    func testDeleteWithIncorrectRoleFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .user, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)

        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()

        let surgeryPlan = try await SurgeryPlanControllerTests().createExpectedSurgeryPlan(with: treatmentID, on: app.db)
        let surgeryPlanID = try surgeryPlan.requireID()

        try await app.test(.DELETE, "\(baseURL)/\(surgeryPlanID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }
}
