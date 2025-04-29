//
//  ImplantDTO.swift
//
//
//  Created by Raphaël Payet on 25/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

/// This file defines the Data Transfer Objects (DTOs) used for creating, updating, and outputting `Implant` models.
/// 
/// - `Implant.Input`: Represents the required structure for creating a new `Implant`.
/// - `Implant.UpdateInput`: Represents an optional structure for partially updating an existing `Implant`.
/// - `Implant.Output`: Represents the full, returned representation of an `Implant`.
/// 
/// Each structure conforms to `Content` to enable automatic decoding and encoding in Vapor.
/// The `UpdateInput` also contains logic to conditionally apply non-nil values to an existing model.

// MARK: - Create Input
extension Implant {
	/// Input structure for Implant
	/// - Note: This structure is used to represent the input
	///     It contains the different parameters of the Implant.
	struct Input: Content {
		let reference: String
		let internalDiam: Float
		let abutmentContactHeight: Float
		let diameter: Float
		let hneck: Float
		let length: Float
		let matName: String
		let upCenter: [Float]
		let centerZ: [Float]
		let upIndex: [Float]
		let modelID: Document.IDValue

		/// Convert the input to a model
		/// - Returns: A `Implant` model representing the input
		func toModel() -> Implant {
			.init(reference: reference,
				  internalDiam: internalDiam,
				  abutmentContactHeight: abutmentContactHeight,
				  diameter: diameter,
				  hneck: hneck,
				  length: length,
				  matName: matName,
				  upCenter: upCenter,
				  centerZ: centerZ,
				  upIndex: upIndex,
				  modelID: modelID
			)
		}

	  static var example: Input {
		.init(reference: "K36012",
			internalDiam: 873.2,
			abutmentContactHeight: 738.1,
			diameter: 42.1,
			hneck: 2.1,
			length: 9.3,
			matName: "Silicon",
			upCenter: [3.89, 90],
			centerZ: [3.89, 90],
			upIndex: [3.89, 90],
			modelID: UUID())
	  }
	}
}

// MARK: - Update Input
extension Implant {
	/// Input for updating an existing Implant
	/// - Note: This structure is used to represent the input for updating an existing Implant.
	///     It contains the reference, internal diameter, abutment contact height, diameter, hneck, length, material name, up center, center Z, up index, and model ID.
	///     The `update` function updates the Implant with the provided values.
	struct UpdateInput: Content {
		let reference: String?
		let internalDiam: Float?
		let abutmentContactHeight: Float?
		let diameter: Float?
		let hneck: Float?
		let length: Float?
		let matName: String?
		let upCenter: [Float]?
		let centerZ: [Float]?
		let upIndex: [Float]?
		let modelID: Document.IDValue?

		/// Updates the given `Implant` model by applying all non-nil fields from this `UpdateInput`.
		///
		/// Only the values that are not nil will overwrite the corresponding fields in the existing model.
		/// This allows for partial updates.
		///
		/// - Parameters:
		///   - implant: The existing `Implant` model to be updated.
		///   - db: A database reference (not currently used in this function).
		/// - Returns: The updated `Implant` model.
		func update(_ implant: Implant, on db: Database) async throws -> Implant {
			let updatedImplant = implant

			applyIfPresent(reference) { updatedImplant.reference = $0 }
			applyIfPresent(internalDiam) { updatedImplant.internalDiam = $0 }
			applyIfPresent(abutmentContactHeight) { updatedImplant.abutmentContactHeight = $0 }
			applyIfPresent(diameter) { updatedImplant.diameter = $0 }
			applyIfPresent(hneck) { updatedImplant.hneck = $0 }
			applyIfPresent(length) { updatedImplant.length = $0 }
			applyIfPresent(matName) { updatedImplant.matName = $0 }
			applyIfPresent(upCenter) { updatedImplant.upCenter = $0 }
			applyIfPresent(centerZ) { updatedImplant.centerZ = $0 }
			applyIfPresent(upIndex) { updatedImplant.upIndex = $0 }
			applyIfPresent(modelID) { updatedImplant.modelID = $0 }

			return updatedImplant
		}

		/// Applies the given closure to a value if it is non-nil.
		///
		/// This utility is used to selectively update fields in an `Implant` only when new values are provided.
		///
		/// - Parameters:
		///   - value: An optional value to check.
		///   - apply: A closure that updates a field with the unwrapped value.
		private func applyIfPresent<T>(_ value: T?, _ apply: (T) -> Void) {
			if let value = value {
				apply(value)
			}
		}

		static var example: UpdateInput {
			.init(reference: "K36012",
				  internalDiam: 873.2,
				  abutmentContactHeight: 738.1,
				  diameter: 42.1,
				  hneck: 2.1,
				  length: 9.3,
				  matName: "Silicon",
				  upCenter: [3.89, 90],
				  centerZ: [3.89, 90],
				  upIndex: [3.89, 90],
				  modelID: UUID())
		}
	}
}

extension Implant {
	/// Output structure for returning an `Implant` model.
	///
	/// This structure is used when returning a fully populated `Implant` to the client.
	/// It includes all the fields present in the model, including the unique identifier.
	/// Conforms to `Content` and `WithExample` for use in API responses and documentation.
	struct Output: Content, WithExample {
		let id: UUID?
		let reference: String
		let internalDiam: Float
		let abutmentContactHeight: Float
		let diameter: Float
		let hneck: Float
		let length: Float
		let matName: String
		let upCenter: [Float]
		let centerZ: [Float]
		let upIndex: [Float]
		let modelID: Document.IDValue

		static var example: Implant.Output {
			.init(id: UUID(),
				  reference: "K36012",
				  internalDiam: 873.2,
				  abutmentContactHeight: 738.1,
				  diameter: 42.1,
				  hneck: 2.1,
				  length: 9.3,
				  matName: "Silicon",
				  upCenter: [3.89, 90],
				  centerZ: [3.89, 90],
				  upIndex: [3.89, 90],
				  modelID: UUID())
		}
	}
}
