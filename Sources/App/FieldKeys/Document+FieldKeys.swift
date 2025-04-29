//
//  Document+FieldKeys.swift
//  
//
//  Created by Raphaël Payet on 21/06/2024.
//

import Fluent

extension Document {
    enum V20240618 {
        static let schemaName = "documents"

        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let path = FieldKey(stringLiteral: "firstName")
        static let updatedAt = FieldKey(stringLiteral: "updatedAt")
        static let treatmentID = FieldKey(stringLiteral: "treatmentID")
        static let surgeryPlanID = FieldKey(stringLiteral: "surgeryPlanID")
        static let mandibleFileID = FieldKey(stringLiteral: "mandibleFileID")
        static let maxillaryFileID = FieldKey(stringLiteral: "maxillaryFileID")
        static let reportFileID = FieldKey(stringLiteral: "reportFileID")
        static let modelFileID = FieldKey(stringLiteral: "modelFileID")
    }
}
