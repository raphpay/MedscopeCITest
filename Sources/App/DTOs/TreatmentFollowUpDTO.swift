//
//  TreatmentFollowUpDTO.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

extension TreatmentFollowUp {
	/// Input for creating a new TreatmentFollowUp
	/// - Note: This structure is used to represent the input for creating a new TreatmentFollowUp.
	///    The `toModel` function converts the input to a `TreatmentFollowUp` model.
	///    The `getAndUpdateVersionLog` function updates the version log of the TreatmentFollowUp.
	struct Input: Content, WithExample {
		let creationDate: String
		let treatmentID: Treatment.IDValue
		let status: Status
		// Optional
		let calculationDate: String?
		let operatorID: User.IDValue?
		let validationDate: String?
		let validatorID: User.IDValue?
		let firstOpenDate: String?
		var versionInterface: String?
		var versionCalculator: String?
		var versionAPI: String?
		var udi: String?


		/// Updates the version log of the TreatmentFollowUp
		/// - Parameter req: The request
		/// - Returns: A `TreatmentFollowUp` model representing the input with the updated version log
		func getAndUpdateVersionLog(on req: Request) async throws -> TreatmentFollowUp.Input {
			let versionLog = try await VersionLogController().get(on: req)
			var updatedInput = self

			if self.versionInterface == nil {
				updatedInput.versionInterface = versionLog.interface
			}
			if self.versionCalculator == nil {
				updatedInput.versionCalculator = versionLog.calculator
			}
			if self.versionAPI == nil {
				updatedInput.versionAPI = versionLog.api
			}

			return updatedInput
		}

		/// Converts the input to a `TreatmentFollowUp` model
		/// - Returns: A `TreatmentFollowUp` model representing the input
		/// - Throws: An error if the conversion fails
		/// - Note: This function is used to convert the input to a `TreatmentFollowUp` model.
		func toModel() -> TreatmentFollowUp {
			.init(
				creationDate: creationDate, treatmentID: treatmentID, status: status,
				calculationDate: calculationDate, operatorID: operatorID,
				validationDate: validationDate, validatorID: validatorID,
				firstOpenDate: firstOpenDate,
				versionInterface: versionInterface, versionCalculator: versionCalculator,
				versionAPI: versionAPI
			)
		}

		static var example: Input {
			.init(creationDate: "1745586420",
				  treatmentID: UUID(),
				  status: .received,
				  calculationDate: "1745586420",
				  operatorID: UUID(),
				  validationDate: "1745586420",
				  validatorID: UUID(),
				  firstOpenDate: "1745586420",
				  versionInterface: "4.0.1",
				  versionCalculator: "3.2.0",
				  versionAPI: "1.0.0",
				  udi: "8787H")
		}
	}
}

extension TreatmentFollowUp {
	/// Input for updating the calculation details of a TreatmentFollowUp
	/// - Note: This structure is used to represent the input for updating the calculation details of a TreatmentFollowUp.
	///    The `updateCalculationDetails` function updates the calculation details of the TreatmentFollowUp.
	struct UpdateCalculationInput: Content, WithExample {
		let calculationDate: String?
		let operatorID: User.IDValue?

		/// Updates the calculation details of the TreatmentFollowUp
		/// - Parameter followUp: The TreatmentFollowUp to update
		/// - Returns: An updated `TreatmentFollowUp` model
		/// - Throws: An error if the update fails
		/// - Note: This function updates the calculation details of the TreatmentFollowUp.
		///    If the calculation details are not set, it throws an error.
		func updateCalculationDetails(_ followUp: TreatmentFollowUp) throws -> TreatmentFollowUp {
			let updatedFollowUp = followUp

			if let calculationDate = calculationDate {
				if let operatorID = operatorID {
					updatedFollowUp.calculationDate = calculationDate
					updatedFollowUp.operatorID = operatorID
					updatedFollowUp.status = .inProgress
				} else {
					throw Abort(.badRequest, reason: "badRequest.missingOperatorID")
				}
			} else {
				throw Abort(.badRequest, reason: "badRequest.missingCalculationDate")
			}

			return updatedFollowUp
		}

		static var example: TreatmentFollowUp.UpdateCalculationInput {
			.init(calculationDate: "1745586420", operatorID: UUID())
		}
	}

	/// Input for updating the validation details of a TreatmentFollowUp
	/// - Note: This structure is used to represent the input for updating the validation details of a TreatmentFollowUp.
	///    The `updateValidationDetails` function updates the validation details of the TreatmentFollowUp.
	struct UpdateValidationInput: Content, WithExample {
		let validationDate: String?
		let validatorID: User.IDValue?

