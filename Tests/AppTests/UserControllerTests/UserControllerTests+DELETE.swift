//
//  UserControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 15/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - DeleteAll
extension UserControllerTests {
    func testDeleteAllSucceed() async throws {
        let _ = try await UserControllerTests().createExpectedUser(on: app.db)
        
        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            
            do {
                let users = try await User.query(on: app.db).all()
                XCTAssertEqual(users.count, 0)
            } catch { }
        }
    }
    
    func testDeleteAllWithNoUsersSucceed() async throws {
        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            
            do {
                let users = try await User.query(on: app.db).all()
                XCTAssertEqual(users.count, 0)
            } catch { }
        }
    }
    
    func testDeleteAllWithUnauthorizedUserFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .companyOperator, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)
        let _ = try await UserControllerTests().createExpectedUser(on: app.db)
        
        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }
}

// MARK: - Delete
extension UserControllerTests {
    func testDeleteSucceed() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        
        try await app.test(.DELETE, "\(baseURL)/\(userID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            
            do {
                let users = try await User.query(on: app.db).all()
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users[0].name, expectedAdminName)
            } catch { }
        }
    }
    
    func testDeleteWithWrongIDFails() async throws {
        let falseUserID = UUID()
        
        try await app.test(.DELETE, "\(baseURL)/\(falseUserID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testDeleteWithInexistantUserFails() async throws {
        try await app.test(.DELETE, "\(baseURL)/userID") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingUserID"))
        }
    }
    
    func testDeleteWithNonAuthorizedUserFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .companyOperator, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        
        try await app.test(.DELETE, "\(baseURL)/\(userID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        }
    }
}
