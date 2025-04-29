//
//  CreateVersion.swift
//  Medscope
//
//  Created by Raphaël Payet on 14/10/2024.
//

import Foundation
import Fluent

struct CreateVersionLog: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(VersionLog.V20240618.schemaName)
            .id()
            .field(VersionLog.V20240618.interface, .string, .required)
            .field(VersionLog.V20240618.api, .string, .required)
            .field(VersionLog.V20240618.calculator, .string, .required)
            .field(VersionLog.V20240618.submissionPlatform, .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(VersionLog.V20240618.schemaName)
            .delete()
    }
}
