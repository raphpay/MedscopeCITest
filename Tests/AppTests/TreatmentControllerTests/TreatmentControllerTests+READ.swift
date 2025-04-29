//
//  TreatmentControllerTests+READ.swift
//  
//
//  Created by Raphaël Payet on 24/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Get All
extension TreatmentControllerTests {
    func testGetAllWithDataSuceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        
        let _ = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        
        try await app.test(.GET, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let treatments = try res.content.decode([Treatment].self)
                XCTAssertEqual(treatments.count, 1)
                XCTAssertEqual(treatments[0].affectedBone, expectedAffectedBone)
                XCTAssertEqual(treatments[0].date, expectedDate)
                XCTAssertEqual(treatments[0].$patient.id, patientID)
            } catch { }
        }
    }
    
    func testGetAllWithoutDataSucceed() async throws {
        try await app.test(.GET, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let treatments = try res.content.decode([Treatment].self)
                XCTAssertEqual(treatments.count, 0)
            } catch { }
        }
    }
}


// TODO: Test get Dicom method when download is resolved on DocumentController Tests

// MARK: - Get Dicom Download Token
extension TreatmentControllerTests {
    func testGetDownloadTokenForDicomSucceed() async throws {
        let fileContent = try JSONSerialization.data(withJSONObject: DocumentControllerTests().expectedJsonObject, options: .prettyPrinted)
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()
        let filePath = app.directory.resourcesDirectory + "Uploads/" + DocumentControllerTests().expectedFilePath
        try DocumentControllerTests().createExpectedFile(with: fileContent, at: filePath)
        
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, and: documentID, on: app.db)
        let treatmentID = try treatment.requireID()
        
        try await app.test(.GET, "\(baseURL)/download/token/for/dicom/\(treatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let downloadToken = try res.content.decode(String.self)
                XCTAssertNotNil(downloadToken)
            } catch { }
        }
    }
}

// MARK: - Download Dicom
extension TreatmentControllerTests {
//	To be run alone
//    func testDownloadDicomSucceed() async throws {
//        let fileContent = try JSONSerialization.data(withJSONObject: DocumentControllerTests().expectedJsonObject, options: .prettyPrinted)
//        let filePath = app.directory.resourcesDirectory + "Uploads/" + DocumentControllerTests().expectedFilePath
//        try DocumentControllerTests().createExpectedFile(with: fileContent, at: filePath)
//        
//        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
//        let documentID = try document.requireID()
//        
//        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
//        let patientID = try patient.requireID()
//        let _ = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, and: documentID, on: app.db)
//        
//        let fileDirectory = DocumentControllerTests().expectedFilePath + DocumentControllerTests().expectedFileName
//        let fileDownload = try await FileDownloadControllerTests().create(at: fileDirectory, on: app.db)
//        let downloadToken = fileDownload.downloadToken
//        
//        try await app.test(.GET, "\(baseURL)/download/dicom/\(downloadToken)") { req in
//            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
//        } afterResponse: { res async in
//            XCTAssertEqual(res.status, .ok)
//            XCTAssertEqual(res.headers.first(name: .contentType), "application/json")
//            XCTAssertEqual(res.headers.first(name: .contentDisposition), "attachment; fileName=\(filePath + DocumentControllerTests().expectedFileName)")
//        }
//    }
}

// MARK: - Get Patient
extension TreatmentControllerTests {
    func testGetPatientSucceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        
        try await app.test(.GET, "\(baseURL)/patient/\(treatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let patient = try res.content.decode(Patient.self)
                XCTAssertEqual(patient.name, expectedPatientName.trimAndLowercase())
                XCTAssertEqual(patient.firstName, expectedPatientFirstName.trimAndLowercase())
                XCTAssertEqual(patient.birthdate, expectedPatientBirthdate)
                XCTAssertEqual(patient.gender, expectedPatientGender)
            } catch { }
        }
    }
    
    func testGetPatientWithIncorrectTreatmentIDFails() async throws {
        try await app.test(.GET, "\(baseURL)/patient/treatmentID") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingTreatmentID"))
        }
    }
    
    func testGetPatientWithInexistantTreatmentFails() async throws {
        let falseTreatmentID = UUID()
        try await app.test(.GET, "\(baseURL)/patient/\(falseTreatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.treatment"))
        }
    }
}

// MARK: - Get Surgery Plans
extension TreatmentControllerTests {
    func testGetSurgeryPlansWithDataSucceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        let _ = try await SurgeryPlanControllerTests().createExpectedSurgeryPlan(with: treatmentID, on: app.db)
        
        try await app.test(.GET, "\(baseURL)/surgeryPlans/\(treatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let surgeryPlans = try res.content.decode([SurgeryPlan].self)
                XCTAssertEqual(surgeryPlans.count, 1)
                XCTAssertEqual(surgeryPlans[0].$treatment.id, treatmentID)
            } catch { }
        }
    }
    
    func testGetSurgeryPlansWithoutDataSucceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        
        try await app.test(.GET, "\(baseURL)/surgeryPlans/\(treatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let surgeryPlans = try res.content.decode([SurgeryPlan].self)
                XCTAssertEqual(surgeryPlans.count, 0)
            } catch { }
        }
    }
    
    func testGetSurgeryPlansWithIncorrectTreatmentIDFails() async throws {
        try await app.test(.GET, "\(baseURL)/surgeryPlans/12345") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingTreatmentID"))
        }
    }
    
    func testGetTreatmentWithInexistantTreatmentFails() async throws {
        let falseTreatmentID = UUID()
        try await app.test(.GET, "\(baseURL)/surgeryPlans/\(falseTreatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.treatment"))
        }
    }
}

// MARK: - Get By ID
extension TreatmentControllerTests {
    func testGetByIDSucceed() async throws {
        let patient = try await PatientControllerTests().createExpectedPatient(on: app.db)
        let patientID = try patient.requireID()
        let treatment = try await TreatmentControllerTests().createExpectedTreatment(with: patientID, on: app.db)
        let treatmentID = try treatment.requireID()
        
        try await app.test(.GET, "\(baseURL)/\(treatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let treatmentFound = try res.content.decode(Treatment.self)
                XCTAssertEqual(treatmentFound.id, treatmentID)
                XCTAssertEqual(treatmentFound.affectedBone, expectedAffectedBone)
                XCTAssertEqual(treatmentFound.date, expectedDate)
                XCTAssertEqual(treatmentFound.$patient.id, patientID)
            } catch { }
        }
    }
    
    func testGetByIDWithIncorrectIDFails() async throws {
        let falseTreatmentID = UUID()
        
        try await app.test(.GET, "\(baseURL)/12345") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingTreatmentID"))
        }
    }
    
    func testGetByIDWithInexistantTreatmentFails() async throws {
        let falseTreatmentID = UUID()
        
        try await app.test(.GET, "\(baseURL)/\(falseTreatmentID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.treatment"))
        }
    }
}
