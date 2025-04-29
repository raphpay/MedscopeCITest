//
//  AddDepthParameterToImplant.swift
//  Medscope
//
//  Created by Raphaël Payet on 11/03/2025.
//

import Foundation
import Fluent

struct AddDepthParameterToImplant: AsyncMigration {
    func prepare(on database: Database) async throws {
        // Add the new fields to the User schema
        try await database.schema(Implant.V20240618.schemaName)
            .field(Implant.V20250311.depth, .array(of: .float), .required)
            .update()
    }

    func revert(on database: Database) async throws {
        // Remove the fields in case of rollback
        try await database.schema(Implant.V20240618.schemaName)
            .deleteField(Implant.V20250311.depth)
            .update()
    }
}
