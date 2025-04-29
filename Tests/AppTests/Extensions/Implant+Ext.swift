//
//  Implant+Ext.swift
//
//
//  Created by Raphaël Payet on 25/07/2024.
//

@testable import App
import XCTVapor
import Fluent

extension ImplantControllerTests {
    /// Create a new implant
    /// - Parameters:
    ///     - modelID: The ID of the model associated with the implant
    ///     - upCenter: The up center of the implant
    ///     - centerZ: The center Z of the implant
    ///     - upIndex: The up index of the implant
    ///     - db: The database connection to use for the creation
    /// - Returns: The created implant
    /// - Throws: An error if the implant creation fails
    func createExpectedImplantInput(with modelID: Document.IDValue,
                                    upCenter: [Float]? = nil,
                                    centerZ: [Float]? = nil,
                                    upIndex: [Float]? = nil,
                                    on db: Database) -> Implant.Input {
        var upCenterData = expectedUpCenter
        var centerZData = expectedCenterZ
        var upIndexData = expectedUpIndex

        if let data1 = upCenter {
            upCenterData = data1
        }

        if let data2 = centerZ {
            centerZData = data2
        }

        if let data3 = upIndex {
            upIndexData = data3
        }

        let input = Implant.Input(reference: expectedReference,
                                  internalDiam: expectedInternalDiam,
                                  abutmentContactHeight: expectedAbutmentContactHeight,
                                  diameter: expectedDiameter,
                                  hneck: expectedHneck,
                                  length: expectedLength,
                                  matName: expectedMatName,
                                  upCenter: upCenterData,
                                  centerZ: centerZData,
                                  upIndex: upIndexData,
                                  modelID: modelID)

        return input
    }

    /// Create a new implant
    /// - Parameters:
    ///     - modelID: The ID of the model associated with the implant
    ///     - db: The database connection to use for the creation
    /// - Returns: The created implant
    /// - Throws: An error if the implant creation fails
    func createExpectedImplant(with modelID: Document.IDValue, on db: Database) async throws -> Implant {
        let implant = Implant(reference: expectedReference, internalDiam: expectedInternalDiam, abutmentContactHeight: expectedAbutmentContactHeight, diameter: expectedDiameter, hneck: expectedHneck, length: expectedLength, matName: expectedMatName, upCenter: expectedUpCenter, centerZ: expectedCenterZ, upIndex: expectedUpIndex, modelID: modelID)
        try await implant.save(on: db)
        return implant
    }
}
