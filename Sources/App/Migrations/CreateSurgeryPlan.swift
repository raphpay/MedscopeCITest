//
//  CreateSurgeryPlan.swift
//
//
//  Created by Raphaël Payet on 21/06/2024.
//

import Foundation
import Fluent

struct CreateSurgeryPlan: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(SurgeryPlan.V20240618.schemaName)
            .id()
            .field(SurgeryPlan.V20240618.medscopeID, .string, .required)
            .field(SurgeryPlan.V20240618.naturalTeeth, .array(of: .int32), .required)
            .field(SurgeryPlan.V20240618.artificialTeeth, .array(of: .int32), .required)
            .field(SurgeryPlan.V20240618.position, .array(of: .int32), .required)
            .field(SurgeryPlan.V20240618.center, .array(of: .array(of: .float)), .required)
            .field(SurgeryPlan.V20240618.apex, .array(of: .array(of: .float)), .required)
            .field(SurgeryPlan.V20240618.upIndex, .array(of: .array(of: .float)), .required)
            .field(SurgeryPlan.V20240618.implantsReference, .array(of: .string), .required)
            .field(SurgeryPlan.V20240618.implantsModels, .uuid, .required)
            .field(SurgeryPlan.V20240618.surgeryReport, .array(of: .uuid), .required)
            .field(SurgeryPlan.V20240618.loadingProtocol, .string)
            .field(SurgeryPlan.V20240618.densityScale, .array(of: .float))
            .field(SurgeryPlan.V20240618.boneStressScale, .array(of: .float))
            .field(SurgeryPlan.V20240618.implantStresScale, .array(of: .float))
            .field(SurgeryPlan.V20240618.messagesBoneStress, .array(of: .string))
            .field(SurgeryPlan.V20240618.messagesImplantStress, .array(of: .string))
            .field(SurgeryPlan.V20240618.messagesDensity, .array(of: .string))
            .field(SurgeryPlan.V20240618.scoresBoneStress, .array(of: .int))
            .field(SurgeryPlan.V20240618.scoresImplantStress, .array(of: .int))
            .field(SurgeryPlan.V20240618.scoresDensity, .array(of: .int))
            .field(SurgeryPlan.V20240618.imagesBoneStress, .array(of: .custom(Document.IDValue.self)))
            .field(SurgeryPlan.V20240618.imagesImplantStress, .array(of: .custom(Document.IDValue.self)))
            .field(SurgeryPlan.V20240618.imagesDensity, .array(of: .custom(Document.IDValue.self)))
            .field(SurgeryPlan.V20240618.imagesBoneQualityPercentage,
				.array(of: .custom(Document.IDValue.self)))
            .field(SurgeryPlan.V20240618.imagesEstimatedBoneType, .array(of: .custom(Document.IDValue.self)))
            .field(SurgeryPlan.V20240618.imagesRadio, .array(of: .custom(Document.IDValue.self)))
            .field(SurgeryPlan.V20240618.imagesDrillingProfile, .array(of: .custom(Document.IDValue.self)))
            .field(SurgeryPlan.V20240618.estimatedCorticalThickness, .float)
            .field(SurgeryPlan.V20240618.estimatedTrabecularDensity, .float)
            .field(SurgeryPlan.V20240618.estimatedCrestalThickness, .float)
            .field(SurgeryPlan.V20240919.resultsBoneStress, .array(of: .uuid))
            .field(SurgeryPlan.V20240919.resultsImplantStress, .array(of: .uuid))
            .field(SurgeryPlan.V20240919.resultsDensity, .array(of: .uuid))
            .field(SurgeryPlan.V20240923.otherResults, .uuid)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(SurgeryPlan.V20240618.schemaName)
            .delete()
    }
}
