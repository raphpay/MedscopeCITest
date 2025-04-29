//
//  APIKey+FieldKeys.swift
//  
//
//  Created by Raphaël Payet on 13/07/2024.
//

import Fluent

extension APIKey {
    enum V20240618 {
        static let schemaName = "apiKeys"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let value = FieldKey(stringLiteral: "value")
    }
}
