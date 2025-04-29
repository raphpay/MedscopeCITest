//
//  Document.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Fluent
import Vapor

final class Document: Model, Content, @unchecked Sendable {
    static let schema = Document.V20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: Document.V20240618.name)
    var name: String

    @Field(key: Document.V20240618.path)
    var path: String

    @Timestamp(key: Document.V20240618.updatedAt, on: .update, format: .iso8601)
    var updatedAt: Date?

    @OptionalParent(key: Document.V20240618.mandibleFileID)
    var mandibleAsSurgeryPlan: SurgeryPlan?

    @OptionalParent(key: Document.V20240618.maxillaryFileID)
    var maxillaryAsSurgeryPlan: SurgeryPlan?

    init() { }

    init(id: UUID? = nil, name: String, path: String, updatedAt: Date? = .now) {
        self.id = id
        self.name = name
        self.path = path
        self.updatedAt = updatedAt
    }

	func toOutput() -> Document.Output {
		.init(id: id, name: name, path: path, updatedAt: updatedAt)
	}
}
