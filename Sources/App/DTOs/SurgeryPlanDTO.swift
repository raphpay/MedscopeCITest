//
//  SurgeryPlanDTO.swift
//
//
//  Created by Raphaël Payet on 21/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

// MARK: - Input
extension SurgeryPlan {
	/// Input for creating a new SurgeryPlan
	/// - Note: This structure is used to represent the input for creating a new SurgeryPlan.
	///    The `toModel` function converts the input to a `SurgeryPlan` model.
	struct Input: Content, WithExample {
		// Mandatory
		let naturalTeeth: [Int]
		let artificialTeeth: [Int]
		let position: [Int]
		let center: [[Float]]
		let apex: [[Float]]
		let upIndex: [[Float]]
		let implantsReference: [String]
		let surgeryReport: [Document.IDValue]
		let isTreated: Bool?
		let depth: [Float]?
		// Optional
		let implantsModels: Document.IDValue?
		let loadingProtocol: String?
		let imagesBoneStress: [Document.IDValue]?
		let imagesImplantStress: [Document.IDValue]?
		let imagesDensity: [Document.IDValue]?
		let finalReport: Document.IDValue?
		let surgeryGuide: Document.IDValue?
		let resultsBoneStress: [Document.IDValue]?
		let resultsImplantStress: [Document.IDValue]?
		let resultsDensity: [Document.IDValue]?
		let otherResults: Document.IDValue?
		// Relation
		let treatmentID: Treatment.IDValue

		/// Convert the input to a model
		/// - Returns: A `SurgeryPlan` model representing the input
		/// - Parameters:
		///   - medscopeID: The ID of the Medscope
		func toModel(_ medscopeID: String) -> SurgeryPlan {
			.init(
				medscopeID: medscopeID,
				naturalTeeth: naturalTeeth,
				artificialTeeth: artificialTeeth,
				position: position,
				center: center,
				apex: apex,
				upIndex: upIndex,
				implantsReference: implantsReference,
				surgeryReport: surgeryReport,
				isTreated: isTreated ?? false,
				depth: depth ?? [],
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
				treatmentID: treatmentID
			)
		}

		static var example: SurgeryPlan.Input {
		  .init(naturalTeeth: [1, 2],
			  artificialTeeth: [3, 4],
			  position: [5, 6],
			  center: [[3.89, 90], [36.2, 98]],
			  apex: [[3.89, 90], [36.2, 98]],
			  upIndex: [[3.89, 90], [36.2, 98]],
			  implantsReference: ["K3601", "K2517"],
			  surgeryReport: [UUID()],
			  isTreated: false,
			  depth: [3.89, 90],
			  implantsModels: UUID(),
			  loadingProtocol: nil,
			  imagesBoneStress: [UUID()],
			  imagesImplantStress: [UUID()],
			  imagesDensity: [UUID()],
			  finalReport: UUID(),
			  surgeryGuide: UUID(),
			  resultsBoneStress: [UUID()],
			  resultsImplantStress: [UUID()],
			  resultsDensity: [UUID()],
			  otherResults: UUID(),
			  treatmentID: UUID())
		}
	}
}

// MARK: FormInput
extension SurgeryPlan {
  /// Input for creating a new SurgeryPlan via a form
	struct FormInput: Content, WithExample {
		// Mandatory
		let naturalTeeth: [Int]
		let artificialTeeth: [Int]
		let position: [Int]
		let center: [[Float]]
		let apex: [[Float]]
		let upIndex: [[Float]]
		let implantsReference: [String]
		let surgeryReport: [Document.IDValue]
		var isTreated: Bool? = false
		let depth: [Float]?
		// Optional
		let implantsModels: Document.IDValue?
		let loadingProtocol: String?
		let imagesBoneStress: [Document.IDValue]?
		let imagesImplantStress: [Document.IDValue]?
		let imagesDensity: [Document.IDValue]?

		let finalReport: Document.IDValue?
		let surgeryGuide: Document.IDValue?
		let resultsBoneStress: [Document.IDValue]?
		let resultsImplantStress: [Document.IDValue]?
		let resultsDensity: [Document.IDValue]?
		let otherResults: Document.IDValue?

