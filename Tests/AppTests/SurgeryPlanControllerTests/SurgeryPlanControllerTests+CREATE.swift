//
//  SurgeryPlanControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 15/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Create
extension SurgeryPlanControllerTests {
    /// Test the creation of a SurgeryPlan
    /// - Given: a valid SurgeryPlan input
    /// - When: a POST request is made to the SurgeryPlan endpoint
    /// - Then: the SurgeryPlan is created successfully
    func testCreateSucceed() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()

        let implant = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        let surgeryPlanInput = SurgeryPlan.Input(naturalTeeth: expectedNaturalTeeth,
                                                 artificialTeeth: expectedArtificialTeeth,
                                                 position: expectedPosition,
                                                 center: expectedCenter,
                                                 apex: expectedApex,
                                                 upIndex: expectedUpIndex,
                                                 implantsReference: [implant.reference],
                                                 surgeryReport: [documentID],
                                                 isTreated: expectedIsTreated,
                                                 depth: expectedDepth,
                                                 implantsModels: documentID,
                                                 loadingProtocol: expectedLoadingProtocol,
                                                 imagesBoneStress: expectedImagesBoneStress,
                                                 imagesImplantStress: [documentID],
                                                 imagesDensity: [documentID],
                                                 finalReport: documentID,
                                                 surgeryGuide: documentID,
                                                 resultsBoneStress: [documentID],
                                                 resultsImplantStress: [documentID],
                                                 resultsDensity: [documentID],
                                                 otherResults: documentID,
                                                 treatmentID: treatmentID)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(surgeryPlanInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let surgeryPlan = try res.content.decode(SurgeryPlan.self)
                XCTAssertEqual(surgeryPlan.naturalTeeth, surgeryPlanInput.naturalTeeth)
                XCTAssertEqual(surgeryPlan.artificialTeeth, surgeryPlanInput.artificialTeeth)
                XCTAssertEqual(surgeryPlan.position, surgeryPlanInput.position)
                XCTAssertEqual(surgeryPlan.center, surgeryPlanInput.center)
                XCTAssertEqual(surgeryPlan.apex, surgeryPlanInput.apex)
                XCTAssertEqual(surgeryPlan.upIndex, surgeryPlanInput.upIndex)
                XCTAssertEqual(surgeryPlan.implantsReference.count, surgeryPlanInput.implantsReference.count)
                XCTAssertEqual(surgeryPlan.surgeryReport.count, surgeryPlanInput.surgeryReport.count)
                XCTAssertEqual(surgeryPlan.isTreated, surgeryPlanInput.isTreated)
                XCTAssertEqual(surgeryPlan.implantsModels, documentID)
                XCTAssertEqual(surgeryPlan.loadingProtocol, surgeryPlanInput.loadingProtocol)
                XCTAssertEqual(surgeryPlan.imagesBoneStress?.count, surgeryPlanInput.imagesBoneStress?.count)
                XCTAssertEqual(surgeryPlan.imagesImplantStress?.count, surgeryPlanInput.imagesImplantStress?.count)
                XCTAssertEqual(surgeryPlan.imagesDensity?.count, surgeryPlanInput.imagesDensity?.count)
                XCTAssertEqual(surgeryPlan.finalReport, surgeryPlanInput.finalReport)
                XCTAssertEqual(surgeryPlan.surgeryGuide, surgeryPlanInput.surgeryGuide)
                XCTAssertEqual(surgeryPlan.resultsBoneStress?.count, surgeryPlanInput.resultsBoneStress?.count)
                XCTAssertEqual(surgeryPlan.resultsImplantStress?.count, surgeryPlanInput.resultsImplantStress?.count)
                XCTAssertEqual(surgeryPlan.resultsDensity?.count, surgeryPlanInput.resultsDensity?.count)
                XCTAssertEqual(surgeryPlan.otherResults, surgeryPlanInput.otherResults)
            } catch { }
        }
    }

    /// Test the creation of a SurgeryPlan with a wrong number of natural teeth
    /// - Given: a SurgeryPlan input with a wrong number of natural teeth
    /// - When: a POST request is made to the SurgeryPlan endpoint
    /// - Then: the request fails with a 400 status code
    func testCreateWithWrongNaturalTeethNumberFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let surgeryPlanInput = SurgeryPlan.Input(naturalTeeth: wrongNaturalTeeth,
                                                 artificialTeeth: expectedArtificialTeeth,
                                                 position: expectedPosition,
                                                 center: expectedCenter,
                                                 apex: expectedApex,
                                                 upIndex: expectedUpIndex,
                                                 implantsReference: expectedImplantsReference,
                                                 surgeryReport: [documentID],
                                                 isTreated: expectedIsTreated,
                                                 depth: expectedDepth,
                                                 implantsModels: documentID,
                                                 loadingProtocol: expectedLoadingProtocol,
                                                 imagesBoneStress: expectedImagesBoneStress,
                                                 imagesImplantStress: expectedImagesImplantStress,
                                                 imagesDensity: expectedImagesDensity,
                                                 finalReport: UUID(),
                                                 surgeryGuide: UUID(),
                                                 resultsBoneStress: [documentID],
                                                 resultsImplantStress: [documentID],
                                                 resultsDensity: [documentID],
                                                 otherResults: documentID,
                                                 treatmentID: treatmentID)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(surgeryPlanInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.naturalTeethArrayMaxCount"))
        }
    }

    /// Test the creation of a SurgeryPlan with a wrong number of artificial teeth
    /// - Given: a SurgeryPlan input with a wrong number of artificial teeth
    /// - When: a POST request is made to the SurgeryPlan endpoint
    /// - Then: the request fails with a 400 status code
    func testCreateWithInexistantTreatmentFails() async throws {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let surgeryPlanInput = SurgeryPlan.Input(naturalTeeth: expectedNaturalTeeth,
                                                 artificialTeeth: expectedArtificialTeeth,
                                                 position: expectedPosition,
                                                 center: expectedCenter,
                                                 apex: expectedApex,
                                                 upIndex: expectedUpIndex,
                                                 implantsReference: expectedImplantsReference,
                                                 surgeryReport: [documentID],
                                                 isTreated: expectedIsTreated,
                                                 depth: expectedDepth,
                                                 implantsModels: documentID,
                                                 loadingProtocol: expectedLoadingProtocol,
                                                 imagesBoneStress: expectedImagesBoneStress,
                                                 imagesImplantStress: expectedImagesImplantStress,
                                                 imagesDensity: expectedImagesDensity,
                                                 finalReport: UUID(),
                                                 surgeryGuide: UUID(),
                                                 resultsBoneStress: [documentID],
                                                 resultsImplantStress: [documentID],
                                                 resultsDensity: [documentID],
                                                 otherResults: documentID,
                                                 treatmentID: UUID())

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(surgeryPlanInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.treatment"))
        }
    }

    /// Test the creation of a SurgeryPlan with too many implants
    /// - Given: a SurgeryPlan input with too many implants
    /// - When: a POST request is made to the SurgeryPlan endpoint
    /// - Then: the request fails with a 400 status code
    func testCreateWithTooManyImplantsFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let surgeryPlanInput = SurgeryPlan.Input(naturalTeeth: expectedNaturalTeeth,
                                                 artificialTeeth: expectedArtificialTeeth,
                                                 position: expectedPosition,
                                                 center: expectedCenter,
                                                 apex: expectedApex,
                                                 upIndex: expectedUpIndex,
                                                 implantsReference: incorrectImplantReferences,
                                                 surgeryReport: [documentID],
                                                 isTreated: expectedIsTreated,
                                                 depth: expectedDepth,
                                                 implantsModels: documentID,
                                                 loadingProtocol: expectedLoadingProtocol,
                                                 imagesBoneStress: expectedImagesBoneStress,
                                                 imagesImplantStress: expectedImagesImplantStress,
                                                 imagesDensity: expectedImagesDensity,
                                                 finalReport: UUID(),
                                                 surgeryGuide: UUID(),
                                                 resultsBoneStress: [documentID],
                                                 resultsImplantStress: [documentID],
                                                 resultsDensity: [documentID],
                                                 otherResults: documentID,
                                                 treatmentID: treatmentID)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(surgeryPlanInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.tooManyImplants"))
        }
    }

    /// Test the creation of a SurgeryPlan with inexistant implants models
    /// - Given: a SurgeryPlan input with inexistant implants models
    /// - When: a POST request is made to the SurgeryPlan endpoint
    /// - Then: the request fails with a 404 status code
    func testCreateWithInexistantImplantsModelsFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let _ = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        let surgeryPlanInput = SurgeryPlan.Input(naturalTeeth: expectedNaturalTeeth,
                                                 artificialTeeth: expectedArtificialTeeth,
                                                 position: expectedPosition,
                                                 center: expectedCenter,
                                                 apex: expectedApex,
                                                 upIndex: expectedUpIndex,
                                                 implantsReference: expectedImplantsReference,
                                                 surgeryReport: [documentID, documentID],
                                                 isTreated: expectedIsTreated,
                                                 depth: expectedDepth,
                                                 implantsModels: UUID(),
                                                 loadingProtocol: expectedLoadingProtocol,
                                                 imagesBoneStress: expectedImagesBoneStress,
                                                 imagesImplantStress: expectedImagesImplantStress,
                                                 imagesDensity: expectedImagesDensity,
                                                 finalReport: UUID(),
                                                 surgeryGuide: UUID(),
                                                 resultsBoneStress: [documentID],
                                                 resultsImplantStress: [documentID],
                                                 resultsDensity: [documentID],
                                                 otherResults: documentID,
                                                 treatmentID: treatmentID)


        try await app.test(.POST, baseURL) { req in
            try req.content.encode(surgeryPlanInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.implantsModelsDocument"))
        }
    }

    /// Test the creation of a SurgeryPlan with inexistant surgery report
    /// - Given: a SurgeryPlan input with inexistant surgery report
    /// - When: a POST request is made to the SurgeryPlan endpoint
    /// - Then: the request fails with a 404 status code
    func testCreateWithInexistantSurgeryReportFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let _ = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        let surgeryPlanInput = SurgeryPlan.Input(naturalTeeth: expectedNaturalTeeth,
                                                 artificialTeeth: expectedArtificialTeeth,
                                                 position: expectedPosition,
                                                 center: expectedCenter,
                                                 apex: expectedApex,
                                                 upIndex: expectedUpIndex,
                                                 implantsReference: expectedImplantsReference,
                                                 surgeryReport: [UUID()],
                                                 isTreated: expectedIsTreated,
                                                 depth: expectedDepth,
                                                 implantsModels: documentID,
                                                 loadingProtocol: expectedLoadingProtocol,
                                                 imagesBoneStress: expectedImagesBoneStress,
                                                 imagesImplantStress: expectedImagesImplantStress,
                                                 imagesDensity: expectedImagesDensity,
                                                 finalReport: UUID(),
                                                 surgeryGuide: UUID(),
                                                 resultsBoneStress: [documentID],
                                                 resultsImplantStress: [documentID],
                                                 resultsDensity: [documentID],
                                                 otherResults: documentID,
                                                 treatmentID: treatmentID)


        try await app.test(.POST, baseURL) { req in
            try req.content.encode(surgeryPlanInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.surgeryReport"))
        }
    }

    /// Test the creation of a SurgeryPlan with too many report documents
    /// - Given: a SurgeryPlan input with too many report documents
    /// - When: a POST request is made to the SurgeryPlan endpoint
    /// - Then: the request fails with a 400 status code
    func testCreateWithTooManyReportDocumentsFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()

        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let _ = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        let surgeryPlanInput = SurgeryPlan.Input(naturalTeeth: expectedNaturalTeeth,
                                                 artificialTeeth: expectedArtificialTeeth,
                                                 position: expectedPosition,
                                                 center: expectedCenter,
                                                 apex: expectedApex,
                                                 upIndex: expectedUpIndex,
                                                 implantsReference: expectedImplantsReference,
                                                 surgeryReport: [documentID, documentID, documentID],
                                                 isTreated: expectedIsTreated,
                                                 depth: expectedDepth,
                                                 implantsModels: documentID,
                                                 loadingProtocol: expectedLoadingProtocol,
                                                 imagesBoneStress: expectedImagesBoneStress,
                                                 imagesImplantStress: expectedImagesImplantStress,
                                                 imagesDensity: expectedImagesDensity,
                                                 finalReport: UUID(),
                                                 surgeryGuide: UUID(),
                                                 resultsBoneStress: [documentID],
                                                 resultsImplantStress: [documentID],
                                                 resultsDensity: [documentID],
                                                 otherResults: documentID,
                                                 treatmentID: treatmentID)


        try await app.test(.POST, baseURL) { req in
            try req.content.encode(surgeryPlanInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.tooManyReportDocuments"))
        }
    }
}
