//
//  20240913-UpdateSurgeryPlanAddOptionalImplantsModels.swift
//
//
//  Created by Raphaël Payet on 13/09/2024.
//

import Foundation

import Fluent

struct AddOptionalImplantsModelsToSurgeryPlan: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(SurgeryPlan.V20240618.schemaName)
            .field(SurgeryPlan.V20240618.implantsModels, .string)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(SurgeryPlan.V20240618.schemaName)
            .deleteField(SurgeryPlan.V20240618.implantsModels)
            .update()
    }
}
