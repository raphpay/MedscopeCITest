//
//  VersionLog+Ext.swift
//  Medscope
//
//  Created by Raphaël Payet on 14/10/2024.
//

import Foundation
//
//  Document+Ext.swift
//
//
//  Created by Raphaël Payet on 25/07/2024.
//

@testable import App
import XCTVapor
import Fluent

extension VersionLogControllerTests {
    /// Create a new version log
    /// - Parameters:
    ///   - interfaceVersion: The interface version
    ///   - apiVersion: The API version
    ///   - calculatorVersion: The calculator version
    ///   - packageVersion: The package version
    ///   - udiVersion: The UDI version
    /// - Returns: The created version log
    /// - Throws: An error if the version log creation fails
    func createExpectedVersionLog(interfaceVersion: String? = nil,
                                  apiVersion: String? = nil,
                                  calculatorVersion: String? = nil,
                                  packageVersion: Int? = nil,
                                  udiVersion: String? = nil,
                                  on db: Database) async throws -> VersionLog {
        var interface = expectedInterfaceVersion
        var api = expectedAPIVersion
        var calculator = expectedCalculatorVersion
        var package = expectedPackage
        var udi = expectedUDI

        if let interfaceVersion = interfaceVersion {
            interface = interfaceVersion
        }

        if let apiVersion = apiVersion {
            api = apiVersion
        }

        if let calculatorVersion = calculatorVersion {
            calculator = calculatorVersion
        }

        if let packageVersion = packageVersion {
            package = packageVersion
        }

        if let udiVersion = udiVersion {
            udi = udiVersion
        }

        let versionLog = VersionLog(interface: interface,
                                    api: api,
                                    calculator: calculator,
                                    package: package,
                                    packageUpdateTimestamp: .now,
                                    udi: udi
        )

        try await versionLog.save(on: db)
        return versionLog
    }
}
