//
//  AddConditionsFieldsToUsers.swift
//  Medscope
//
//  Created by Raphaël Payet on 29/11/2024.
//

import Fluent

struct AddConditionsFieldsToUsers: AsyncMigration {
    func prepare(on database: Database) async throws {
        // Add the new fields to the User schema
        try await database.schema(User.V20240618.schemaName)
            .field(User.V20241129.conditionsAccepted, .bool, .required)
            .field(User.V20241129.conditionsAcceptedTimestamp, .string)
            .update()

        // For existing users, set default values
        try await User.query(on: database)
            .set(\.$conditionsAccepted, to: false)
            .set(\.$conditionsAcceptedTimestamp, to: nil)
            .update()
    }

    func revert(on database: Database) async throws {
        // Remove the fields in case of rollback
        try await database.schema(User.V20240618.schemaName)
            .deleteField(User.V20241129.conditionsAccepted)
            .deleteField(User.V20241129.conditionsAcceptedTimestamp)
            .update()
    }
}
