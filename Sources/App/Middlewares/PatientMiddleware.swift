//
//  PatientMiddleware.swift
//
//
//  Created by Raphaël Payet on 26/06/2024.
//

import Fluent
import Vapor

/// Middleware to validate and check the existence of a patient
/// It checks the input data for the patient and verifies if the patient already exists in the database.
/// If the patient already exists, it throws a conflict error.
/// If the input data is invalid, it throws a bad request error.
/// This middleware is used to protect routes that require patient data validation.
/// It is important to note that this middleware should be used in conjunction with the `Patient` model,
/// which is responsible for storing the patient data in the database.
/// It is also used to check the existence of the patient in the database before creating or updating it.
/// It is important to note that this middleware should be used in conjunction with the `User` model,
/// which is responsible for storing the user data in the database.
/// It is also used to check the existence of the user in the database before creating or updating the patient.
struct PatientMiddleware: AsyncMiddleware {
	/// Middleware entry point to validate patient input data.
	///
	/// This method checks for:
	/// - The existence of the associated `User` in the database.
	/// - Validity of the patient's name and first name (length ≤ 32).
	/// - Proper ISO 8601 formatting of the birthdate.
	/// - Reasonable age derived from birthdate (between 2 and 119 years).
	///
	/// If any validation fails, it throws a `.badRequest` error.
	/// If all validations pass, it forwards the request to the next responder.
	/// Middleware entry point to validate patient input data.
	///
	/// This method checks for:
	/// - The existence of the associated `User` in the database.
	/// - Validity of the patient's name and first name (length ≤ 32).
	/// - Proper ISO 8601 formatting of the birthdate.
	/// - Reasonable age derived from birthdate (between 2 and 119 years).
	///
	/// If any validation fails, it throws a `.badRequest` error.
	/// If all validations pass, it forwards the request to the next responder.
	func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
		if let patientInput = try? request.content.decode(Patient.Input.self) {

			guard try await User.find(patientInput.userID, on: request.db) != nil else {
				throw Abort(.badRequest, reason: "badRequest.userDoesntExist")
			}

			guard patientInput.name.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.nameLength")
			}

			guard patientInput.firstName.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.firstNameLength")
			}

			guard patientInput.birthdate.isValidISOFormat() else {
				throw Abort(.badRequest, reason: "badRequest.invalidDateFormat")
			}

			guard let age = patientInput.birthdate.ageFromISODate(),
				  1 < age && age < 120 else {
				throw Abort(.badRequest, reason: "badRequest.invalidAge")
			}
		}

		return try await next.respond(to: request)
	}

	/// Checks if a patient already exists in the database.
	///
	/// This method compares the patient's name, first name, birthdate, and associated user ID
	/// to check if the same patient is already registered in the system.
	///
	/// - Parameters:
	///   - patient: The patient object to check for existence.
	///   - req: The request object containing the database connection.
	/// - Throws: A `.conflict` error if the patient already exists.
	func checkIfPatientExist(patient: Patient, on req: Request) async throws {
		let normalizedName = patient.name.trimAndLowercase()
		let normalizedFirstName = patient.firstName.trimAndLowercase()

		let existingPatientQuery = Patient.query(on: req.db)
			.filter(\.$name == normalizedName)
			.filter(\.$firstName == normalizedFirstName)
			.filter(\.$birthdate == patient.birthdate)
			.filter(\.$user.$id == patient.$user.id)

		if try await existingPatientQuery.first() != nil {
			throw Abort(.conflict, reason: "conflict.patientAlreadyExists")
		}
	}
}

struct PatientUpdateMiddleware {
	/// Validates the fields of a `Patient.UpdateInput` instance.
	///
	/// This method checks each optional field individually:
	/// - Ensures `name` and `firstName` do not exceed 32 characters.
	/// - Validates that `birthdate`, if present, is a properly formatted ISO 8601 date and results in an age between 2 and 119 years.
	/// - Confirms that the provided `userID` exists in the database.
	///
	/// Throws a `.badRequest` error if any validation fails.
	func validate(input: Patient.UpdateInput, on req: Request) async throws {
		if let name = input.name {
			guard name.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.nameLength")
			}
		}

		if let firstName = input.firstName {
			guard firstName.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.firstNameLength")
			}
		}

		if let birthdate = input.birthdate {
			guard birthdate.isValidISOFormat() else {
				throw Abort(.badRequest, reason: "badRequest.invalidDateFormat")
			}

			guard let age = birthdate.ageFromISODate(),
				  1 < age && age < 120 else {
				throw Abort(.badRequest, reason: "badRequest.invalidAge")
			}
		}

		if let userID = input.userID {
			guard try await User.find(userID, on: req.db) != nil else {
				throw Abort(.badRequest, reason: "badRequest.userDoesntExist")
			}
		}
	}
}
