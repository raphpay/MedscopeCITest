//
//  CreateDocument.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Foundation
import Fluent

struct CreateDocument: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(Document.V20240618.schemaName)
            .id()
            .field(Document.V20240618.name, .string, .required)
            .field(Document.V20240618.path, .string, .required)
            .field(Document.V20240618.updatedAt, .date)
            .field(Document.V20240618.treatmentID, .uuid,
                   .references(Treatment.V20240618.schemaName, Treatment.V20240618.id))
            .field(SurgeryPlan.V20240618.mandibleFileID, .uuid,
                   .references(SurgeryPlan.V20240618.schemaName, SurgeryPlan.V20240618.id))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Document.V20240618.schemaName)
            .delete()
    }
}
