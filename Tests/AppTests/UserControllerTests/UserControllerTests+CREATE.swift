//
//  UserControllerTests+CREATE.swift
//  
//
//  Created by Raphaël Payet on 14/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - CREATE
extension UserControllerTests {
    func testCreateUserWithCorrectAPIKeyAndInfosSucceed() async throws {
        // Given
        let userInput = UserControllerTests().createUserInput()
       
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(userInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let user = try res.content.decode(User.self)
                XCTAssertEqual(user.name, expectedName)
                XCTAssertEqual(user.firstName, expectedFirstName)
                XCTAssertEqual(user.address, expectedAddress)
            } catch { }
        })
    }
    
    func testCreateUserWithoutAPIKeyAndInfosFails() async throws {
        // Given
        let userInput = UserControllerTests().createUserInput()
       
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: nil, token: token, on: req)
            try req.content.encode(userInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.missingAPIKey"))
        })
    }
    
    func testCreateWithAlreadyExistingUserFails() async throws {
        let _ = try await UserControllerTests().createExpectedUser(on: app.db)
        let userInput = UserControllerTests().createUserInput()
        
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(userInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.userAlreadyExists"))
        })
    }
    
    func testCreateWithLongNameFails() async throws {
        let userInput = UserControllerTests().createUserInput(name: longName)
        
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(userInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.nameLength"))
        })
    }
    
    func testCreateWithLongFirstNameFails() async throws {
        let userInput = UserControllerTests().createUserInput(firstName: longFirstName)
        
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(userInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.firstNameLength"))
        })
    }
    
    func testCreateWithLongAddressFails() async throws {
        let userInput = UserControllerTests().createUserInput(address: longAddress)
            
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(userInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.addressLength"))
        })
    }
    
    func testCreateWithIncorrectMailFails() async throws {
        let userInput = UserControllerTests().createUserInput(mailAddress: incorrectMail)
        
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(userInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.incorrectMailAddressFormat"))
        })
    }
    
    func testCreateWithIncorrectPasswordLengthFails() async throws {
        let userInput = UserControllerTests().createUserInput(password: incorrectPasswordLength)
        
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(userInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.password.invalidLength"))
        })
    }
    
    func testCreateWithPasswordMissingUppercaseFails() async throws {
        let userInput = UserControllerTests().createUserInput(password: incorrectPasswordUppercase)
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(userInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.password.missingUppercase"))
        })
    }
    
    func testCreateWithPasswordMissingDigitFails() async throws {
        let userInput = UserControllerTests().createUserInput(password: incorrectPasswordDigit)
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(userInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.password.missingDigit"))
        })
    }
    
    func testCreateWithPasswordMissingSpecialCharacterFails() async throws {
        let userInput = UserControllerTests().createUserInput(password: incorrectPasswordSymbol)
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(userInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.password.missingSpecialCharacter"))
        })
    }
    
    func testCreateWithNotAcceptedConditionsFails() async throws {
        let userInput = UserControllerTests().createUserInput(conditionsAccepted: false)
        
        try await app.test(.POST, baseURL, beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(userInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.conditionsNotAccepted"))
        })
    }
    
    func testCreateWithIncorrectConditionsAcceptedTimestampFails() async throws {
        let userInput = UserControllerTests().createUserInput(conditionsAcceptedTimestamp: incorrectConditionsAcceptedTimestamp)
        try await app.test(.POST, baseURL, beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(userInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidConditionsAcceptedTimestamp"))
        })
    }
    
}
