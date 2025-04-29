//
//  TreatmentFollowUpControllerTests+READ.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Get All
extension TreatmentFollowUpControllerTests {
    func testGetAllSucceed() async throws {
        let _ = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCreation(with: treatmentID, on: app.db)
        
        try await app.test(.GET, baseURL, beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let treatmentFollowUps = try res.content.decode([TreatmentFollowUp].self)
                XCTAssertEqual(treatmentFollowUps.count, 1)
                XCTAssertEqual(treatmentFollowUps[0].creationDate, expectedCreationDate)
                XCTAssertEqual(treatmentFollowUps[0].status, expectedCreationStatus)
                XCTAssertEqual(treatmentFollowUps[0].treatmentID, treatmentID)
            } catch { }
        })
    }
    
    func testGetAllWithoutDataSucceed() async throws {
        try await app.test(.GET, baseURL, beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let treatmentFollowUps = try res.content.decode([TreatmentFollowUp].self)
                XCTAssertEqual(treatmentFollowUps.count, 0)
            } catch { }
        })
    }
}

// MARK: - Get Treatment Follow Up
extension TreatmentFollowUpControllerTests {
    func testGetTreatmentFollowUpSucceed() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCreation(with: treatmentID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        try await app.test(.GET, "\(baseURL)/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let treatmentFollowUp = try res.content.decode(TreatmentFollowUp.self)
                XCTAssertEqual(treatmentFollowUp.creationDate, expectedCreationDate)
                XCTAssertEqual(treatmentFollowUp.status, expectedCreationStatus)
                XCTAssertEqual(treatmentFollowUp.treatmentID, treatmentID)
            } catch { }
        })
    }
    
    func testGetTreatmentFollowUpWithInexistantFollowUpFails() async throws {
        let falseFollowUpID = UUID()
        try await app.test(.GET, "\(baseURL)/\(falseFollowUpID)", beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.treatmentFollowUp"))
        })
    }
}
