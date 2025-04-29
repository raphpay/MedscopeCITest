//
//  ImplantMiddleware.swift
//
//
//  Created by Raphaël Payet on 26/06/2024.
//

import Fluent
import Vapor

struct ImplantMiddleware {
	/// Validate the implant input
	/// - Parameters:
	///   - implantInput: The input to validate
	///   - database: The database connection
	/// - Throws: An error if the input is invalid
	func validate(implantInput: Implant.Input, on database: Database) async throws {
		guard implantInput.internalDiam.hasAtMostTwoDecimalPlaces else {
			throw Abort(.badRequest, reason: "badRequest.internalDiamHasTooMuchPrecision")
		}

		guard implantInput.abutmentContactHeight.hasAtMostTwoDecimalPlaces else {
			throw Abort(.badRequest, reason: "badRequest.abutmentContactHeightHasTooMuchPrecision")
		}

		guard implantInput.diameter.hasAtMostTwoDecimalPlaces else {
			throw Abort(.badRequest, reason: "badRequest.diameterHasTooMuchPrecision")
		}

		guard implantInput.hneck.hasAtMostTwoDecimalPlaces else {
			throw Abort(.badRequest, reason: "badRequest.hneckHasTooMuchPrecision")
		}

		guard implantInput.length.hasAtMostTwoDecimalPlaces else {
			throw Abort(.badRequest, reason: "badRequest.lengthHasTooMuchPrecision")
		}

		guard implantInput.matName.count <= 32 else {
			throw Abort(.badRequest, reason: "badRequest.matNameLength")
		}

		guard try await Document.find(implantInput.modelID, on: database) != nil else {
			throw Abort(.badRequest, reason: "badRequest.inexistantModel")
		}

		guard implantInput.upCenter.count == 3 else {
			throw Abort(.badRequest, reason: "badRequest.invalidUpCenterData")
		}

		guard implantInput.centerZ.count == 3 else {
			throw Abort(.badRequest, reason: "badRequest.invalidCenterZData")
		}

		guard implantInput.upIndex.count == 3 else {
			throw Abort(.badRequest, reason: "badRequest.invalidUpIndexData")
		}
	}
}

struct ImplantUpdateMiddleware {
	/// Validate the implant update input
	/// - Parameters:
	///   - implantInput: The input to validate
	///   - database: The database connection
	/// - Throws: An error if the input is invalid
	func validate(implantInput: Implant.UpdateInput, on database: Database) async throws {
		try validateDecimalPrecision(for: implantInput.internalDiam, fieldName: "internalDiam")
		try validateDecimalPrecision(for: implantInput.abutmentContactHeight, fieldName: "abutmentContactHeight")
		try validateDecimalPrecision(for: implantInput.diameter, fieldName: "diameter")
		try validateDecimalPrecision(for: implantInput.hneck, fieldName: "hneck")
		try validateDecimalPrecision(for: implantInput.length, fieldName: "length")

		if let matName = implantInput.matName, matName.count > 32 {
			throw Abort(.badRequest, reason: "badRequest.matNameLength")
		}

		if let modelID = implantInput.modelID {
			guard try await Document.find(modelID, on: database) != nil else {
				throw Abort(.badRequest, reason: "badRequest.inexistantModel")
			}
		}

		try validateArrayCount(implantInput.upCenter, expectedCount: 3, fieldName: "upCenter")
		try validateArrayCount(implantInput.centerZ, expectedCount: 3, fieldName: "centerZ")
		try validateArrayCount(implantInput.upIndex, expectedCount: 3, fieldName: "upIndex")
	}

	/// Validates that a given float value has at most two decimal places.
	///
	/// - Parameters:
	///   - value: The optional float value to validate.
	///   - fieldName: The name of the field, used in the error message.
	/// - Throws: A `.badRequest` error if the value has more than two decimal places.
	private func validateDecimalPrecision(for value: Float?, fieldName: String) throws {
		if let value = value, !value.hasAtMostTwoDecimalPlaces {
			throw Abort(.badRequest, reason: "badRequest.\(fieldName)HasTooMuchPrecision")
		}
	}

	/// Validates that an array has the expected number of elements.
	///
	/// - Parameters:
	///   - array: The optional array to validate.
	///   - expectedCount: The required number of elements in the array.
	///   - fieldName: The name of the field, used in the error message.
	/// - Throws: A `.badRequest` error if the array exists but has a different count.
	private func validateArrayCount<T>(_ array: [T]?, expectedCount: Int, fieldName: String) throws {
		if let array = array, array.count != expectedCount {
			throw Abort(.badRequest, reason: "badRequest.invalid\(fieldName.capitalized)Data")
		}
	}
}