		static var example: SurgeryPlan.FormInput {
			.init(naturalTeeth: [1, 2],
				artificialTeeth: [3, 4],
				position: [5, 6],
				center: [[3.89, 90], [36.2, 98]],
				apex: [[3.89, 90], [36.2, 98]],
				upIndex: [[3.89, 90], [36.2, 98]],
				implantsReference: ["K3601", "K2517"],
				surgeryReport: [UUID()],
				isTreated: false,
				depth: [3.89, 90],
				implantsModels: UUID(),
				loadingProtocol: nil,
				imagesBoneStress: [UUID()],
				imagesImplantStress: [UUID()],
				imagesDensity: [UUID()],
				finalReport: UUID(),
				surgeryGuide: UUID(),
				resultsBoneStress: [UUID()],
				resultsImplantStress: [UUID()],
				resultsDensity: [UUID()],
				otherResults: UUID())
		}
	}
}

// MARK: - UpdateInput
extension SurgeryPlan {
	/// Input for updating an existing SurgeryPlan
	/// - Note: This structure is used to represent the input for updating an existing SurgeryPlan.
	///    The `update` function updates the SurgeryPlan with the provided values.
	struct UpdateInput: Content {
		// Mandatory in initial Input
		let naturalTeeth: [Int]?
		let artificialTeeth: [Int]?
		let position: [Int]?
		let center: [[Float]]?
		let apex: [[Float]]?
		let upIndex: [[Float]]?
		let implantsReference: [String]?
		let surgeryReport: [Document.IDValue]?
		var isTreated: Bool? = false
		let depth: [Float]?
		// Optional in initial Input
		let implantsModels: Document.IDValue?
		let loadingProtocol: String?
		let imagesBoneStress: [Document.IDValue]?
		let imagesImplantStress: [Document.IDValue]?
		let imagesDensity: [Document.IDValue]?
		let finalReport: Document.IDValue?
		let surgeryGuide: Document.IDValue?
		let resultsBoneStress: [Document.IDValue]?
		let resultsImplantStress: [Document.IDValue]?
		let resultsDensity: [Document.IDValue]?
		let otherResults: Document.IDValue?

		/// Update the SurgeryPlan with the provided values
		/// - Parameter surgeryPlan: The SurgeryPlan to update
		/// - Returns: An updated `SurgeryPlan` model
		/// - Note: This function updates the SurgeryPlan with the provided values.
		///    If a value is `nil`, it will not be updated.
		func update(_ surgeryPlan: SurgeryPlan) async throws -> SurgeryPlan {
			let updatedSurgeryPlan = surgeryPlan

			applyIfPresent(naturalTeeth) { updatedSurgeryPlan.naturalTeeth = $0 }
			applyIfPresent(artificialTeeth) { updatedSurgeryPlan.artificialTeeth = $0 }
			applyIfPresent(position) { updatedSurgeryPlan.position = $0 }
			applyIfPresent(center) { updatedSurgeryPlan.center = $0 }
			applyIfPresent(apex) { updatedSurgeryPlan.apex = $0 }
			applyIfPresent(upIndex) { updatedSurgeryPlan.upIndex = $0 }
			applyIfPresent(implantsReference) { updatedSurgeryPlan.implantsReference = $0 }
			applyIfPresent(implantsModels) { updatedSurgeryPlan.implantsModels = $0 }
			applyIfPresent(surgeryReport) { updatedSurgeryPlan.surgeryReport = $0 }
			applyIfPresent(isTreated) { updatedSurgeryPlan.isTreated = $0 }
			applyIfPresent(loadingProtocol) { updatedSurgeryPlan.loadingProtocol = $0 }
			applyIfPresent(imagesBoneStress) { updatedSurgeryPlan.imagesBoneStress = $0 }
			applyIfPresent(imagesImplantStress) { updatedSurgeryPlan.imagesImplantStress = $0 }
			applyIfPresent(imagesDensity) { updatedSurgeryPlan.imagesDensity = $0 }
			applyIfPresent(finalReport) { updatedSurgeryPlan.finalReport = $0 }
			applyIfPresent(surgeryGuide) { updatedSurgeryPlan.surgeryGuide = $0 }
			applyIfPresent(resultsBoneStress) { updatedSurgeryPlan.resultsBoneStress = $0 }
			applyIfPresent(resultsImplantStress) { updatedSurgeryPlan.resultsImplantStress = $0 }
			applyIfPresent(resultsDensity) { updatedSurgeryPlan.resultsDensity = $0 }
			applyIfPresent(otherResults) { updatedSurgeryPlan.otherResults = $0 }
			applyIfPresent(depth) { updatedSurgeryPlan.depth = $0 }

			return updatedSurgeryPlan
		}

