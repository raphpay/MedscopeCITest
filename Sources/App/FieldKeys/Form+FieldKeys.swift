//
//  Form+FieldKeys.swift
//
//
//  Created by Raphaël Payet on 31/07/2024.
//

import Fluent

extension Form {
    enum V20240618 {
        static let schemaName = "forms"

        static let id = FieldKey(stringLiteral: "id")
        static let user = FieldKey(stringLiteral: "user")
        static let patient = FieldKey(stringLiteral: "patient")
        static let treatment = FieldKey(stringLiteral: "treatment")
        static let surgeryPlans = FieldKey(stringLiteral: "surgeryPlans")
        static let treatmentDicomID = FieldKey(stringLiteral: "treatmentDicomID")
    }
}
