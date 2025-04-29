//
//  PasswordResetToken+FieldKeys.swift
//  
//
//  Created by Raphaël Payet on 05/11/2024.
//

import Fluent

extension PasswordResetToken {
    enum V20240618 {
        static let schemaName = "password_reset_tokens"
        static let id = FieldKey(stringLiteral: "id")
        static let token = FieldKey(stringLiteral: "token")
        static let userID = FieldKey(stringLiteral: "userID")
        static let userEmail = FieldKey(stringLiteral: "userEmail")
        static let expiresAt = FieldKey(stringLiteral: "expiresAt")
    }
}
