//
//  20240919-AddResultsToSurgeryPlan.swift
//  Medscope
//
//  Created by Raphaël Payet on 19/09/2024.
//

import Foundation
import Fluent

struct AddResultsToSurgeryPlan: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(SurgeryPlan.V20240618.schemaName)
            .id()
            .field(SurgeryPlan.V20240919.resultsBoneStress, .uuid)
            .field(SurgeryPlan.V20240919.resultsImplantStress, .uuid)
            .field(SurgeryPlan.V20240919.resultsDensity, .uuid)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(SurgeryPlan.V20240618.schemaName)
            .deleteField(SurgeryPlan.V20240919.resultsBoneStress)
            .deleteField(SurgeryPlan.V20240919.resultsImplantStress)
            .deleteField(SurgeryPlan.V20240919.resultsDensity)
            .update()
    }
}
