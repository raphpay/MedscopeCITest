//
//  CreatePasswordResetToken.swift
//
//
//  Created by Raphaël Payet on 05/11/2024.
//

import Fluent
import Vapor

struct CreatePasswordResetToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(PasswordResetToken.V20240618.schemaName)
            .id()
            .field(PasswordResetToken.V20240618.token, .string, .required)
            .field(PasswordResetToken.V20240618.userEmail, .string, .required)
            .field(PasswordResetToken.V20240618.expiresAt, .date, .required)
            .field(PasswordResetToken.V20240618.userID, .uuid, .required,
                   .references(User.V20240618.schemaName, User.V20240618.id, onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(PasswordResetToken.V20240618.schemaName)
            .delete()
    }
}
