//
//  CreateTreatmentFollowUp.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

import Foundation
import Fluent

struct CreateTreatmentFollowUp: AsyncMigration {
    func prepare(on database: Database) async throws {

        try await database
            .schema(TreatmentFollowUp.V20240618.schemaName)
            .id()
            .field(TreatmentFollowUp.V20240618.creationDate, .string, .required)
            .field(TreatmentFollowUp.V20240618.treatmentID, .uuid, .required)
            .field(TreatmentFollowUp.V20240618.status, .string, .required)
            .field(TreatmentFollowUp.V20240618.calculationDate, .string)
            .field(TreatmentFollowUp.V20240618.operatorID, .uuid)
            .field(TreatmentFollowUp.V20240618.validationDate, .string)
            .field(TreatmentFollowUp.V20240618.validatorID, .uuid)
            .field(TreatmentFollowUp.V20240618.firstOpenDate, .string)
            .field(TreatmentFollowUp.V20240618.versionInterface, .string)
            .field(TreatmentFollowUp.V20240618.versionCalculator, .string)
            .field(TreatmentFollowUp.V20240618.versionSP, .string)
            .field(TreatmentFollowUp.V20240618.versionAPI, .string)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(TreatmentFollowUp.V20240618.schemaName)
            .delete()
    }
}
