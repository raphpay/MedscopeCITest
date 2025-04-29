//
//  UserMiddleware.swift
//
//
//  Created by Raphaël Payet on 26/06/2024.
//

import Fluent
import Vapor

struct UserMiddleware {
	/// Validates the input data for creating a new user.
	///
	/// This method checks the following fields for validity:
	/// - `name` and `firstName` length (≤ 32 characters).
	/// - Optional `address` length (≤ 128 characters).
	/// - Validates the format of `mailAddress` (email format).
	/// - Checks if the `mailAddress` already exists in the database.
	/// - Ensures `conditionsAccepted` is true.
	/// - Validates the `conditionsAcceptedTimestamp` format (ISO 8601).
	///
	/// Throws a `.badRequest` error if any validation fails.
	///
	/// - Parameters:
	///   - userInput: The input data to validate.
	///   - database: The database connection for checking user availability.
	/// - Throws: A `.badRequest` error if any field is invalid.
	func validate(userInput: User.Input, on database: Database) async throws {
		guard userInput.name.count <= 32 else {
			throw Abort(.badRequest, reason: "badRequest.nameLength")
		}

		guard userInput.firstName.count <= 32 else {
			throw Abort(.badRequest, reason: "badRequest.firstNameLength")
		}

		if let address = userInput.address {
			guard address.count <= 128 else {
				throw Abort(.badRequest, reason: "badRequest.addressLength")
			}
		}

		guard userInput.mailAddress.isValidEmail() else {
			throw Abort(.badRequest, reason: "badRequest.incorrectMailAddressFormat")
		}

		try await checkUserAvailability(mailAddress: userInput.mailAddress, on: database)

		guard userInput.conditionsAccepted == true else {
			throw Abort(.badRequest, reason: "badRequest.conditionsNotAccepted")
		}

		if let conditionsAcceptedTimestamp = userInput.conditionsAcceptedTimestamp {
			guard conditionsAcceptedTimestamp.isValidISOFormat() else {
				throw Abort(.badRequest, reason: "badRequest.invalidConditionsAcceptedTimestamp")
			}
		} else {
			throw Abort(.badRequest, reason: "badRequest.noConditionsAcceptedTimestamp")
		}
	}

	/// Checks if a user with the given email address already exists in the database.
	///
	/// This method queries the database to check if any user already has the provided email address.
	///
	/// - Parameters:
	///   - mailAddress: The email address to check.
	///   - database: The database connection to query for user existence.
	/// - Throws: A `.badRequest` error if the user already exists.
	func checkUserAvailability(mailAddress: String, on database: Database) async throws {
		let userCount = try await User
			.query(on: database)
			.filter(\.$mailAddress == mailAddress)
			.count()

		guard userCount == 0 else {
			throw Abort(.badRequest, reason: "badRequest.userAlreadyExists")
		}
	}
}

struct UserUpdateMiddleware {
	/// Validates the input data for updating an existing user.
	///
	/// This method performs validation on the following fields:
	/// - Basic information (`name`, `firstName`, `address`, `mailAddress`).
	/// - Conditions acceptance (`conditionsAccepted`, `conditionsAcceptedTimestamp`).
	///
	/// Throws a `.badRequest` error if any field is invalid.
	///
	/// - Parameters:
	///   - userInput: The input data to validate.
	///   - database: The database connection to use for validation.
	/// - Throws: An error if the input data is invalid.
	func validate(userInput: User.UpdateInput, on database: Database) async throws {
		try await validateBasicInformation(userInput, on: database)
		try await validateConditions(userInput, on: database)
	}

	/// Validates the basic information fields for updating a user.
	///
	/// This method checks:
	/// - `name` and `firstName` length (≤ 32 characters).
	/// - Optional `address` length (≤ 128 characters).
	/// - Validates the format of `mailAddress` (email format).
	/// - Checks if the `mailAddress` already exists in the database.
	///
	/// Throws a `.badRequest` error if any field is invalid.
	///
	/// - Parameters:
	///   - userInput: The input data to validate.
	///   - database: The database connection for checking user availability.
	/// - Throws: A `.badRequest` error if any field is invalid.
	private func validateBasicInformation(_ userInput: User.UpdateInput, on database: Database) async throws {
		if let name = userInput.name {
			guard name.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.nameLength")
			}
		}

		if let firstName = userInput.firstName {
			guard firstName.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.firstNameLength")
			}
		}

		if let address = userInput.address {
			guard address.count <= 128 else {
				throw Abort(.badRequest, reason: "badRequest.addressLength")
			}
		}

		if let mailAddress = userInput.mailAddress {
			guard mailAddress.isValidEmail() else {
				throw Abort(.badRequest, reason: "badRequest.incorrectMailAddressFormat")
			}

			try await UserMiddleware().checkUserAvailability(mailAddress: mailAddress, on: database)
		}
	}

	/// Validates the conditions acceptance fields for updating a user.
	///
	/// This method checks:
	/// - `conditionsAccepted` is true.
	/// - `conditionsAcceptedTimestamp` is in a valid ISO 8601 format.
	///
	/// Throws a `.badRequest` error if any condition is invalid.
	///
	/// - Parameters:
	///   - userInput: The input data to validate.
	///   - database: The database connection (not used but passed for consistency).
	/// - Throws: A `.badRequest` error if any field is invalid.
	private func validateConditions(_ userInput: User.UpdateInput, on database: Database) async throws {
		if let conditionsAccepted = userInput.conditionsAccepted {
			guard conditionsAccepted == true else {
				throw Abort(.badRequest, reason: "badRequest.conditionsNotAccepted")
			}
		}

		if let conditionsAcceptedTimestamp = userInput.conditionsAcceptedTimestamp {
			guard conditionsAcceptedTimestamp.isValidISOFormat() else {
				throw Abort(.badRequest, reason: "badRequest.invalidConditionsAcceptedTimestamp")
			}
		}
	}
}
