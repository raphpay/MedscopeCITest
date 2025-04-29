//
//  Material+Ext.swift
//
//
//  Created by Raphaël Payet on 25/07/2024.
//

@testable import App
import XCTVapor
import Fluent

extension MaterialControllerTests {
    /// Create a new material
    /// - Parameters:
    ///     - db: The database connection to use for the creation
    /// - Returns: The created material
    /// - Throws: An error if the material creation fails
    func createExpectedMaterial(on db: Database) async throws -> Material {
        let material = Material(matName: expectedMatName, e: expectedE, nu: expectedNu, sigmaDam: expectedSigmaDam, sigmaFa: expectedSigmaFa)
        try await material.save(on: db)
        return material
    }
}
