//
//  VersionLogControllerTests+READ.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - CREATE
extension VersionLogControllerTests {
    func testGetCurrentVersionLogSucceed() async throws {
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        
        try await app.test(.GET, baseURL, beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: nil, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let versionLog = try res.content.decode(VersionLog.self)
                XCTAssertEqual(versionLog.interface, expectedInterfaceVersion)
                XCTAssertEqual(versionLog.api, expectedAPIVersion)
                XCTAssertEqual(versionLog.calculator, expectedCalculatorVersion)
                XCTAssertEqual(versionLog.package, expectedPackage)
                XCTAssertEqual(versionLog.udi, expectedUDI)
            } catch { }
        })
    }
    
    func testGetCurrentVersionLogWithoutExistingVersionLogFails() async throws {
        try await app.test(.GET, baseURL, beforeRequest: { req in
            // When
            req = Utils.prepareHeaders(apiKey: apiKey, token: nil, on: req)
        }, afterResponse: { res async  in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.versionLog"))
        })
    }
}
