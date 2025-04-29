//
//  VersionLogControllerTests+UPDATE.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - CREATE
extension VersionLogControllerTests {
    func testUpdateVersionLogSucceed() async throws {
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        let newInterfaceVersion = "1.0.0"
        let newAPIVersion = "2.0.0"
        let newCalculatorVersion = "3.0.0"
        let newUDIVersion = "1235MEDSCOPEYT"
        let updateInput = VersionLog.UpdateInput(interface: newInterfaceVersion,
                                                 api: newAPIVersion,
                                                 calculator: newCalculatorVersion, udi: newUDIVersion)
        
        try await app.test(.PUT, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(updateInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let versionLog = try res.content.decode(VersionLog.self)
                XCTAssertEqual(versionLog.interface, newInterfaceVersion)
                XCTAssertEqual(versionLog.api, newAPIVersion)
                XCTAssertEqual(versionLog.calculator, newCalculatorVersion)
                XCTAssertEqual(versionLog.udi, newUDIVersion)
            } catch { }
        })
    }
    
    func testUpdateVersionWithoutExistingVersionLogFails() async throws {
        let newInterfaceVersion = "1.0.0"
        let newAPIVersion = "2.0.0"
        let newCalculatorVersion = "3.0.0"
        let newUDIVersion = "1235MEDSCOPEYT"
        let updateInput = VersionLog.UpdateInput(interface: newInterfaceVersion,
                                                 api: newAPIVersion,
                                                 calculator: newCalculatorVersion,
                                                 udi: newUDIVersion)
        
        try await app.test(.PUT, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(updateInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.versionLog"))
        })
    }
    
    func testUpdateWithInterfaceRegressionFails() async throws {
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(interfaceVersion: "0.1.002", on: app.db)
        let newInterfaceVersion = "0.1.001"
        let updateInput = VersionLog.UpdateInput(interface: newInterfaceVersion,
                                                 api: nil, calculator: nil, udi: nil)
        
        try await app.test(.PUT, baseURL, beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.interfaceRegression"))
        })
    }
    
    func testUpdateWithAPIRegressionFails() async throws {
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        let newAPIVersion = "0.1.002"
        let updateInput = VersionLog.UpdateInput(interface: nil,
                                                 api: newAPIVersion,
                                                 calculator: nil, udi: nil)
        
        try await app.test(.PUT, baseURL, beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.apiRegression"))
        })
    }
    
    func testUpdateWithCalculatorRegressionFails() async throws {
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(calculatorVersion: "3.0.001", on: app.db)
        let newCalculVersion = "0.1.001"
        let updateInput = VersionLog.UpdateInput(interface: nil, api: nil,
                                                 calculator: newCalculVersion,
                                                 udi: nil)
        
        try await app.test(.PUT, baseURL, beforeRequest: { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.calculatorRegression"))
        })
    }
    
    func testUpdateVersionLogWithIncorrectRoleFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .user, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)
        
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        let newUDIVersion = "1235MEDSCOPEYT"
        let updateInput = VersionLog.UpdateInput(interface: nil,
                                                 api: nil,
                                                 calculator: nil,
                                                 udi: newUDIVersion)
        
        try await app.test(.PUT, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(updateInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
}

// MARK: - Update Package
extension VersionLogControllerTests {
    func testUpdateVersionLogPackageSucceed() async throws {
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        let newPackageVersion = 2
        let updateInput = VersionLog.PackageUpdateInput(package: newPackageVersion)
        
        try await app.test(.PUT, "\(baseURL)/package", beforeRequest: { req in
            // When
            try req.content.encode(updateInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let versionLog = try res.content.decode(VersionLog.self)
                XCTAssertEqual(versionLog.package, newPackageVersion)
            } catch { }
        })
    }
    
    func testUpdateVersionLogPackageWithIncorrectRoleFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .user, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)
        
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        let newPackageVersion = 2
        let updateInput = VersionLog.PackageUpdateInput(package: newPackageVersion)
        
        try await app.test(.PUT, "\(baseURL)/package", beforeRequest: { req in
            // When
            try req.content.encode(updateInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
    
    func testUpdateVersionLogPackageWithInexistantVersionLogFails() async throws {
        let newPackageVersion = 2
        let updateInput = VersionLog.PackageUpdateInput(package: newPackageVersion)
        
        try await app.test(.PUT, "\(baseURL)/package", beforeRequest: { req in
            // When
            try req.content.encode(updateInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.versionLog"))
        })
    }
}

// MARK: - Reset
extension VersionLogControllerTests {
    func testResetVersionLogPackageSucceed() async throws {
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        
        try await app.test(.PUT, "\(baseURL)/reset/package", beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let versionLog = try res.content.decode(VersionLog.self)
                XCTAssertEqual(versionLog.package, 0)
            } catch { }
        })
    }
    
    func testResetVersionLogPackageWithIncorrectRoleFails() async throws {
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .user, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)
        
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        
        try await app.test(.PUT, "\(baseURL)/reset/package", beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
    
    func testResetVersionLogPackageWithInexistantVersionLogFails() async throws {
        try await app.test(.PUT, "\(baseURL)/reset/package", beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.versionLog"))
        })
    }
}
