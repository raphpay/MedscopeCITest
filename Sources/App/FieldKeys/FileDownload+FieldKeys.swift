//
//  FileDownload+FieldKeys.swift
//
//
//  Created by Raphaël Payet on 02/09/2024.
//

import Fluent


extension FileDownload {
    enum V20240618 {
        static let schemaName = "fileDownloads"

        static let id = FieldKey(stringLiteral: "id")
        static let filePath = FieldKey(stringLiteral: "filePath")
        static let downloadToken = FieldKey(stringLiteral: "downloadToken")
        static let expiresAt = FieldKey(stringLiteral: "expiresAt")
        static let usedAt = FieldKey(stringLiteral: "usedAt")
    }
}
