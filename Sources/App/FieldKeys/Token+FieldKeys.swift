//
//  Token+FieldKeys.swift
//  
//
//  Created by Raphaël Payet on 30/07/2024.
//

import Fluent

extension Token {
    enum V20240618 {
        static let schemaName = "tokens"

        static let id = FieldKey(stringLiteral: "id")
        static let value = FieldKey(stringLiteral: "value")
        static let userID = FieldKey(stringLiteral: "userID")
    }
}
