//
//  VersionLogTests+CREATE.swift
//  Medscope
//
//  Created by Raphaël Payet on 14/10/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - CREATE
extension VersionLogControllerTests {
    func testCreateVersionLogSucceed() async throws {
        // Given
        let input = VersionLog.Input(interface: expectedInterfaceVersion,
                                     api: expectedAPIVersion,
                                     calculator: expectedCalculatorVersion,
                                     package: expectedPackage,
                                     udi: expectedUDI
        )
       
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let versionLog = try res.content.decode(VersionLog.self)
                XCTAssertEqual(versionLog.interface, expectedInterfaceVersion)
                XCTAssertEqual(versionLog.api, expectedAPIVersion)
                XCTAssertEqual(versionLog.calculator, expectedCalculatorVersion)
                XCTAssertEqual(versionLog.package, expectedPackage)
            } catch { }
        })
    }
    
    func testCreateVersionLogWithAlreadyExistingVersionLogFails() async throws {
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        
        // Given
        let input = VersionLog.Input(interface: expectedInterfaceVersion,
                                     api: expectedAPIVersion,
                                     calculator: expectedCalculatorVersion,
                                     package: expectedPackage,
                                     udi: expectedUDI
        )
       
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .conflict)
            XCTAssertTrue(res.body.string.contains("conflict.versionLogAlreadyExists"))
        })
    }
    
    func testCreateVersionLogWithUnauthorizedUserFails() async throws {
        // Given
        let unauthorizedUser = try await UserControllerTests().createUnauthorizedUser(with: .user, on: app.db)
        let unauthorizedToken = try await Token.create(with: unauthorizedUser, on: app.db)
        
        let input = VersionLog.Input(interface: expectedInterfaceVersion,
                                     api: expectedAPIVersion,
                                     calculator: expectedCalculatorVersion,
                                     package: expectedPackage,
                                     udi: expectedUDI
        )
       
        try await app.test(.POST, baseURL, beforeRequest: { req in
            // When
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: unauthorizedToken, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
}
