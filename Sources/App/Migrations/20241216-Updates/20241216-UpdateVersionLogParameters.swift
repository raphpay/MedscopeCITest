//
//  20241216-UpdateVersionLogParameters.swift
//  Medscope
//
//  Created by Raphaël Payet on 17/12/2024.
//

import Foundation
import Fluent

struct UpdateVersionLogParameters: AsyncMigration {
    func prepare(on database: Database) async throws {
        // Add the new fields to the User schema
        try await database.schema(VersionLog.V20240618.schemaName)
            .deleteField(VersionLog.V20240618.submissionPlatform)
            .field(VersionLog.V20241216.package, .int, .required)
            .field(VersionLog.V20241216.packageUpdateTimestamp, .date, .required)
            .field(VersionLog.V20241216.udi, .string, .required)
            .update()

        // For existing users, set default values
        try await VersionLog.query(on: database)
            .set(\.$package, to: 0)
            .set(\.$packageUpdateTimestamp, to: .now)
            .set(\.$udi, to: "")
            .update()
    }

    func revert(on database: Database) async throws {
        // Remove the fields in case of rollback
        try await database.schema(VersionLog.V20240618.schemaName)
            .deleteField(VersionLog.V20241216.package)
            .deleteField(VersionLog.V20241216.packageUpdateTimestamp)
            .deleteField(VersionLog.V20241216.udi)
            .field(VersionLog.V20240618.submissionPlatform, .string)
            .update()
    }
}
