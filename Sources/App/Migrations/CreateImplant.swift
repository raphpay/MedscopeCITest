//
//  CreateImplant.swift
//
//
//  Created by Raphaël Payet on 25/06/2024.
//

import Foundation
import Fluent

struct CreateImplant: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(Implant.V20240618.schemaName)
            .id()
            .field(Implant.V20240618.reference, .string, .required)
            .field(Implant.V20240618.internalDiam, .float, .required)
            .field(Implant.V20240618.abutmentContactHeight, .float, .required)
            .field(Implant.V20240618.diameter, .float, .required)
            .field(Implant.V20240618.hneck, .float, .required)
            .field(Implant.V20240618.length, .float, .required)
            .field(Implant.V20240618.matName, .string, .required)
            .field(Implant.V20240618.upCenter, .array(of: .float), .required)
            .field(Implant.V20240618.centerZ, .array(of: .float), .required)
            .field(Implant.V20240618.upIndex, .array(of: .float), .required)
            .field(Implant.V20240618.modelID, .uuid, .required,
                   .references(Document.V20240618.schemaName, Document.V20240618.id))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Implant.V20240618.schemaName)
            .delete()
    }
}
