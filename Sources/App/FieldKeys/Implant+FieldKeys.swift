//
//  Implant+FieldKeys.swift
//
//
//  Created by Raphaël Payet on 25/06/2024.
//

import Fluent

extension Implant {
    enum V20240618 {
        static let schemaName = "implants"

        static let id = FieldKey(stringLiteral: "id")
        static let reference = FieldKey(stringLiteral: "reference")
        static let internalDiam = FieldKey(stringLiteral: "internalDiam")
        static let abutmentContactHeight = FieldKey(stringLiteral: "abutmentContactHeight")
        static let diameter = FieldKey(stringLiteral: "diameter")
        static let hneck = FieldKey(stringLiteral: "hneck")
        static let length = FieldKey(stringLiteral: "length")
        static let matName = FieldKey(stringLiteral: "matName")
        static let upCenter = FieldKey(stringLiteral: "upCenter")
        static let centerZ = FieldKey(stringLiteral: "centerZ")
        static let upIndex = FieldKey(stringLiteral: "upIndex")
        static let surgeryPlanID = FieldKey(stringLiteral: "surgeryPlanID")
        static let modelID = FieldKey(stringLiteral: "modelID")
    }

    enum V20250311 {
        static let depth = FieldKey(stringLiteral: "depth")
    }
}
