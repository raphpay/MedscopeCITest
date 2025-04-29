//
//  VersionLog+FieldKeys.swift
//  Medscope
//
//  Created by Raphaël Payet on 14/10/2024.
//

import Fluent

extension VersionLog {
    enum V20240618 {
        static let schemaName = "versionLogs"

        static let id = FieldKey(stringLiteral: "id")
        static let interface = FieldKey(stringLiteral: "interface")
        static let api = FieldKey(stringLiteral: "api")
        static let calculator = FieldKey(stringLiteral: "calculator")
        static let submissionPlatform = FieldKey(stringLiteral: "submissionPlatform")
    }

    enum V20241216 {
        static let package = FieldKey(stringLiteral: "package")
        static let packageUpdateTimestamp = FieldKey(stringLiteral: "packageUpdateTimestamp")
        static let udi = FieldKey(stringLiteral: "udi")
    }
}
