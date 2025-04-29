//
//  TreatmentControllerTests+UPDATE.swift
//  Medscope
//
//  Created by Raphaël Payet on 24/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Update
extension TreatmentControllerTests {
    func testUpdateSucceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()
        
        let newAffectedBone = Treatment.AffectedBone.mandible
        let newDate = "2008-01-08T00:00:00.000Z"
        let updateInput = Treatment.UpdateInput(affectedBone: newAffectedBone, date: newDate, dicomID: documentID, model3Ds: [documentID])
        
        try await app.test(.PUT, "\(baseURL)/\(treatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let updatedTreatment = try res.content.decode(Treatment.self)
                XCTAssertEqual(updatedTreatment.affectedBone, newAffectedBone)
                XCTAssertEqual(updatedTreatment.date, newDate)
            } catch { }
        }
    }
    
    func testUpdateWithInexistantTreatmentFails() async throws {
        let newAffectedBone = Treatment.AffectedBone.mandible
        let newDate = "2008-01-08T00:00:00.000Z"
        let updateInput = Treatment.UpdateInput(affectedBone: newAffectedBone, date: newDate, dicomID: nil, model3Ds: nil)
        
        try await app.test(.PUT, "\(baseURL)/\(UUID())") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.treatment"))
        }
    }
    
    func testUpdateWithInvalidDateFormatFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        
        let incorrectDate = "incorrectDate"
        let updateInput = Treatment.UpdateInput(affectedBone: nil, date: incorrectDate, dicomID: nil, model3Ds: nil)
        
        try await app.test(.PUT, "\(baseURL)/\(treatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidDateFormat"))
            
        }
    }
    
    func testUpdateWithAlreadyExistingTreatmentFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        
        let newDate = expectedDate
        let updateInput = Treatment.UpdateInput(affectedBone: nil, date: newDate, dicomID: nil, model3Ds: nil)
        
        try await app.test(.PUT, "\(baseURL)/\(treatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .conflict)
            XCTAssertTrue(res.body.string.contains("conflict.treatmentAlreadyExists"))
        }
    }
    
    func testUpdateWithInexistantDocumentFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        
        let updateInput = Treatment.UpdateInput(affectedBone: nil, date: nil, dicomID: UUID(), model3Ds: nil)
        
        try await app.test(.PUT, "\(baseURL)/\(treatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.inexistantDocument"))
        }
    }
    
    func testUpdateWithTooMany3DModelsFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()
        
        let updateInput = Treatment.UpdateInput(affectedBone: nil, date: nil, dicomID: nil, model3Ds: [documentID, documentID, documentID, documentID])
        
        try await app.test(.PUT, "\(baseURL)/\(treatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.tooManyModel3Ds"))
        }
    }
    
    func testUpdateWithInexistantModel3DFails() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        
        let updateInput = Treatment.UpdateInput(affectedBone: nil, date: nil, dicomID: nil, model3Ds: [UUID()])
        
        try await app.test(.PUT, "\(baseURL)/\(treatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.inexistantModel3DDocument"))
        }
    }
}

