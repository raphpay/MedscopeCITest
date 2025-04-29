//
//  AddDepthParameterToSurgeryPlan.swift
//  Medscope
//
//  Created by Raphaël Payet on 14/03/2025.
//

import Foundation
import Fluent

struct AddDepthParameterToSurgeryPlan: AsyncMigration {
    func prepare(on database: Database) async throws {
        // Add the new fields to the User schema
        try await database.schema(SurgeryPlan.V20240618.schemaName)
            .field(SurgeryPlan.V20250314.depth, .array(of: .float), .required)
            .update()

        // Set default values if needed
        try await SurgeryPlan.query(on: database)
            .set(\.$depth, to: [])
            .update()
    }

    func revert(on database: Database) async throws {
        // Remove the fields in case of rollback
		try await database.schema(SurgeryPlan.V20240618.schemaName)
            .deleteField(SurgeryPlan.V20250314.depth)
            .update()
    }
}
