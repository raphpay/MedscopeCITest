//
//  Material+FieldKeys.swift
//
//
//  Created by Raphaël Payet on 26/06/2024.
//

import Fluent

extension Material {
    enum V20240618 {
        static let schemaName = "materials"

        static let id = FieldKey(stringLiteral: "id")
        static let matName = FieldKey(stringLiteral: "matName")
        static let e = FieldKey(stringLiteral: "e")
        static let nu = FieldKey(stringLiteral: "nu")
        static let sigmaDam = FieldKey(stringLiteral: "sigmaDam")
        static let sigmaFa = FieldKey(stringLiteral: "sigmaFa")
        static let implantID = FieldKey(stringLiteral: "implantID")
    }
}
