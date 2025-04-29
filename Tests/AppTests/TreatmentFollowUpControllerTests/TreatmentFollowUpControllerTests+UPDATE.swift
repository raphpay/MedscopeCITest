//
//  TreatmentFollowUpControllerTests+UPDATE.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Update for calculation
extension TreatmentFollowUpControllerTests {
    func testUpdateTreatmentFollowUpForCalculationSucceed() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCreation(with: treatmentID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateCalculationInput(calculationDate: expectedCalculationDate, operatorID: operatorID)
        
        try await app.test(.PUT, "\(baseURL)/calculate/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let treatmentFollowUp = try res.content.decode(TreatmentFollowUp.self)
                XCTAssertEqual(treatmentFollowUp.calculationDate, expectedCalculationDate)
                XCTAssertEqual(treatmentFollowUp.status, expectedCalculationStatus)
                XCTAssertEqual(treatmentFollowUp.treatmentID, treatmentID)
                XCTAssertEqual(treatmentFollowUp.operatorID, operatorID)
            } catch { }
        })
    }
    
    func testUpdateForCalculationWithInexistantFollowUpFails() async throws {
        let input = TreatmentFollowUp.UpdateCalculationInput(calculationDate: expectedCalculationDate, operatorID: operatorID)
        
        try await app.test(.PUT, "\(baseURL)/calculate/\(UUID())", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.treatmentFollowUp"))
        })
    }
    
    func testUpdateForCalculationWithInvalidDateFails() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCreation(with: treatmentID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateCalculationInput(calculationDate: invalidDate, operatorID: operatorID)
        
        try await app.test(.PUT, "\(baseURL)/calculate/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidCalculationDateFormat"))
        })
    }
    
    func testUpdateForCalculationWithInexistantOperatorFails() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCreation(with: treatmentID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateCalculationInput(calculationDate: expectedCalculationDate, operatorID: UUID())
        
        try await app.test(.PUT, "\(baseURL)/calculate/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.inexistantOperator"))
        })
    }
    
    func testUpdateForCalculationWithMissingOperatorIDFails() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCreation(with: treatmentID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateCalculationInput(calculationDate: expectedCalculationDate, operatorID: nil)
        
        try await app.test(.PUT, "\(baseURL)/calculate/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOperatorID"))
        })
    }
    
    func testUpdateCreateWithMissingCalculationDateFails() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCreation(with: treatmentID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateCalculationInput(calculationDate: nil, operatorID: operatorID)
        
        try await app.test(.PUT, "\(baseURL)/calculate/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingCalculationDate"))
        })
    }
}

// MARK: - Update for validation
extension TreatmentFollowUpControllerTests {
    func testUpdateForValidationSucceed() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCalculation(with: treatmentID, and: operatorID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateValidationInput(validationDate: expectedValidationDate, validatorID: validatorID)
        
        try await app.test(.PUT, "\(baseURL)/validate/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let treatmentFollowUp = try res.content.decode(TreatmentFollowUp.self)
                XCTAssertEqual(treatmentFollowUp.validatorID, validatorID)
                XCTAssertEqual(treatmentFollowUp.validationDate, expectedValidationDate)
                XCTAssertEqual(treatmentFollowUp.calculationDate, expectedCalculationDate)
                XCTAssertEqual(treatmentFollowUp.status, expectedValidationStatus)
                XCTAssertEqual(treatmentFollowUp.treatmentID, treatmentID)
                XCTAssertEqual(treatmentFollowUp.operatorID, operatorID)
            } catch { }
        })
    }
    
    func testUpdateForValidationWithInexistantFollowUpFails() async throws {
        let input = TreatmentFollowUp.UpdateValidationInput(validationDate: expectedValidationDate, validatorID: validatorID)
        
        try await app.test(.PUT, "\(baseURL)/validate/\(UUID())", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.treatmentFollowUp"))
        })
    }
    
    func testUpdateForValidationWithMissingValidatorIDFails() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCalculation(with: treatmentID, and: operatorID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateValidationInput(validationDate: expectedValidationDate, validatorID: nil)
        
        try await app.test(.PUT, "\(baseURL)/validate/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingValidatorID"))
        })
    }
    
    func testUpdateForValidationWithMissingValidationDateFails() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCalculation(with: treatmentID, and: operatorID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateValidationInput(validationDate: nil, validatorID: validatorID)
        
        try await app.test(.PUT, "\(baseURL)/validate/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingValidationDate"))
        })
    }
    
    func testUpdateForValidationWithIncorrectFollowUpStateFails() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCreation(with: treatmentID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateValidationInput(validationDate: expectedValidationDate, validatorID: validatorID)
        
        try await app.test(.PUT, "\(baseURL)/validate/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.incorrectFollowUpState"))
        })
    }
    
    func testUpdateForValidationWithInvalidDateFails() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCalculation(with: treatmentID, and: operatorID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateValidationInput(validationDate: invalidDate, validatorID: validatorID)
        
        try await app.test(.PUT, "\(baseURL)/validate/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidValidationDateFormat"))
        })
    }
    
    func testUpdateForValidationInexistantValidatorFails() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCalculation(with: treatmentID, and: operatorID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateValidationInput(validationDate: expectedValidationDate, validatorID: UUID())
        
        try await app.test(.PUT, "\(baseURL)/validate/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.inexistantValidator"))
        })
    }
}