		private func applyIfPresent<T>(_ value: T?, _ apply: (T) -> Void) {
			if let value = value {
				apply(value)
			}
		}

		static var example: SurgeryPlan.UpdateInput {
			.init(naturalTeeth: [1, 2],
				  artificialTeeth: [3, 4],
				  position: [5, 6],
				  center: [[3.89, 90], [36.2, 98]],
				  apex: [[3.89, 90], [36.2, 98]],
				  upIndex: [[3.89, 90], [36.2, 98]],
				  implantsReference: ["K3601", "K2517"],
				  surgeryReport: [UUID()],
				  isTreated: false,
				  depth: [3.89, 90],
				  implantsModels: UUID(),
				  loadingProtocol: nil,
				  imagesBoneStress: [UUID()],
				  imagesImplantStress: [UUID()],
				  imagesDensity: [UUID()],
				  finalReport: UUID(),
				  surgeryGuide: UUID(),
				  resultsBoneStress: [UUID()],
				  resultsImplantStress: [UUID()],
				  resultsDensity: [UUID()],
				  otherResults: UUID()
			)
		}
	}
}

// MARK: - Output
extension SurgeryPlan {
	/// Output structure for returning a `SurgeryPlan` model.
	///
	/// This structure is used to return a complete and serialized representation of a `SurgeryPlan` to clients.
	/// It includes all relevant data fields and identifiers, including relations to documents and treatments.
	/// Conforms to `Content` and `WithExample` for use in API responses and OpenAPI documentation.
	struct Output: Content, WithExample {
		let id: UUID?
		// Mandatory
		let medscopeID: String
		let naturalTeeth: [Int]
		let artificialTeeth: [Int]
		let position: [Int]
		let center: [[Float]]
		let apex: [[Float]]
		let upIndex: [[Float]]
		let implantsReference: [String]
		let surgeryReport: [Document.IDValue]
		let isTreated: Bool?
		let depth: [Float]?
		// Optional
		let implantsModels: Document.IDValue?
		let loadingProtocol: String?
		let imagesBoneStress: [Document.IDValue]?
		let imagesImplantStress: [Document.IDValue]?
		let imagesDensity: [Document.IDValue]?
		let finalReport: Document.IDValue?
		let surgeryGuide: Document.IDValue?
		let resultsBoneStress: [Document.IDValue]?
		let resultsImplantStress: [Document.IDValue]?
		let resultsDensity: [Document.IDValue]?
		let otherResults: Document.IDValue?
		// Relation
		let treatmentID: Treatment.IDValue

		static var example: SurgeryPlan.Output {
			.init(id: UUID(),
				  medscopeID: "PLAN00000235",
				  naturalTeeth: [1, 2],
				  artificialTeeth: [3, 4],
				  position: [5, 6],
				  center: [[3.89, 90], [36.2, 98]],
				  apex: [[3.89, 90], [36.2, 98]],
				  upIndex: [[3.89, 90], [36.2, 98]],
				  implantsReference: ["K3601", "K2517"],
				  surgeryReport: [UUID()],
				  isTreated: false,
				  depth: [3.89, 90],
				  implantsModels: UUID(),
				  loadingProtocol: nil,
				  imagesBoneStress: [UUID()],
				  imagesImplantStress: [UUID()],
				  imagesDensity: [UUID()],
				  finalReport: UUID(),
				  surgeryGuide: UUID(),
				  resultsBoneStress: [UUID()],
				  resultsImplantStress: [UUID()],
				  resultsDensity: [UUID()],
				  otherResults: UUID(),
				  treatmentID: UUID())
		}
	}
}
