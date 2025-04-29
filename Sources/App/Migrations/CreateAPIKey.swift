//
//  CreateAPIKey.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Foundation
import Fluent

struct CreateAPIKey: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(APIKey.V20240618.schemaName)
            .id()
            .field(APIKey.V20240618.name, .string, .required)
            .field(APIKey.V20240618.value, .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(APIKey.V20240618.schemaName)
            .delete()
    }
}
