//
//  RemoveSurgeryPlanParameters.swift
//  Medscope
//
//  Created by Raphaël Payet on 06/03/2025.
//

import Foundation
import Fluent

struct RemoveSurgeryPlanParameters: AsyncMigration {
    func prepare(on database: Database) async throws {
        // Add the new fields to the User schema
        try await database.schema(SurgeryPlan.V20240618.schemaName)
            .deleteField(SurgeryPlan.V20240618.densityScale)
            .deleteField(SurgeryPlan.V20240618.boneStressScale)
            .deleteField(SurgeryPlan.V20240618.implantStresScale)
            .deleteField(SurgeryPlan.V20240618.messagesBoneStress)
            .deleteField(SurgeryPlan.V20240618.messagesImplantStress)
            .deleteField(SurgeryPlan.V20240618.messagesDensity)
            .deleteField(SurgeryPlan.V20240618.scoresBoneStress)
            .deleteField(SurgeryPlan.V20240618.scoresImplantStress)
            .deleteField(SurgeryPlan.V20240618.scoresDensity)
            .deleteField(SurgeryPlan.V20240618.estimatedCorticalThickness)
            .deleteField(SurgeryPlan.V20240618.estimatedTrabecularDensity)
            .deleteField(SurgeryPlan.V20240618.estimatedCrestalThickness)
            .deleteField(SurgeryPlan.V20240618.imagesBoneQualityPercentage)
            .field(SurgeryPlan.V20240618.imagesEstimatedBoneType, .string)
            .field(SurgeryPlan.V20240618.imagesRadio, .string)
            .field(SurgeryPlan.V20240618.imagesDrillingProfile, .string)
            .update()
    }

    func revert(on database: Database) async throws {
        // Remove the fields in case of rollback
        try await database.schema(SurgeryPlan.V20240618.schemaName)
            .field(SurgeryPlan.V20240618.densityScale, .string)
            .field(SurgeryPlan.V20240618.boneStressScale, .string)
            .field(SurgeryPlan.V20240618.implantStresScale, .string)
            .field(SurgeryPlan.V20240618.messagesBoneStress, .string)
            .field(SurgeryPlan.V20240618.messagesImplantStress, .string)
            .field(SurgeryPlan.V20240618.messagesDensity, .string)
            .field(SurgeryPlan.V20240618.scoresBoneStress, .string)
            .field(SurgeryPlan.V20240618.scoresImplantStress, .string)
            .field(SurgeryPlan.V20240618.scoresDensity, .string)
            .field(SurgeryPlan.V20240618.estimatedCorticalThickness, .string)
            .field(SurgeryPlan.V20240618.estimatedTrabecularDensity, .string)
            .field(SurgeryPlan.V20240618.estimatedCrestalThickness, .string)
            .field(SurgeryPlan.V20240618.imagesBoneQualityPercentage, .string)
            .deleteField(SurgeryPlan.V20240618.imagesEstimatedBoneType)
            .deleteField(SurgeryPlan.V20240618.imagesRadio)
            .deleteField(SurgeryPlan.V20240618.imagesDrillingProfile)
            .update()
    }
}
