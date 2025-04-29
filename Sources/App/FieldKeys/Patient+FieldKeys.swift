//
//  Patient+FieldKeys.swift
//  
//
//  Created by Raphaël Payet on 21/06/2024.
//

import Fluent

extension Patient {
    enum V20240618 {
        static let schemaName = "patients"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let firstName = FieldKey(stringLiteral: "firstName")
        static let birthdate = FieldKey(stringLiteral: "birthdate")
        static let userID = FieldKey(stringLiteral: "userID")
        static let laGalaxyID = FieldKey(stringLiteral: "laGalaxyID")

        static let genderEnum = FieldKey(stringLiteral: "genderEnum")
        static let gender = "gender"
        static let female = "female"
        static let male = "male"
    }

    enum V20240823 {
        static let medscopeID = FieldKey(stringLiteral: "medscopeID")
    }
}