// MARK: - Update for opening
extension TreatmentFollowUpControllerTests {
    func testUpdateForOpeningSucceed() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtValidation(with: treatmentID, operatorID: operatorID, validatorID: validatorID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateOpeningInput(firstOpenDate: expectedFirstOpenDate)
        
        try await app.test(.PUT, "\(baseURL)/open/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let treatmentFollowUp = try res.content.decode(TreatmentFollowUp.self)
                XCTAssertEqual(treatmentFollowUp.firstOpenDate, expectedFirstOpenDate)
                XCTAssertEqual(treatmentFollowUp.validatorID, validatorID)
                XCTAssertEqual(treatmentFollowUp.validationDate, expectedValidationDate)
                XCTAssertEqual(treatmentFollowUp.calculationDate, expectedCalculationDate)
                XCTAssertEqual(treatmentFollowUp.status, expectedFirstOpenStatus)
                XCTAssertEqual(treatmentFollowUp.treatmentID, treatmentID)
                XCTAssertEqual(treatmentFollowUp.operatorID, operatorID)
            } catch { }
        })
    }
    
    func testUpdateForOpeningWithInexistantFollowUpFails() async throws {
        let input = TreatmentFollowUp.UpdateOpeningInput(firstOpenDate: expectedFirstOpenDate)
        
        try await app.test(.PUT, "\(baseURL)/open/\(UUID())", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.treatmentFollowUp"))
        })
    }
    
    func testUpdateForOpeningWithMissingOpeningDateFails() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtValidation(with: treatmentID, operatorID: operatorID, validatorID: validatorID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateOpeningInput(firstOpenDate: nil)
        
        try await app.test(.PUT, "\(baseURL)/open/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOpeningDate"))
        })
    }
    
    func testUpdateForOpeningWithIncorrectFollowUpStateFails() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCreation(with: treatmentID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateOpeningInput(firstOpenDate: expectedFirstOpenDate)
        
        try await app.test(.PUT, "\(baseURL)/open/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.incorrectFollowUpState"))
        })
    }
    
    func testUpdateForOpeningWithInvalidDateFails() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtValidation(with: treatmentID, operatorID: operatorID, validatorID: validatorID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let input = TreatmentFollowUp.UpdateOpeningInput(firstOpenDate: invalidDate)
        
        try await app.test(.PUT, "\(baseURL)/open/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidFirstOpenDateFormat"))
        })
    }
}

// MARK: - Update Status
extension TreatmentFollowUpControllerTests {
    func testUpdateStatusSucceed() async throws {
        let treatmentFollowUp = try await TreatmentFollowUpControllerTests().createExpectedTreatmentFollowUpAtCreation(with: treatmentID, on: app.db)
        let treatmentFollowUpID = try treatmentFollowUp.requireID()
        
        let newStatus = TreatmentFollowUp.Status.deleted
        let input = TreatmentFollowUp.UpdateStatusInput(status: .deleted)
        
        try await app.test(.PUT, "\(baseURL)/status/\(treatmentFollowUpID)", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let treatmentFollowUp = try res.content.decode(TreatmentFollowUp.self)
                XCTAssertEqual(treatmentFollowUp.status, newStatus)
                XCTAssertEqual(treatmentFollowUp.treatmentID, treatmentID)
            } catch { }
        })
    }
    
    func testUpdateStatusWithInexistantFollowUpFails() async throws {
        let newStatus = TreatmentFollowUp.Status.deleted
        let input = TreatmentFollowUp.UpdateStatusInput(status: .deleted)
        
        try await app.test(.PUT, "\(baseURL)/status/\(UUID())", beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.treatmentFollowUp"))
        })
    }
}
