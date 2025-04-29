//
//  FileDownload.swift
//
//
//  Created by Raphaël Payet on 02/09/2024.
//

import Vapor
import Fluent

final class FileDownload: Model, Content, @unchecked Sendable {
    static let schema = FileDownload.V20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: FileDownload.V20240618.filePath)
    var filePath: String

    @Field(key: FileDownload.V20240618.downloadToken)
    var downloadToken: String

    @Field(key: FileDownload.V20240618.expiresAt)
    var expiresAt: Date

    @OptionalField(key: FileDownload.V20240618.usedAt)
    var usedAt: Date?

    init() {}

    init(id: UUID? = nil, filePath: String, downloadToken: String, expiresAt: Date, usedAt: Date? = nil) {
        self.id = id
        self.filePath = filePath
        self.downloadToken = downloadToken
        self.expiresAt = expiresAt
        self.usedAt = usedAt
    }
}
