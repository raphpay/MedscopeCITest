//
//  CreateFormulaire.swift
//
//
//  Created by Raphaël Payet on 31/07/2024.
//

import Foundation
import Fluent

struct CreateForm: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(Form.V20240618.schemaName)
            .id()
            .field(Form.V20240618.user, .custom(User.self), .required)
            .field(Form.V20240618.patient, .custom(Patient.self), .required)
            .field(Form.V20240618.treatment, .custom(Treatment.self), .required)
            .field(Form.V20240618.surgeryPlans, .custom([SurgeryPlan].self), .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Form.V20240618.schemaName)
            .delete()
    }
}
