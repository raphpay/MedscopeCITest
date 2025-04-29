//
//  SurgeryPlanControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 16/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Get all
extension SurgeryPlanControllerTests {
    /// Test the retrieval of all surgery plans
    /// - Given: a user with the correct role
    /// - When: sends a GET request to the endpoint
    /// - Then: all surgery plans are returned and the response status is 200 OK
    /// - Note: The test is performed in two cases:
    ///         1. When there is data in the database
    ///         2. When there is no data in the database
    func testGetAllWithDataSucceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()

        let implantsModels = UUID()
        let surgeryReport = [UUID()]
        let finalReport = UUID()
        let surgeryGuide = UUID()
        let imagesBoneStress = [UUID(), UUID()]
        let imagesImplantsStress = [UUID(), UUID()]
        let imagesDensity = [UUID(), UUID()]
        let resultsBoneStress = [UUID(), UUID()]
        let resultsImplantStress = [UUID(), UUID()]
        let resultsDensity = [UUID(), UUID()]
        let _ = try await SurgeryPlanControllerTests().createExpectedSurgeryPlan(with: treatmentID,
                                                                                 implantsReference: expectedImplantsReference,
                                                                                 implantsModels: implantsModels,
                                                                                 surgeryReport: surgeryReport,
                                                                                 imagesBoneStress: imagesBoneStress,
                                                                                 imagesImplantsStress: imagesImplantsStress,
                                                                                 imagesDensity: imagesDensity,
                                                                                 finalReport: finalReport,
                                                                                 surgeryGuide: surgeryGuide,
                                                                                 resultsBoneStress: resultsBoneStress,
                                                                                 resultsImplantStress: resultsImplantStress,
                                                                                 resultsDensity: resultsDensity,
                                                                                 on: app.db)


        try await app.test(.GET, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let surgeryPlans = try res.content.decode([SurgeryPlan].self)
                XCTAssertEqual(surgeryPlans.count, 1)
                XCTAssertEqual(surgeryPlans[0].naturalTeeth, expectedNaturalTeeth)
                XCTAssertEqual(surgeryPlans[0].artificialTeeth, expectedArtificialTeeth)
                XCTAssertEqual(surgeryPlans[0].position, expectedPosition)
                XCTAssertEqual(surgeryPlans[0].center, expectedCenter)
                XCTAssertEqual(surgeryPlans[0].apex, expectedApex)
                XCTAssertEqual(surgeryPlans[0].upIndex, expectedUpIndex)
                XCTAssertEqual(surgeryPlans[0].implantsReference, expectedImplantsReference)
                XCTAssertEqual(surgeryPlans[0].implantsModels, implantsModels )
                XCTAssertEqual(surgeryPlans[0].surgeryReport, surgeryReport)
                XCTAssertEqual(surgeryPlans[0].isTreated, expectedIsTreated)
                XCTAssertEqual(surgeryPlans[0].loadingProtocol, expectedLoadingProtocol)
                XCTAssertEqual(surgeryPlans[0].imagesBoneStress, imagesBoneStress)
               XCTAssertEqual(surgeryPlans[0].imagesImplantStress, imagesImplantsStress)
               XCTAssertEqual(surgeryPlans[0].imagesDensity, imagesDensity)
                XCTAssertEqual(surgeryPlans[0].finalReport, finalReport)
                XCTAssertEqual(surgeryPlans[0].surgeryGuide, surgeryGuide)
                XCTAssertEqual(surgeryPlans[0].resultsBoneStress, resultsBoneStress)
                XCTAssertEqual(surgeryPlans[0].resultsImplantStress, resultsImplantStress)
                XCTAssertEqual(surgeryPlans[0].resultsDensity, resultsDensity)
                XCTAssertEqual(surgeryPlans[0].$treatment.id, treatmentID)
            } catch {}
        }
    }

    /// Test the retrieval of all surgery plans
    /// - Given: a user with the correct role
    /// - When: sends a GET request to the endpoint
    /// - Then: all surgery plans are returned and the response status is 200 OK
    /// - Note: The test is performed in two cases:
    ///         1. When there is data in the database
    ///         2. When there is no data in the database
    func testGetAllWithoutDataSucceed() async throws {
        try await app.test(.GET, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let surgeryPlans = try res.content.decode([SurgeryPlan].self)
                XCTAssertEqual(surgeryPlans.count, 0)
            } catch {}
        }
    }
}

// MARK: - Get Surgery plan
extension SurgeryPlanControllerTests {
    /// Test the retrieval of a surgery plan
    /// - Given: a user with the correct role
    /// - When: sends a GET request to the endpoint
    /// - Then: the surgery plan is returned and the response status is 200 OK
    func test_getSurgeryPlan_Succeed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        let surgeryPlan = try await SurgeryPlanControllerTests().createExpectedSurgeryPlan(with: treatmentID, implantsReference: expectedImplantsReference, on: app.db)
        let surgeryPlanID = try surgeryPlan.requireID()

