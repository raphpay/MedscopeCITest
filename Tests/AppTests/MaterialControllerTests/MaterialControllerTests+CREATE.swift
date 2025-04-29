//
//  MaterialControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Create
extension MaterialControllerTests {
    /// Tests the creation of a material
    /// - Given: A valid input
    /// - When: The material is created
    /// - Then: The material is created
    func testCreateSucceed() async throws {
        let input = Material.Input(matName: expectedMatName, e: expectedE, nu: expectedNu, sigmaDam: expectedSigmaDam, sigmaFa: expectedSigmaFa)

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let material = try res.content.decode(Material.self)
                XCTAssertEqual(material.matName, expectedMatName)
                XCTAssertEqual(material.nu, expectedNu)
            } catch { }
        }
    }
}
