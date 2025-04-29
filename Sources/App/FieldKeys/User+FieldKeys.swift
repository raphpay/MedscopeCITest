//
//  User+FieldKeys.swift
//  
//
//  Created by Raphaël Payet on 21/06/2024.
//

import Fluent

extension User {
    enum V20240618 {
        static let schemaName = "users"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let firstName = FieldKey(stringLiteral: "firstName")
        static let address = FieldKey(stringLiteral: "address")
        static let mailAddress = FieldKey(stringLiteral: "mailAddress")
        static let password = FieldKey(stringLiteral: "password")
        static let roleEnum = FieldKey(stringLiteral: "roleEnum")
    }

    enum V20241129 {
        static let conditionsAccepted = FieldKey(stringLiteral: "conditionsAccepted")
        static let conditionsAcceptedTimestamp = FieldKey(stringLiteral: "conditionsAcceptedTimestamp")
    }

    enum V20241216 {
        static let loginFailedAttempts = FieldKey(stringLiteral: "loginFailedAttempts")
        static let lastLoginFailedAttempt = FieldKey(stringLiteral: "lastLoginFailedAttempt")
    }
}
