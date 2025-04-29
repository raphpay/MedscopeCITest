//
//  TreatmentFollowUp+FieldKeys.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

import Fluent

extension TreatmentFollowUp {
    enum V20240618 {
        static let schemaName = "treatmentFollowUps"

        static let id = FieldKey(stringLiteral: "id")
        // Mandatory
        static let creationDate = FieldKey(stringLiteral: "creationDate")
        static let treatmentID = FieldKey(stringLiteral: "treatmentID")
        static let status = FieldKey(stringLiteral: "status")
        // Optional
        static let calculationDate = FieldKey(stringLiteral: "calculationDate")
        static let operatorID = FieldKey(stringLiteral: "operatorID")
        static let validationDate = FieldKey(stringLiteral: "validationDate")
        static let validatorID = FieldKey(stringLiteral: "validatorID")
        static let firstOpenDate = FieldKey(stringLiteral: "firstOpenDate")
        static let versionInterface = FieldKey(stringLiteral: "versionInterface")
        static let versionCalculator = FieldKey(stringLiteral: "versionCalculator")
        static let versionSP = FieldKey(stringLiteral: "versionSP")
        static let versionAPI = FieldKey(stringLiteral: "versionAPI")
    }
}
