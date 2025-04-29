//
//  CreateToken.swift
//
//
//  Created by Raphaël Payet on 30/07/2024.
//

import Foundation
import Fluent

struct CreateToken: AsyncMigration {
    func prepare(on database: Database) async throws {

        try await database
            .schema(Token.V20240618.schemaName)
            .id()
            .field(Token.V20240618.value, .string, .required)
            .field(Token.V20240618.userID, .uuid, .required,
                   .references(User.V20240618.schemaName, User.V20240618.id)
            )
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Token.V20240618.schemaName)
            .delete()
    }
}
