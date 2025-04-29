//
//  SurgeryPlan.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Fluent
import Vapor

final class SurgeryPlan: Model, Content, @unchecked Sendable {
    static let schema = SurgeryPlan.V20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: SurgeryPlan.V20240618.medscopeID)
    var medscopeID: String

    @Field(key: SurgeryPlan.V20240618.naturalTeeth)
    var naturalTeeth: [Int]

    @Field(key: SurgeryPlan.V20240618.artificialTeeth)
    var artificialTeeth: [Int]

    @Field(key: SurgeryPlan.V20240618.position)
    var position: [Int]

    @Field(key: SurgeryPlan.V20240618.center)
    var center: [[Float]]

    @Field(key: SurgeryPlan.V20240618.apex)
    var apex: [[Float]]

    @Field(key: SurgeryPlan.V20240618.upIndex)
    var upIndex: [[Float]]

    @Field(key: SurgeryPlan.V20240618.implantsReference)
    var implantsReference: [String]

    @Field(key: SurgeryPlan.V20240618.surgeryReport)
    var surgeryReport: [Document.IDValue]

    @Field(key: SurgeryPlan.V20250306.isTreated)
    var isTreated: Bool

    @Field(key: SurgeryPlan.V20250314.depth)
    var depth: [Float]

    @OptionalField(key: SurgeryPlan.V20240618.implantsModels)
    var implantsModels: Document.IDValue?

    @OptionalField(key: SurgeryPlan.V20240618.loadingProtocol)
    var loadingProtocol: String?

    @OptionalField(key: SurgeryPlan.V20240618.imagesBoneStress)
    var imagesBoneStress: [Document.IDValue]?

    @OptionalField(key: SurgeryPlan.V20240618.imagesImplantStress)
    var imagesImplantStress: [Document.IDValue]?

    @OptionalField(key: SurgeryPlan.V20240618.imagesDensity)
    var imagesDensity: [Document.IDValue]?

    @OptionalField(key: SurgeryPlan.V20240618.finalReport)
    var finalReport: Document.IDValue?

    @OptionalField(key: SurgeryPlan.V20240618.surgeryGuide)
    var surgeryGuide: Document.IDValue?

    @OptionalField(key: SurgeryPlan.V20240919.resultsBoneStress)
    var resultsBoneStress: [Document.IDValue]?

    @OptionalField(key: SurgeryPlan.V20240919.resultsImplantStress)
    var resultsImplantStress: [Document.IDValue]?

    @OptionalField(key: SurgeryPlan.V20240919.resultsDensity)
    var resultsDensity: [Document.IDValue]?

    @OptionalField(key: SurgeryPlan.V20240923.otherResults)
    var otherResults: Document.IDValue?

    @Parent(key: SurgeryPlan.V20240618.treatmentID)
    var treatment: Treatment

    init() { }

	init(
		id: UUID? = nil,
		medscopeID: String,
		naturalTeeth: [Int],
		artificialTeeth: [Int],
		position: [Int],
		center: [[Float]],
		apex: [[Float]],
		upIndex: [[Float]],
		implantsReference: [String],
		surgeryReport: [Document.IDValue],
		isTreated: Bool,
		depth: [Float],
		implantsModels: Document.IDValue? = nil,
		loadingProtocol: String? = nil,
		imagesBoneStress: [Document.IDValue]? = nil,
		imagesImplantStress: [Document.IDValue]? = nil,
		imagesDensity: [Document.IDValue]? = nil,
		finalReport: Document.IDValue? = nil,
		surgeryGuide: Document.IDValue? = nil,
		resultsBoneStress: [Document.IDValue]? = nil,
		resultsImplantStress: [Document.IDValue]? = nil,
		resultsDensity: [Document.IDValue]? = nil,
		otherResults: Document.IDValue? = nil,
		treatmentID: Treatment.IDValue
	) {
		self.id = id
		// Mandatory
		self.medscopeID = medscopeID
		self.naturalTeeth = naturalTeeth
		self.artificialTeeth = artificialTeeth
		self.position = position
		self.center = center
		self.apex = apex
		self.upIndex = upIndex
		self.implantsReference = implantsReference
		self.surgeryReport = surgeryReport
		self.$treatment.id = treatmentID
		// 2025/03
		self.isTreated = isTreated
		self.depth = depth
		// Optional
		self.implantsModels = implantsModels
		self.loadingProtocol = loadingProtocol
		self.imagesBoneStress = imagesBoneStress
		self.imagesImplantStress = imagesImplantStress
		self.imagesDensity = imagesDensity
		self.finalReport = finalReport
		self.surgeryGuide = surgeryGuide
		self.resultsBoneStress = resultsBoneStress
		self.resultsImplantStress = resultsImplantStress
		self.resultsDensity = resultsDensity
		self.otherResults = otherResults
	}

	func toOutput() -> SurgeryPlan.Output {
		.init(id: id,
			  medscopeID: medscopeID,
			  naturalTeeth: naturalTeeth,
			  artificialTeeth: artificialTeeth,
			  position: position,
			  center: center,
			  apex: apex,
			  upIndex: upIndex,
			  implantsReference: implantsReference,
			  surgeryReport: surgeryReport,
			  isTreated: isTreated,
			  depth: depth,
			  implantsModels: implantsModels,
			  loadingProtocol: loadingProtocol,
			  imagesBoneStress: imagesBoneStress,
			  imagesImplantStress: imagesImplantStress,
			  imagesDensity: imagesDensity,
			  finalReport: finalReport,
			  surgeryGuide: surgeryGuide,
			  resultsBoneStress: resultsBoneStress,
			  resultsImplantStress: resultsImplantStress,
			  resultsDensity: resultsDensity,
			  otherResults: otherResults,
			  treatmentID: $treatment.id)
	}
}
