//
//  TreatmentControllerTests+CREATE.swift
//  Medscope
//
//  Created by Raphaël Payet on 24/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Create
extension TreatmentControllerTests {
    /// Tests the creation of a treatment
    /// - Given: A valid treatment input
    /// - When: The user sends a POST request to the /api/treatments endpoint
    /// - Then: The treatment is created successfully and the response contains the created treatment
    func testCreateSucceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()
        let input = Treatment.Input(affectedBone: expectedAffectedBone, date: expectedDate , patientID: patientID, dicomID: documentID, model3Ds: [documentID])

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)

            do {
                let treatment = try res.content.decode(Treatment.self)
                XCTAssertEqual(treatment.affectedBone, expectedAffectedBone)
                XCTAssertEqual(treatment.date, expectedDate)
                XCTAssertEqual(treatment.$patient.id, patientID)
            } catch { }
        }
    }

    /// Tests the creation of a treatment with an invalid date format
    /// - Given: A valid treatment input with an invalid date format
    /// - When: The user sends a POST request to the /api/treatments endpoint
    /// - Then: The request fails with a 400 Bad Request status and an error message indicating the invalid date format
    /// - Note: The date format should be in ISO8601 format (e.g. "2007-01-08T00:00:00.000Z")
    func testCreateWithInvalidDateFormatFails() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()
        let input = Treatment.Input(affectedBone: expectedAffectedBone, date: invalidDate , patientID: expectedPatientID, dicomID: documentID, model3Ds: [documentID])

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidDateFormat"))
        }
    }

    /// Tests the creation of a treatment with an invalid patient ID
    /// - Given: A valid treatment input with an invalid patient ID
    /// - When: The user sends a POST request to the /api/treatments endpoint
    /// - Then: The request fails with a 400 Bad Request status and an error message indicating the invalid patient ID
    /// - Note: The patient ID should be a valid UUID
    func testCreateWithAlreadyExistingTreatmentFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let _ = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let input = Treatment.Input(affectedBone: expectedAffectedBone, date: expectedDate , patientID: patientID, dicomID: documentID, model3Ds: [documentID])

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .conflict)
            XCTAssertTrue(res.body.string.contains("conflict.treatmentAlreadyExists"))
        }
    }

    /// Tests the creation of a treatment with an invalid DICOM document ID
    /// - Given: A valid treatment input with an invalid DICOM document ID
    /// - When: The user sends a POST request to the /api/treatments endpoint
    /// - Then: The request fails with a 400 Bad Request status and an error message indicating the invalid DICOM document ID
    /// - Note: The DICOM document ID should be a valid UUID
    func testCreateWithInexistantDicomFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()
        let input = Treatment.Input(affectedBone: expectedAffectedBone, date: expectedDate , patientID: patientID, dicomID: UUID(), model3Ds: [documentID])

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.inexistantDicomDocument"))
        }
    }

    /// Tests the creation of a treatment with an invalid model 3D document ID
    /// - Given: A valid treatment input with an invalid model 3D document ID
    /// - When: The user sends a POST request to the /api/treatments endpoint
    /// - Then: The request fails with a 400 Bad Request status and an error message indicating the invalid model 3D document ID
    /// - Note: The model 3D document ID should be a valid UUID
    func testCreateWithInexistantModel3DFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()
        let input = Treatment.Input(affectedBone: expectedAffectedBone, date: expectedDate , patientID: patientID, dicomID: documentID, model3Ds: [UUID()])

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.inexistantModel3DDocument"))
        }
    }
}

