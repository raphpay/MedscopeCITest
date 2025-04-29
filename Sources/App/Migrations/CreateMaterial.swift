//
//  CreateMaterial.swift
//
//
//  Created by Raphaël Payet on 26/06/2024.
//

import Foundation
import Fluent

struct CreateMaterial: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(Material.V20240618.schemaName)
            .id()
            .field(Material.V20240618.matName, .string, .required)
            .field(Material.V20240618.e, .float, .required)
            .field(Material.V20240618.nu, .float, .required)
            .field(Material.V20240618.sigmaDam, .float, .required)
            .field(Material.V20240618.sigmaFa, .float, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Material.V20240618.schemaName)
            .delete()
    }
}
