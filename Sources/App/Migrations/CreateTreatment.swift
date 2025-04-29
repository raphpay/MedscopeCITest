//
//  CreateTreatment.swift
//
//
//  Created by Raphaël Payet on 19/06/2024.
//

import Foundation
import Fluent

struct CreateTreatment: AsyncMigration {
    func prepare(on database: Database) async throws {

        try await database
            .schema(Treatment.V20240618.schemaName)
            .id()
            .field(Treatment.V20240618.date, .date, .required)
            .field(Treatment.V20240618.affectedBoneEnum, .string, .required)
            .field(Treatment.V20240618.patientID, .uuid, .required)
            .field(Treatment.V20240618.dicomID, .uuid, .required)
            .field(Treatment.V20240618.model3Ds, .uuid, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Treatment.V20240618.schemaName)
            .delete()
    }
}
