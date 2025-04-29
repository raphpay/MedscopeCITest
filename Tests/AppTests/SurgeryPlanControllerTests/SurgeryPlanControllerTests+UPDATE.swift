//
//  SurgeryPlanControllerTests+UPDATE.swift
//
//
//  Created by Raphaël Payet on 25/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Update
extension SurgeryPlanControllerTests {
    /// Test the update of a surgery plan
    /// - Given: A surgery plan with a treatment
    /// - When: sends a PUT request to the endpoint
    /// - Then: The surgery plan is updated with the new values
    func testUpdateSucceed() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        let updateInput = SurgeryPlan.UpdateInput(naturalTeeth: expectedUpdatedNaturalTeeth,
                                                  artificialTeeth: expectedUpdatedArtificialTeeth,
                                                  position: expectedUpdatedPosition,
                                                  center: expectedUpdatedCenter,
                                                  apex: expectedUpdatedApex,
                                                  upIndex: expectedUpdatedUpIndex,
                                                  implantsReference: [implant.reference],
                                                  surgeryReport: [documentID],
                                                  depth: expectedDepth,
                                                  implantsModels: documentID,
                                                  loadingProtocol: expectedUpdatedLoadingProtocol,
                                                  imagesBoneStress: [documentID],
                                                  imagesImplantStress: [documentID],
                                                  imagesDensity: [documentID],
                                                  finalReport: documentID,
                                                  surgeryGuide: documentID,
                                                  resultsBoneStress: [documentID],
                                                  resultsImplantStress: [documentID],
                                                  resultsDensity: [documentID],
                                                  otherResults: documentID)

        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        let surgeryPlan = try await SurgeryPlanControllerTests().createExpectedSurgeryPlan(with: treatmentID, implantsReference: expectedImplantsReference, on: app.db)
        let surgeryPlanID = try surgeryPlan.requireID()

        try await app.test(.PUT, "\(baseURL)/\(surgeryPlanID)") { req in
            try req.content.encode(updateInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let updatedSurgeryPlan = try res.content.decode(SurgeryPlan.self)
                // Check Updated values
                XCTAssertEqual(updatedSurgeryPlan.naturalTeeth, expectedUpdatedNaturalTeeth)
                XCTAssertEqual(updatedSurgeryPlan.artificialTeeth, expectedUpdatedArtificialTeeth)
                XCTAssertEqual(updatedSurgeryPlan.position, expectedUpdatedPosition)
                XCTAssertEqual(updatedSurgeryPlan.center, expectedUpdatedCenter)
                XCTAssertEqual(updatedSurgeryPlan.apex, expectedUpdatedApex)
                XCTAssertEqual(updatedSurgeryPlan.upIndex, expectedUpdatedUpIndex)
                XCTAssertEqual(updatedSurgeryPlan.implantsReference.count, [implant.reference].count)
                XCTAssertEqual(updatedSurgeryPlan.surgeryReport, [documentID])
                XCTAssertEqual(updatedSurgeryPlan.implantsModels, documentID)
                XCTAssertEqual(updatedSurgeryPlan.loadingProtocol, expectedUpdatedLoadingProtocol)
                XCTAssertEqual(updatedSurgeryPlan.imagesBoneStress, [documentID])
                XCTAssertEqual(updatedSurgeryPlan.imagesImplantStress, [documentID])
                XCTAssertEqual(updatedSurgeryPlan.imagesDensity, [documentID])
                XCTAssertEqual(updatedSurgeryPlan.finalReport, documentID)
                XCTAssertEqual(updatedSurgeryPlan.surgeryGuide, documentID)
                XCTAssertEqual(updatedSurgeryPlan.resultsBoneStress, [documentID])
                XCTAssertEqual(updatedSurgeryPlan.resultsImplantStress, [documentID])
                XCTAssertEqual(updatedSurgeryPlan.resultsDensity, [documentID])
                XCTAssertEqual(updatedSurgeryPlan.otherResults, documentID)
            } catch { }
        }
    }

    /// Test the update of a surgery plan
    /// - Given: A surgery plan with a treatment
    /// - When: sends a PUT request to the endpoint
    /// - Then: The request fails with a 400 error
    func testUpdateWithInexistantSurgeryPlanFails() async throws {
        let falseSurgeryPlanID = UUID()
        try await app.test(.PUT, "\(baseURL)/\(falseSurgeryPlanID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.surgeryPlan"))
        }
    }

    func testUpdateWithTooMuchImplantsFails() async throws {
        let updateInput = SurgeryPlan.UpdateInput(naturalTeeth: nil,
                                                  artificialTeeth: expectedUpdatedArtificialTeeth,
                                                  position: nil,
                                                  center: nil,
                                                  apex: nil,
                                                  upIndex: nil,
                                                  implantsReference: incorrectImplantReferences,
                                                  surgeryReport: nil,
                                                  depth: nil,
                                                  implantsModels: nil,
                                                  loadingProtocol: nil,
                                                  imagesBoneStress: nil,
                                                  imagesImplantStress: nil,
                                                  imagesDensity: nil,
                                                  finalReport: nil,
                                                  surgeryGuide: nil,
                                                  resultsBoneStress: nil,
                                                  resultsImplantStress: nil,
                                                  resultsDensity: nil,
                                                  otherResults: nil)

        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        let surgeryPlan = try await SurgeryPlanControllerTests().createExpectedSurgeryPlan(with: treatmentID, on: app.db)
        let surgeryPlanID = try surgeryPlan.requireID()

        try await app.test(.PUT, "\(baseURL)/\(surgeryPlanID)") { req in
            try req.content.encode(updateInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.tooManyImplants"))
        }
    }
}
