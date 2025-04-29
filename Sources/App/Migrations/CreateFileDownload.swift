//
//  CreateFileDownload.swift
//  
//
//  Created by Raphaël Payet on 02/09/2024.
//

import Foundation
import Fluent

struct CreateFileDownload: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(FileDownload.V20240618.schemaName)
            .id()
            .field(FileDownload.V20240618.filePath, .string, .required)
            .field(FileDownload.V20240618.downloadToken, .string, .required)
            .field(FileDownload.V20240618.expiresAt, .date, .required)
            .field(FileDownload.V20240618.usedAt, .date)
            .unique(on: FileDownload.V20240618.downloadToken)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(FileDownload.V20240618.schemaName)
            .delete()
    }
}