		/// Updates the validation details of the TreatmentFollowUp
		/// - Parameter followUp: The TreatmentFollowUp to update
		/// - Returns: An updated `TreatmentFollowUp` model
		/// - Throws: An error if the update fails
		/// - Note: This function updates the validation details of the TreatmentFollowUp.
		///    If the validation details are not set, it throws an error.
		func updateValidationDetails(_ followUp: TreatmentFollowUp) throws -> TreatmentFollowUp {
			let updatedFollowUp = followUp

			// Ensure `validationDate` and `validatorID` can only be set if `calculationDate` is already set
			if followUp.calculationDate != nil {
				if let validationDate = validationDate {
					if let validatorID = validatorID {
						updatedFollowUp.validatorID = validatorID
						updatedFollowUp.validationDate = validationDate
						updatedFollowUp.status = .sent
					} else {
						throw Abort(.badRequest, reason: "badRequest.missingValidatorID")
					}
				} else {
					throw Abort(.badRequest, reason: "badRequest.missingValidationDate")
				}
			} else {
				throw Abort(.badRequest, reason: "badRequest.incorrectFollowUpState")
			}

			return updatedFollowUp
		}

		static var example: TreatmentFollowUp.UpdateValidationInput {
			.init(validationDate: "1745586420", validatorID: UUID())
		}
	}

	/// Input for updating the first opening date of a TreatmentFollowUp
	/// - Note: This structure is used to represent the input for updating the first opening date of a TreatmentFollowUp.
	///    The `updateFirstOpenDate` function updates the first opening date of the TreatmentFollowUp.
	struct UpdateOpeningInput: Content, WithExample {
		let firstOpenDate: String?

		/// Updates the first opening date of the TreatmentFollowUp
		/// - Parameter followUp: The TreatmentFollowUp to update
		/// - Returns: An updated `TreatmentFollowUp` model
		/// - Throws: An error if the update fails
		/// - Note: This function updates the first opening date of the TreatmentFollowUp.
		///    If the first opening date is not set, it throws an error.
		func updateFirstOpenDate(_ followUp: TreatmentFollowUp) throws -> TreatmentFollowUp {
			let updatedFollowUp = followUp

			// Ensure `firstOpenDate` can only be set if `validationDate` is already set
			if followUp.calculationDate != nil && followUp.validationDate != nil {
				if let firstOpenDate = firstOpenDate {
					updatedFollowUp.firstOpenDate = firstOpenDate
					updatedFollowUp.status = .open
				} else {
					throw Abort(.badRequest, reason: "badRequest.missingOpeningDate")
				}
			} else {
				throw Abort(.badRequest, reason: "badRequest.incorrectFollowUpState")
			}

			return updatedFollowUp
		}

		static var example: UpdateOpeningInput {
			.init(firstOpenDate: "1745586420")
		}
	}

	/// Input for updating the status of a TreatmentFollowUp
	/// - Note: This structure is used to represent the input for updating the status of a TreatmentFollowUp.
	///    The `updateStatus` function updates the status of the TreatmentFollowUp.
	///    The `status` property is optional, and if it is not set, the status will not be updated.
	///    If the status is not set, it will not be updated.
	struct UpdateStatusInput: Content, WithExample {
		let status: Status?

		/// Updates the status of the TreatmentFollowUp
		/// - Parameter followUp: The TreatmentFollowUp to update
		/// - Returns: An updated `TreatmentFollowUp` model
		/// - Note: This function updates the status of the TreatmentFollowUp.
		func updateStatus(_ followUp: TreatmentFollowUp) -> TreatmentFollowUp {
			let updatedFollowUp = followUp
			if let status = status {
				updatedFollowUp.status = status
			}
			return updatedFollowUp
		}

		static var example: UpdateStatusInput {
			.init(status: .open)
		}
	}
}

extension TreatmentFollowUp {
	/// Output structure for returning a `TreatmentFollowUp` model.
	///
	/// This structure is used to serialize and return all fields related to a `TreatmentFollowUp`.
	/// It includes tracking fields like calculation and validation dates, versioning metadata, and status.
	/// Conforms to `Content` and `WithExample` for use in API responses and documentation.
	struct Output: Content, WithExample {
		let id: UUID?
		let creationDate: String
		let treatmentID: Treatment.IDValue
		let status: Status
		let calculationDate: String?
		let operatorID: User.IDValue?
		let validationDate: String?
		let validatorID: User.IDValue?
		let firstOpenDate: String?
		let versionInterface: String?
		let versionCalculator: String?
		let versionSP: String?
		let versionAPI: String?

		static var example: TreatmentFollowUp.Output {
			.init(id: UUID(),
				  creationDate: "1745586420",
				  treatmentID: UUID(),
				  status: .received,
				  calculationDate: "1745586420",
				  operatorID: UUID(),
				  validationDate: "1745586420",
				  validatorID: UUID(),
				  firstOpenDate: "1745586420",
				  versionInterface: "1.0.0",
				  versionCalculator: "2.3.7",
				  versionSP: "9.2.3",
				  versionAPI: "6.1.2")
		}
	}
}
