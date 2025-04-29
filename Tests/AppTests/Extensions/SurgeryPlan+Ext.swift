//
//  SurgeryPlan+Ext.swift
//
//
//  Created by Raphaël Payet on 25/07/2024.
//

@testable import App
import XCTVapor
import Fluent

extension SurgeryPlanControllerTests {
    /// Create a new surgery plan
    /// - Parameters:
    ///  - treatmentID: The treatment ID of the surgery plan
    /// - implantsReference: The implants reference of the surgery plan
    /// - implantsModels: The implants models of the surgery plan
    /// - surgeryReport: The surgery report of the surgery plan
    /// - imagesBoneStress: The images bone stress of the surgery plan
    /// - imagesImplantsStress: The images implants stress of the surgery plan
    /// - imagesDensity: The images density of the surgery plan
    /// - finalReport: The final report of the surgery plan
    /// - surgeryGuide: The surgery guide of the surgery plan
    /// - resultsBoneStress: The results bone stress of the surgery plan
    /// - resultsImplantStress: The results implant stress of the surgery plan
    /// - resultsDensity: The results density of the surgery plan
    /// - save: A boolean indicating whether to save the surgery plan
    /// - db: The database connection to use for the creation
    /// - Returns: The created surgery plan
    /// - Throws: An error if the surgery plan creation fails
    func createExpectedSurgeryPlan(with treatmentID: Treatment.IDValue,
                                   implantsReference: [String] = [],
                                   implantsModels: Document.IDValue = UUID(),
                                   surgeryReport: [Document.IDValue] = [UUID()],
                                   imagesBoneStress: [Document.IDValue] = [UUID()],
                                   imagesImplantsStress: [Document.IDValue] = [UUID()],
                                   imagesDensity: [Document.IDValue] = [UUID()],
                                   finalReport: Document.IDValue = UUID(),
                                   surgeryGuide: Document.IDValue = UUID(),
                                   resultsBoneStress: [Document.IDValue] = [UUID()],
                                   resultsImplantStress: [Document.IDValue] = [UUID()],
                                   resultsDensity: [Document.IDValue] = [UUID()],
                                   save: Bool = true,
                                   on db: Database
    ) async throws -> SurgeryPlan {
		let surgeryPlan = SurgeryPlan(medscopeID: expectedMedscopeID,
									  naturalTeeth: expectedNaturalTeeth,
									  artificialTeeth: expectedArtificialTeeth,
									  position: expectedPosition,
									  center: expectedCenter,
									  apex: expectedApex,
									  upIndex: expectedUpIndex,
									  implantsReference: implantsReference,
									  surgeryReport: surgeryReport,
									  isTreated: expectedIsTreated,
									  depth: expectedDepth,
									  implantsModels: implantsModels,
									  loadingProtocol: expectedLoadingProtocol,
									  imagesBoneStress: imagesBoneStress,
									  imagesImplantStress: imagesImplantsStress,
									  imagesDensity: imagesDensity,
									  finalReport: finalReport,
									  surgeryGuide: surgeryGuide,
									  resultsBoneStress: resultsBoneStress,
									  resultsImplantStress: resultsImplantStress,
									  resultsDensity: resultsDensity,
									  otherResults: nil,
									  treatmentID: treatmentID)

        if save == true {
            try await surgeryPlan.save(on: db)
        } else {
            surgeryPlan.id = UUID()
        }
        return surgeryPlan
    }

    /// Create a new surgery plan
    /// - Parameters:
    /// - treatmentID: The treatment ID of the surgery plan
    /// - implantsReference: The implants reference of the surgery plan
    /// - implantsModels: The implants models of the surgery plan
    /// - surgeryReport: The surgery report of the surgery plan
    /// - imagesBoneStress: The images bone stress of the surgery plan
    /// - imagesImplantsStress: The images implants stress of the surgery plan
    /// - imagesDensity: The images density of the surgery plan
    /// - finalReport: The final report of the surgery plan
    /// - surgeryGuide: The surgery guide of the surgery plan
    /// - resultsBoneStress: The results bone stress of the surgery plan
    /// - resultsImplantStress: The results implant stress of the surgery plan
    /// - resultsDensity: The results density of the surgery plan
    /// - save: A boolean indicating whether to save the surgery plan
    /// - db: The database connection to use for the creation
    /// - Returns: The created surgery plan
    /// - Throws: An error if the surgery plan creation fails
    func createImplant(with surgeryPlanID: SurgeryPlan.IDValue, on db: Database) async throws -> Implant {
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let input = Implant.Input(reference: implantExpectedReference,
                                  internalDiam: expectedInternalDiam,
                                  abutmentContactHeight: expectedAbutmentContactHeight,
                                  diameter: expectedDiameter,
                                  hneck: expectedHneck,
                                  length: expectedLength,
                                  matName: expectedMatName,
                                  upCenter: expectedUpCenter,
                                  centerZ: expectedCenterZ,
                                  upIndex: expectedUpIndexImplant,
                                  modelID: documentID)
        let implant = input.toModel()
        try await implant.save(on: app.db)
        return implant
    }

    /// Create a new surgery plan
    /// - Parameters:
    /// - implantsModels: The implants models of the surgery plan
    /// - surgeryReport: The surgery report of the surgery plan
    /// - imagesBoneStress: The images bone stress of the surgery plan
    /// - imagesImplantsStress: The images implants stress of the surgery plan
    /// - imagesDensity: The images density of the surgery plan
    /// - finalReport: The final report of the surgery plan
    /// - surgeryGuide: The surgery guide of the surgery plan
    /// - resultsBoneStress: The results bone stress of the surgery plan
    /// - resultsImplantStress: The results implant stress of the surgery plan
    /// - resultsDensity: The results density of the surgery plan
    /// - otherResults: The other results of the surgery plan
    /// - db: The database connection to use for the creation
    /// - Returns: The created surgery plan
    /// - Throws: An error if the surgery plan creation fails
    func createExpectedSurgeryPlanFormInput(
        implantsModels: Document.IDValue = UUID(),
        surgeryReport: [Document.IDValue] = [UUID()],
        finalReport: Document.IDValue = UUID(),
        surgeryGuide: Document.IDValue = UUID(),
        resultsBoneStress: [Document.IDValue] = [UUID()],
        resultsImplantStress: [Document.IDValue] = [UUID()],
        resultsDensity: [Document.IDValue] = [UUID()],
        otherResults: Document.IDValue = UUID()
    ) -> SurgeryPlan.FormInput {
        .init(naturalTeeth: expectedNaturalTeeth,
              artificialTeeth: expectedArtificialTeeth,
              position: expectedPosition,
              center: expectedCenter,
              apex: expectedApex,
              upIndex: expectedUpIndex,
              implantsReference: expectedImplantsReference,
              surgeryReport: surgeryReport,
              depth: expectedDepth,
              implantsModels: implantsModels,
              loadingProtocol: expectedLoadingProtocol,
              imagesBoneStress: expectedImagesBoneStress,
              imagesImplantStress: expectedImagesImplantStress,
              imagesDensity: expectedImagesDensity,
              finalReport: finalReport,
              surgeryGuide: surgeryGuide,
              resultsBoneStress: resultsBoneStress,
              resultsImplantStress: resultsImplantStress,
              resultsDensity: resultsDensity,
              otherResults: otherResults)
    }
}
