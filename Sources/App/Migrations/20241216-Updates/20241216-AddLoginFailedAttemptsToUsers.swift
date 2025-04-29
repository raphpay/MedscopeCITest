//
//  20241216-AddLoginFailedAttemptsToUsers.swift
//  Medscope
//
//  Created by Raphaël Payet on 16/12/2024.
//

import Fluent

struct AddLoginFailedAttemptsToUsers: AsyncMigration {
    func prepare(on database: Database) async throws {
        // Add the new fields to the User schema
        try await database.schema(User.V20240618.schemaName)
            .field(User.V20241216.loginFailedAttempts, .int, .required)
            .field(User.V20241216.lastLoginFailedAttempt, .string)
            .update()

        // For existing users, set default values
        try await User.query(on: database)
            .set(\.$loginFailedAttempts, to: 0)
            .set(\.$lastLoginFailedAttempt, to: nil)
            .update()
    }

    func revert(on database: Database) async throws {
        // Remove the fields in case of rollback
        try await database.schema(User.V20240618.schemaName)
            .deleteField(User.V20241216.loginFailedAttempts)
            .deleteField(User.V20241216.lastLoginFailedAttempt)
            .update()
    }
}
