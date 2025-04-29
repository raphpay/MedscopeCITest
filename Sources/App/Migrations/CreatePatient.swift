//
//  CreatePatient.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Foundation
import Fluent

struct CreatePatient: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(Patient.V20240618.schemaName)
            .id()
            .field(Patient.V20240618.name, .string, .required)
            .field(Patient.V20240618.firstName, .string, .required)
            .field(Patient.V20240618.birthdate, .string, .required)
            .field(Patient.V20240618.genderEnum, .string, .required)
            .field(Patient.V20240823.medscopeID, .string, .required)
            .field(Patient.V20240618.userID, .uuid, .required,
                   .references(User.V20240618.schemaName, User.V20240618.id, onDelete: .cascade))
            .field(Patient.V20240618.laGalaxyID, .string)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Patient.V20240618.schemaName)
            .delete()
    }
}
