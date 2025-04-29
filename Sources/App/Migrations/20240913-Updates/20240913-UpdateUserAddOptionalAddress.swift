//
//  UpdateUserAddOptionalAddress.swift
//  
//
//  Created by Raphaël Payet on 13/09/2024.
//

import Foundation
import Fluent

struct UpdateUserAddOptionalAddress: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(User.V20240618.schemaName)
            .id()
            .field(User.V20240618.address, .string)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(User.V20240618.schemaName)
            .deleteField(User.V20240618.address)
            .update()
    }
}
