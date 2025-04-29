//
//  MaterialControllerTests+UPDATE.swift
//
//
//  Created by Raphaël Payet on 17/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Update
extension MaterialControllerTests {
    /// Tests the update of an material
    /// - Given: A valid material ID
    /// - When: The material is updated
    /// - Then: The material is updated successfully
    func testUpdateSucceed() async throws {
        let material = try await MaterialControllerTests().createExpectedMaterial(on: app.db)
        let materialID = try material.requireID()

        let newMatName = "New name"
        let newE = Float(100.0)
        let newSigmaDam = Float(100.0)
        let updateInput = Material.UpdateInput(matName: newMatName, e: newE, nu: nil, sigmaDam: newSigmaDam, sigmaFa: nil)

        try await app.test(.PUT, "\(baseURL)/\(materialID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let updatedMaterial = try res.content.decode(Material.self)
                XCTAssertEqual(updatedMaterial.matName, newMatName)
                XCTAssertEqual(updatedMaterial.e, newE)
                XCTAssertEqual(updatedMaterial.sigmaDam, newSigmaDam)
            } catch { }
        }
    }

    /// Tests the update of an material with an inexistant material
    /// - Given: An invalid material UUID
    /// - When: The material is updated
    /// - Then: The update fails with a not found error
    func testUpdateWithInexistantMaterialFails() async throws {
        let newMatName = "New name"
        let newE = Float(100.0)
        let newSigmaDam = Float(100.0)
        let updateInput = Material.UpdateInput(matName: newMatName, e: newE, nu: nil, sigmaDam: newSigmaDam, sigmaFa: nil)

        try await app.test(.PUT, "\(baseURL)/\(UUID())") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.material"))
        }
    }
}