        try await app.test(.GET, "\(baseURL)/\(surgeryPlanID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            do {
				let plan = try res.content.decode(SurgeryPlan.Output.self)
                XCTAssertEqual(plan.medscopeID, surgeryPlan.medscopeID)
                XCTAssertEqual(plan.naturalTeeth.count, surgeryPlan.naturalTeeth.count)
                XCTAssertEqual(plan.artificialTeeth.count, surgeryPlan.artificialTeeth.count)
                XCTAssertEqual(plan.position.count, surgeryPlan.position.count)
                XCTAssertEqual(plan.center.count, surgeryPlan.center.count)
                XCTAssertEqual(plan.apex.count, surgeryPlan.apex.count)
                XCTAssertEqual(plan.upIndex.count, surgeryPlan.upIndex.count)
                XCTAssertEqual(plan.implantsReference.count, surgeryPlan.implantsReference.count)
                XCTAssertEqual(plan.surgeryReport.count, surgeryPlan.surgeryReport.count)
                XCTAssertEqual(plan.implantsModels, surgeryPlan.implantsModels)
                XCTAssertEqual(plan.loadingProtocol, surgeryPlan.loadingProtocol)
                XCTAssertEqual(plan.imagesBoneStress?.count, surgeryPlan.imagesBoneStress?.count)
                XCTAssertEqual(plan.imagesImplantStress?.count, surgeryPlan.imagesImplantStress?.count)
                XCTAssertEqual(plan.imagesDensity?.count, surgeryPlan.imagesDensity?.count)
                XCTAssertEqual(plan.finalReport, surgeryPlan.finalReport)
                XCTAssertEqual(plan.surgeryGuide, surgeryPlan.surgeryGuide)
                XCTAssertEqual(plan.resultsBoneStress?.count, surgeryPlan.resultsBoneStress?.count)
                XCTAssertEqual(plan.resultsImplantStress?.count, surgeryPlan.resultsImplantStress?.count)
                XCTAssertEqual(plan.resultsDensity?.count, surgeryPlan.resultsDensity?.count)
                XCTAssertEqual(plan.otherResults, surgeryPlan.otherResults)
				XCTAssertEqual(plan.treatmentID, surgeryPlan.$treatment.id)
            }
        }
    }

    /// Test the retrieval of a surgery plan with an incorrect ID
    /// - Given: a user with the correct role
    /// - When: sends a GET request to the endpoint with an incorrect ID
    /// - Then: the response status is 404 Not Found
    func test_getSurgeryPlan_WithIncorrectID_ReturnsNotFound() async throws {
        let falseID = UUID()
        try await app.test(.GET, "\(baseURL)/\(falseID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.surgeryPlan"))
        }
    }
}

// MARK: - Get Implants
extension SurgeryPlanControllerTests {
    // TODO: Correct AppTests/Application+Ext.swift:65: Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional valu
    /// Test the retrieval of implants
    /// - Given: a user with the correct role
    /// - When: sends a GET request to the endpoint
    /// - Then: the implants are returned and the response status is 200 OK
    /// Note: The test is performed in two cases:
    ///         1. When there is data in the database
    ///         2. When there is no data in the database
    func testGetImplantsWithDataSucceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        let surgeryPlan = try await SurgeryPlanControllerTests().createExpectedSurgeryPlan(with: treatmentID, implantsReference: expectedImplantsReference, on: app.db)
        let surgeryPlanID = try surgeryPlan.requireID()
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let _ = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        try await app.test(.GET, "\(baseURL)/\(surgeryPlanID)/implants") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let implants = try res.content.decode([Implant].self)
                XCTAssertEqual(implants.count, 1)
                XCTAssertEqual(implants[0].modelID, documentID)
            } catch { }
        }

    }

    /// Test the retrieval of implants
    /// - Given: a user with the correct role
    /// - When: sends a GET request to the endpoint
    /// - Then: the implants are returned and the response status is 200 OK
    /// Note: The test is performed in two cases:
    ///         1. When there is data in the database
    ///         2. When there is no data in the database
    func testGetImplantsWithoutDataSucceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        let surgeryPlan = try await SurgeryPlanControllerTests().createExpectedSurgeryPlan(with: treatmentID, on: app.db)
        let surgeryPlanID = try surgeryPlan.requireID()

        try await app.test(.GET, "\(baseURL)/\(surgeryPlanID)/implants") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let implants = try res.content.decode([Implant].self)
                XCTAssertEqual(implants.count, 0)
            } catch {}
        }
    }
}
