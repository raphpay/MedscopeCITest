//
//  UserControllerTests+UPDATE.swift
//
//
//  Created by Raphaël Payet on 15/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Update
extension UserControllerTests {
    func testUpdateSucceed() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        
        let updatedName = "updatedName"
        let updatedFirstName = "updatedFirstName"
        let updatedAddress = "updatedAddress"
        let updatedRole = User.Role.user
        let updatedUser = User.UpdateInput(name: updatedName, firstName: updatedFirstName,
                                           address: updatedAddress, mailAddress: nil,
                                           conditionsAccepted: nil, conditionsAcceptedTimestamp: nil,
                                           role: updatedRole)
        
        try await app.test(.PUT, "\(baseURL)/\(userID)") { req in
            try req.content.encode(updatedUser)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let user = try res.content.decode(User.self)
                XCTAssertEqual(user.name, updatedName)
                XCTAssertEqual(user.firstName, updatedFirstName)
                XCTAssertEqual(user.address, updatedAddress)
                XCTAssertEqual(user.role, updatedRole)
            } catch { }
        }
    }
    
    func testUpdateUserWithWrongIDFails() async throws {
        try await app.test(.PUT, "\(baseURL)/userID") { req async in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingUserID"))
        }
    }
    
    func testUpdateInexistantUserFails() async throws {
        let falseUserID = UUID()
        try await app.test(.PUT, "\(baseURL)/\(falseUserID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testUpdateUserWithNotAcceptedConditionsFails() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        
        let updatedUser = User.UpdateInput(name: nil, firstName: nil,
                                           address: nil, mailAddress: nil,
                                           conditionsAccepted: false,
                                           conditionsAcceptedTimestamp: nil, role: nil)
        try await app.test(.PUT, "\(baseURL)/\(userID)", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updatedUser)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.conditionsNotAccepted"))
        })
    }
    
    func testUpdateUserWithIncorrectConditionAcceptedTimetampFails() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        
        let updatedUser = User.UpdateInput(name: nil, firstName: nil,
                                           address: nil, mailAddress: nil,
                                           conditionsAccepted: nil,
                                           conditionsAcceptedTimestamp: incorrectConditionsAcceptedTimestamp,
                                           role: nil)
        
        try await app.test(.PUT, "\(baseURL)/\(userID)", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updatedUser)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidConditionsAcceptedTimestamp"))
        })
    }
    
    func testUpdateUserRoleWithUnauthorizedUserFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .user, on: app.db)
        let userID = try unauthorizedUser.requireID()
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)
        
        let updatedInput = User.UpdateInput(name: nil, firstName: nil,
                                           address: nil, mailAddress: nil,
                                           conditionsAccepted: nil,
                                           conditionsAcceptedTimestamp: nil,
                                           role: .admin)
        
        try await app.test(.PUT, "\(baseURL)/\(userID)", beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
            try req.content.encode(updatedInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
}

// MARK: - Update User Mail Address
extension UserControllerTests {
    func testUpdateUserMailAddressSucceed() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        let newMailAddress = "newMailAddress@test.com"
        
        try await app.test(.PUT, "\(baseURL)/mail/\(userID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(newMailAddress)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let user = try res.content.decode(User.self)
                XCTAssertEqual(user.id, userID)
                XCTAssertEqual(user.mailAddress, newMailAddress)
            } catch {}
        }
    }
    
    func testUpdateUserMailAddressWithIncorrectIDFails() async throws {
        let newMailAddress = "newMailAddress@test.com"
        
        try await app.test(.PUT, "\(baseURL)/mail/123456") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(newMailAddress)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingUserID"))
        }
    }
    
    func testUpdateUserMailAddressWithInexistantUserFails() async throws {
        let newMailAddress = "newMailAddress@test.com"
        let falseUserID = UUID()
        
        try await app.test(.PUT, "\(baseURL)/mail/\(falseUserID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(newMailAddress)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testUpdateUserMailAddresWithSameMailAddressFails() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        let newMailAddress = expectedMailAddress
        
        try await app.test(.PUT, "\(baseURL)/mail/\(userID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(newMailAddress)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.userAlreadyExists"))
        }
    }
}
