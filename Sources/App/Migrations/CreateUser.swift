//
//  CreateUser.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Foundation
import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(User.V20240618.schemaName)
            .id()
            .field(User.V20240618.name, .string, .required)
            .field(User.V20240618.firstName, .string, .required)
            .field(User.V20240618.address, .string, .required)
            .field(User.V20240618.mailAddress, .string, .required)
            .field(User.V20240618.password, .string, .required)
            .field(User.V20240618.roleEnum, .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(User.V20240618.schemaName)
            .delete()
    }
}
