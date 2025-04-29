//
//  TreatmentDTO.swift
//
//
//  Created by Raphaël Payet on 21/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

extension Treatment {
	/// Input for creating a new Treatment
	/// - Note: This structure is used to represent the input for creating a new Treatment.
	///   The `toModel` function converts the input to a `Treatment` model.
	struct Input: Content, WithExample {
		let affectedBone: AffectedBone
		let date: String
		let patientID: Patient.IDValue
		let dicomID: Document.IDValue
		let model3Ds: [Document.IDValue]

		/// Convert the input to a model
		/// - Returns: A `Treatment` model representing the input
		func toModel() -> Treatment {
			.init(date: date,
				  affectedBone: affectedBone,
				  patientID: patientID,
				  dicomID: dicomID,
				  model3Ds: model3Ds)
		}

		static var example: Input {
			.init(affectedBone: .maxillary,
				  date: "1745586420",
				  patientID: UUID(),
				  dicomID: UUID(),
				  model3Ds: [UUID(), UUID()])
		}
	}

	/// Input for creating a new Treatment via a form
	struct FormInput: Content, WithExample {
		let affectedBone: AffectedBone
		let date: String
		let dicomID: Document.IDValue
		let model3Ds: [Document.IDValue]

		static var example: FormInput {
			.init(affectedBone: .maxillary,
				  date: "1745586420",
				  dicomID: UUID(),
				  model3Ds: [UUID(), UUID()])
		}
	}
}

extension Treatment {
	/// Input for updating an existing Treatment
	/// - Note: This structure is used to represent the input for updating an existing Treatment.
	///   The `update` function updates the Treatment with the provided values.
	struct UpdateInput: Content {
		let affectedBone: AffectedBone?
		let date: String?
		let dicomID: Document.IDValue?
		let model3Ds: [Document.IDValue]?

		/// Update the Treatment with the provided values
		/// - Parameter treatment: The Treatment to update
		/// - Returns: An updated `Treatment` model
		/// - Note: This function updates the Treatment with the provided values.
		///    If a value is `nil`, it will not be updated.
		func update(_ treatment: Treatment) -> Treatment {
			let updatedTreatment = treatment

			if let affectedBone = affectedBone {
				updatedTreatment.affectedBone = affectedBone
			}

			if let date = date {
				updatedTreatment.date = date
			}

			if let dicomID = dicomID {
				updatedTreatment.dicomID = dicomID
			}

			if let model3Ds = model3Ds {
				updatedTreatment.model3Ds = model3Ds
			}

			return updatedTreatment
		}

		static var example: UpdateInput {
			.init(affectedBone: .both,
				  date: "1745586420",
				  dicomID: UUID(),
				  model3Ds: [UUID()])
		}
	}
}

extension Treatment {
	/// Output structure for returning a `Treatment` model.
	///
	/// This structure is used to return a fully populated representation of a `Treatment` entity.
	/// It includes identifiers and all associated fields including linked `Patient` and `SurgeryPlan` IDs.
	/// Conforms to `Content` and `WithExample` for use in API responses and OpenAPI documentation.
	struct Output: Content, WithExample {
		let id: UUID?
		let date: String
		let affectedBone: AffectedBone
		let dicomID: Document.IDValue
		let model3Ds: [Document.IDValue]
		let patientID: Patient.IDValue
		let surgeryPlans: [SurgeryPlan.IDValue]

		static var example: Output {
			.init(id: UUID(),
				  date: "1745586420",
				  affectedBone: .mandible,
				  dicomID: UUID(),
				  model3Ds: [UUID(), UUID()],
				  patientID: UUID(),
				  surgeryPlans: [UUID(), UUID()])
		}
	}
}
