//
//  SurgeryPlan+FieldKeys.swift
//
//
//  Created by Raphaël Payet on 24/06/2024.
//

import Fluent

extension SurgeryPlan {
    enum V20240618 {
        static let schemaName = "surgeryPlans"

        static let id = FieldKey(stringLiteral: "id")
        // Mandatory
        static let medscopeID = FieldKey(stringLiteral: "medscopeID")
        static let naturalTeeth = FieldKey(stringLiteral: "naturalTeeth")
        static let artificialTeeth = FieldKey(stringLiteral: "artificialTeeth")
        static let position = FieldKey(stringLiteral: "position")
        static let center = FieldKey(stringLiteral: "center")
        static let apex = FieldKey(stringLiteral: "apex")
        static let upIndex = FieldKey(stringLiteral: "upIndex")
        static let implantsReference = FieldKey(stringLiteral: "implantsReference")
        static let implantsModels = FieldKey(stringLiteral: "implantsModels")
        static let surgeryReport = FieldKey(stringLiteral: "surgeryReport")
        // Optional
        static let mandibleFileID = FieldKey(stringLiteral: "mandibleFileID")
        static let maxillaryFileID = FieldKey(stringLiteral: "maxillaryFileID")
        static let loadingProtocol = FieldKey(stringLiteral: "loadingProtocol")
        static let densityScale = FieldKey(stringLiteral: "densityScale")
        static let boneStressScale = FieldKey(stringLiteral: "boneStressScale")
        static let implantStresScale = FieldKey(stringLiteral: "implantStresScale")
        static let messagesBoneStress = FieldKey(stringLiteral: "messagesBoneStress")
        static let messagesImplantStress = FieldKey(stringLiteral: "messagesImplantStress")
        static let messagesDensity = FieldKey(stringLiteral: "messagesDensity")
        static let scoresBoneStress = FieldKey(stringLiteral: "scoresBoneStress")
        static let scoresImplantStress = FieldKey(stringLiteral: "scoresImplantStress")
        static let scoresDensity = FieldKey(stringLiteral: "scoresDensity")
        static let imagesBoneStress = FieldKey(stringLiteral: "imagesBoneStress")
        static let imagesImplantStress = FieldKey(stringLiteral: "imagesImplantStress")
        static let imagesDensity = FieldKey(stringLiteral: "imagesDensity")
        static let imagesBoneQualityPercentage = FieldKey(stringLiteral: "imagesBoneQualityPercentage")
        static let imagesEstimatedBoneType = FieldKey(stringLiteral: "imagesEstimatedBoneType")
        static let imagesRadio = FieldKey(stringLiteral: "imagesRadio")
        static let imagesDrillingProfile = FieldKey(stringLiteral: "imagesDrillingProfile")
        static let estimatedCorticalThickness = FieldKey(stringLiteral: "estimatedCorticalThickness")
        static let estimatedTrabecularDensity = FieldKey(stringLiteral: "estimatedTrabecularDensity")
        static let estimatedCrestalThickness = FieldKey(stringLiteral: "estimatedCrestalThickness")
        static let finalReport = FieldKey(stringLiteral: "finalReport")
        static let surgeryGuide = FieldKey(stringLiteral: "surgeryGuide")
        // Relation
        static let treatmentID = FieldKey(stringLiteral: "treatmentID")
    }

    enum V20240919 {
        static let resultsBoneStress = FieldKey(stringLiteral: "resultsBoneStress")
        static let resultsImplantStress = FieldKey(stringLiteral: "resultsImplantStress")
        static let resultsDensity = FieldKey(stringLiteral: "resultsDensity")
    }

    enum V20240923 {
        static let otherResults = FieldKey(stringLiteral: "otherResults")
    }

    enum V20250306 {
        static let isTreated = FieldKey(stringLiteral: "isTreated")
    }

    enum V20250314 {
        static let depth = FieldKey(stringLiteral: "depth")
    }
}
