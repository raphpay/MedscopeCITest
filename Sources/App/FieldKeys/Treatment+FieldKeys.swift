//
//  Treatment+FieldKeys.swift
//
//
//  Created by Raphaël Payet on 21/06/2024.
//

import Fluent

extension Treatment {
    enum V20240618 {
        static let schemaName = "treatments"

        static let id = FieldKey(stringLiteral: "id")
        static let date = FieldKey(stringLiteral: "date")
        static let dicomID = FieldKey(stringLiteral: "dicomID")
        static let patientID = FieldKey(stringLiteral: "patientID")
        static let model3Ds = FieldKey(stringLiteral: "model3Ds")

        static let affectedBoneEnum = FieldKey(stringLiteral: "affectedBoneEnum")
        static let affectedBone = "affectedBone"
        static let mandible = "mandible"
        static let maxillary = "maxillary"
        static let both = "both"
    }
}
