//
//  AddIsTreatedParameterToSurgeryPlan.swift
//  Medscope
//
//  Created by Raphaël Payet on 07/03/2025.
//

import Foundation
import Fluent

struct AddIsTreatedParameterToSurgeryPlan: AsyncMigration {
    func prepare(on database: Database) async throws {
        // Add the new fields to the User schema
        try await database.schema(SurgeryPlan.V20240618.schemaName)
            .field(SurgeryPlan.V20250306.isTreated, .string)
            .update()

        try await SurgeryPlan.query(on: database)
            .set(\.$isTreated, to: false)
            .update()
    }

    func revert(on database: Database) async throws {
        // Remove the fields in case of rollback
        try await database.schema(SurgeryPlan.V20240618.schemaName)
            .deleteField(SurgeryPlan.V20250306.isTreated)
            .update()
    }
}
