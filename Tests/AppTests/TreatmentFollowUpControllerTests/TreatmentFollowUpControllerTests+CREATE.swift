//
//  TreatmentFollowUpControllerTests.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - CREATE
extension TreatmentFollowUpControllerTests {
    func test_Create_Succeed() async throws {
        let input = TreatmentFollowUp.Input(creationDate: expectedCreationDate,
                                            treatmentID: treatmentID,
                                            status: expectedCreationStatus,
                                            calculationDate: nil,
                                            operatorID: nil,
                                            validationDate: nil,
                                            validatorID: nil,
                                            firstOpenDate: nil)
        
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let treatmentFollowUp = try res.content.decode(TreatmentFollowUp.self)
                XCTAssertEqual(treatmentFollowUp.creationDate, expectedCreationDate)
                XCTAssertEqual(treatmentFollowUp.treatmentID, treatmentID)
                XCTAssertEqual(treatmentFollowUp.status, expectedCreationStatus)
            } catch { }
        })
    }
    
    func testCreateFollowUpWithIncorrectCreationDateFails() async throws {
        let incorrectCreationDate = "2024"
        let input = TreatmentFollowUp.Input(creationDate: incorrectCreationDate, treatmentID: treatmentID, status: expectedCreationStatus,
                                            calculationDate: nil, operatorID: nil, validationDate: nil, validatorID: nil, firstOpenDate: nil)
        
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidCreationDateFormat"))
        })
    }
    
    func testCreateFollowUpWithInexistantTreatmentFails() async throws {
        let input = TreatmentFollowUp.Input(creationDate: expectedCreationDate, treatmentID: UUID(), status: expectedCreationStatus,
                                            calculationDate: nil, operatorID: nil, validationDate: nil, validatorID: nil, firstOpenDate: nil)
        
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.inexistantTreatment"))
        })
    }
}
