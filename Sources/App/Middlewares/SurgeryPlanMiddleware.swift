//
//  SurgeryPlanMiddleware.swift
//
//
//  Created by Raphaël Payet on 26/06/2024.
//

import Fluent
import Vapor

struct SurgeryPlanMiddleware {
	/// Validates the input data for the surgery plan.
	///
	/// This method performs a series of checks:
	/// - Validates arrays such as `naturalTeeth`, `artificialTeeth`, `position`, and others to ensure they do not exceed the maximum allowed count.
	/// - Checks that depth values have at most two decimal places and the count does not exceed 16.
	/// - Validates that references to implants, documents, and other required entities exist in the database.
	/// - Throws `.badRequest` errors for invalid data such as too many items in an array or missing documents.
	///
	/// - Parameters:
	///   - input: The input data to validate.
	///   - db: The database connection to use for the validation.
	/// - Throws: An error if the input data is invalid.
	func validate(input: SurgeryPlan.Input, on database: Database) async throws {
		try validateFloatInputs(input)
		try validateOptionalInputs(input)

		_ = try await TreatmentController().get(with: input.treatmentID, on: database)

		try await validateReference(input, on: database)
		try await validateDocuments(input, on: database)
		try await validateSecondPartDocuments(input, on: database)
		try await validateThirdPartDocuments(input, on: database)

		if let depth = input.depth {
			guard depth.count <= 16 else {
				throw Abort(.badRequest, reason: "badRequest.tooManyDepthData")
			}

			for planDepth in depth {
				guard planDepth.hasAtMostTwoDecimalPlaces else {
					throw Abort(.badRequest, reason: "badRequest.depthHasTooMuchPrecision")
				}
			}
		}
	}

	/// Validates the float array inputs.
	///
	/// This method checks that arrays like `naturalTeeth`, `artificialTeeth`, `position`, etc.,
	/// do not exceed the maximum allowed count (32 items).
	///
	/// - Parameters:
	///   - input: The input data containing arrays to validate.
	/// - Throws: A `.badRequest` error if any array exceeds the allowed count.
	private func validateFloatInputs(_ input: SurgeryPlan.Input) throws {
		guard input.naturalTeeth.count <= 32 else {
			throw Abort(.badRequest, reason: "badRequest.naturalTeethArrayMaxCount")
		}

		guard input.artificialTeeth.count <= 32 else {
			throw Abort(.badRequest, reason: "badRequest.naturalTeethArrayMaxCount")
		}

		guard input.position.count <= 32 else {
			throw Abort(.badRequest, reason: "badRequest.positionArrayMaxCount")
		}

		guard input.center.count <= 32 else {
			throw Abort(.badRequest, reason: "badRequest.centerArrayMaxCount")
		}

		guard input.apex.count <= 32 else {
			throw Abort(.badRequest, reason: "badRequest.apexArrayMaxCount")
		}

		guard input.upIndex.count <= 32 else {
			throw Abort(.badRequest, reason: "badRequest.upIndexArrayMaxCount")
		}
	}

	/// Validates optional input fields.
	///
	/// This method checks if optional fields like `loadingProtocol`, `imagesBoneStress`, `imagesImplantStress`, and `imagesDensity`
	/// exceed the maximum allowed count (32 items).
	///
	/// - Parameters:
	///   - input: The input data containing optional fields to validate.
	/// - Throws: A `.badRequest` error if any optional field exceeds the allowed count.
	private func validateOptionalInputs(_ input: SurgeryPlan.Input) throws {
		if let loadingProtocol = input.loadingProtocol {
			guard loadingProtocol.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.loadingProtocolLength")
			}
		}

		if let imagesBoneStress = input.imagesBoneStress {
			guard imagesBoneStress.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.imagesBoneStressArrayCount")
			}
		}

		if let imagesImplantStress = input.imagesImplantStress {
			guard imagesImplantStress.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.imagesImplantStressArrayCount")
			}
		}

		if let imagesDensity = input.imagesDensity {
			guard imagesDensity.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.imagesDensityArrayCount")
			}
		}
	}

	/// Validates the references to implants in the input data.
	///
	/// This method checks that the number of implant references does not exceed the allowed count (32).
	/// It also verifies the existence of each implant reference in the database.
	///
	/// - Parameters:
	///   - input: The input data containing implant references.
	///   - db: The database connection to check the implant references.
	/// - Throws: A `.badRequest` error if there are too many implant references or if any reference is invalid.
	private func validateReference(_ input: SurgeryPlan.Input, on database: Database) async throws {
		guard input.implantsReference.count <= 32 else {
			throw Abort(.badRequest, reason: "badRequest.tooManyImplants")
		}

		for implantRef in input.implantsReference {
			_ = try await ImplantController().getByReference(implantRef, on: database)
		}
	}

	/// Validates the required documents for the surgery plan.
	///
	/// This method checks for the existence of required documents such as `implantsModels`, `surgeryReport`, `finalReport`,
	/// `surgeryGuide`, and validates that their references exist in the database.
	///
	/// - Parameters:
	///   - input: The input data containing document references.
	///   - db: The database connection to check the documents.
	/// - Throws: A `.notFound` error if any required document is not found in the database.
	private func validateDocuments(_ input: SurgeryPlan.Input, on database: Database) async throws {

		if let implantsModels = input.implantsModels {
			guard try await Document.find(implantsModels, on: database) != nil else {
				throw Abort(.notFound, reason: "notFound.implantsModelsDocument")
			}
		}

		guard input.surgeryReport.count <= 2 else {
			throw Abort(.badRequest, reason: "badRequest.tooManyReportDocuments")
		}

		for report in input.surgeryReport {
			guard try await Document.find(report, on: database) != nil else {
				throw Abort(.notFound, reason: "notFound.surgeryReport")
			}
		}

		if let finalReport = input.finalReport {
			guard try await Document.find(finalReport, on: database) != nil else {
				throw Abort(.notFound, reason: "notFound.finalReport")
			}
		}

		if let surgeryGuide = input.surgeryGuide {
			guard try await Document.find(surgeryGuide, on: database) != nil else {
				throw Abort(.notFound, reason: "notFound.surgeryGuide")
			}
		}
	}

	/// Validates the second set of documents for the surgery plan.
	///
	/// This method checks the existence of documents related to `resultsBoneStress` and `resultsImplantStress`,
	/// ensuring each exists in the database.
	///
	/// - Parameters:
	///   - input: The input data containing second set of document references.
	///   - db: The database connection to check the documents.
	/// - Throws: A `.notFound` error if any required document is not found in the database.
	private func validateSecondPartDocuments(_ input: SurgeryPlan.Input, on database: Database) async throws {
		if let resultsBoneStress = input.resultsBoneStress {
			for result in resultsBoneStress {
				guard try await Document.find(result, on: database) != nil else {
					throw Abort(.notFound, reason: "notFound.resultsBoneStress")
				}
			}
		}

		if let resultsImplantStress = input.resultsImplantStress {
			for result in resultsImplantStress {
				guard try await Document.find(result, on: database) != nil else {
					throw Abort(.notFound, reason: "notFound.resultsImplantStress")
				}
			}
		}
	}

	/// Validates the third set of documents for the surgery plan.
	///
	/// This method checks the existence of documents related to `resultsDensity` and `otherResults`,
	/// ensuring each exists in the database.
	///
	/// - Parameters:
	///   - input: The input data containing third set of document references.
	///   - db: The database connection to check the documents.
	/// - Throws: A `.notFound` error if any required document is not found in the database.
	private func validateThirdPartDocuments(_ input: SurgeryPlan.Input, on database: Database) async throws {
		if let resultsDensity = input.resultsDensity {
			for result in resultsDensity {
				guard try await Document.find(result, on: database) != nil else {
					throw Abort(.notFound, reason: "notFound.resultsDensity")
				}
			}
		}

		if let otherResults = input.otherResults {
			guard try await Document.find(otherResults, on: database) != nil else {
				throw Abort(.notFound, reason: "notFound.otherResults")
			}
		}
	}
}

struct SurgeryPlanUpdateMiddleware {
	/// Validates the update input for a surgery plan.
	///
	/// This method orchestrates the validation of all update input fields, calling other helper validation methods.
	///
	/// - Parameters:
	///   - input: The updated input data to validate.
	///   - database: The database connection to use for validation.
	/// - Throws: An error if the input data is invalid.
	func validate(_ input: SurgeryPlan.UpdateInput, on database: Database) async throws {
		try validateFloatInputs(input)
		try validateSecondFloatInputs(input)
		try await validateReference(input, on: database)
		try await validateDocuments(input, on: database)
		try await validateSecondDocuments(input, on: database)
		try await validateThirdDocuments(input, on: database)
	}

	/// Validates the float array inputs for the updated surgery plan.
	///
	/// This method checks that arrays like `naturalTeeth`, `artificialTeeth`, `position`, etc.,
	/// do not exceed the maximum allowed count (32 items).
	///
	/// - Parameters:
	///   - input: The updated input data containing arrays to validate.
	/// - Throws: A `.badRequest` error if any array exceeds the allowed count.
	private func validateFloatInputs(_ input: SurgeryPlan.UpdateInput) throws {
		if let naturalTeeth = input.naturalTeeth {
			guard naturalTeeth.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.naturalTeethArrayMaxCount")
			}
		}
		if let artificialTeeth = input.artificialTeeth {
			guard artificialTeeth.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.naturalTeethArrayMaxCount")
			}
		}
		if let position = input.position {
			guard position.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.positionArrayMaxCount")
			}
		}
		if let center = input.center {
			guard center.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.centerArrayMaxCount")
			}
		}
		if let apex = input.apex {
			guard apex.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.apexArrayMaxCount")
			}
		}
	}

	/// Validates the second set of optional float array inputs.
	///
	/// This method checks the arrays like `upIndex`, `loadingProtocol`, `imagesBoneStress`, `imagesImplantStress`,
	/// and `imagesDensity` to ensure they do not exceed the allowed count of 32.
	///
	/// - Parameters:
	///   - input: The input data containing the second set of optional arrays to validate.
	/// - Throws: A `.badRequest` error if any array exceeds the allowed count.
	private func validateSecondFloatInputs(_ input: SurgeryPlan.UpdateInput) throws {
		if let upIndex = input.upIndex {
			guard upIndex.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.upIndexArrayMaxCount")
			}
		}
		if let loadingProtocol = input.loadingProtocol {
			guard loadingProtocol.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.loadingProtocolLength")
			}
		}

		if let imagesBoneStress = input.imagesBoneStress {
			guard imagesBoneStress.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.imagesBoneStressArrayCount")
			}
		}

		if let imagesImplantStress = input.imagesImplantStress {
			guard imagesImplantStress.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.imagesImplantStressArrayCount")
			}
		}

		if let imagesDensity = input.imagesDensity {
			guard imagesDensity.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.imagesDensityArrayCount")
			}
		}
	}

	/// Validates references to implants for the updated surgery plan.
	///
	/// This method checks that the implant reference count does not exceed the maximum allowed and verifies
	/// that each reference exists in the database.
	///
	/// - Parameters:
	///   - input: The updated input data containing implant references.
	///   - db: The database connection to verify the implant references.
	/// - Throws: A `.badRequest` error if any reference is invalid or too numerous.
	private func validateReference(_ input: SurgeryPlan.UpdateInput, on database: Database) async throws {
		if let implantsReference = input.implantsReference {
			guard implantsReference.count <= 32 else {
				throw Abort(.badRequest, reason: "badRequest.tooManyImplants")
			}

			for implantRef in implantsReference {
				 _ = try await ImplantController().getByReference(implantRef, on: database)
			}
		}
	}

	/// Validates the documents for the updated surgery plan.
	///
	/// This method checks the references to documents such as `implantsModels`, `surgeryReport`, `finalReport`,
	/// and `surgeryGuide` for validity, ensuring that they exist in the database.
	///
	/// - Parameters:
	///   - input: The updated input data containing document references.
	///   - db: The database connection to check the documents.
	/// - Throws: A `.notFound` error if any document is missing from the database.
	private func validateDocuments(_ input: SurgeryPlan.UpdateInput, on database: Database) async throws {
		if let implantsModels = input.implantsModels {
			guard try await Document.find(implantsModels, on: database) != nil else {
				throw Abort(.notFound, reason: "notFound.implantsModelsDocument")
			}
		}

		if let surgeryReport = input.surgeryReport {
			guard surgeryReport.count <= 2 else {
				throw Abort(.badRequest, reason: "badRequest.tooManyReportDocuments")
			}

			for report in surgeryReport {
				guard try await Document.find(report, on: database) != nil else {
					throw Abort(.notFound, reason: "notFound.surgeryReport")
				}
			}
		}

		if let finalReport = input.finalReport {
			guard try await Document.find(finalReport, on: database) != nil else {
				throw Abort(.notFound, reason: "notFound.finalReport")
			}
		}

		if let surgeryGuide = input.surgeryGuide {
			guard try await Document.find(surgeryGuide, on: database) != nil else {
				throw Abort(.notFound, reason: "notFound.surgeryGuide")
			}
		}
	}

	/// Validates the second set of documents for the updated surgery plan.
	///
	/// This method checks for the existence of documents related to `resultsBoneStress` and `resultsImplantStress`,
	/// ensuring they are available in the database.
	///
	/// - Parameters:
	///   - input: The updated input data containing second set of document references.
	///   - db: The database connection to check the documents.
	/// - Throws: A `.notFound` error if any document is missing.
	private func validateSecondDocuments(_ input: SurgeryPlan.UpdateInput, on database: Database) async throws {
		if let resultsBoneStress = input.resultsBoneStress {
			for result in resultsBoneStress {
				guard try await Document.find(result, on: database) != nil else {
					throw Abort(.notFound, reason: "notFound.resultsBoneStress")
				}
			}
		}

		if let resultsImplantStress = input.resultsImplantStress {
			for result in resultsImplantStress {
				guard try await Document.find(result, on: database) != nil else {
					throw Abort(.notFound, reason: "notFound.resultsImplantStress")
				}
			}
		}
	}

	/// Validates the third set of documents for the updated surgery plan.
	///
	/// This method ensures that documents related to `resultsDensity` and `otherResults` are found in the database.
	///
	/// - Parameters:
	///   - input: The updated input data containing third set of document references.
	///   - db: The database connection to check the documents.
	/// - Throws:
  //    - A `.notFound` error if any document is missing.
  //    - A `.badRequest` error if any data is incorrect
	private func validateThirdDocuments(_ input: SurgeryPlan.UpdateInput, on database: Database) async throws {
		if let resultsDensity = input.resultsDensity {
			for result in resultsDensity {
				guard try await Document.find(result, on: database) != nil else {
					throw Abort(.notFound, reason: "notFound.resultsDensity")
				}
			}
		}

		if let otherResults = input.otherResults {
			guard try await Document.find(otherResults, on: database) != nil else {
				throw Abort(.notFound, reason: "notFound.otherResults")
			}
		}

		if let depth = input.depth {
			guard depth.count <= 16 else {
				throw Abort(.badRequest, reason: "badRequest.tooManyDepthData")
			}

			for value in depth {
				guard value.hasAtMostTwoDecimalPlaces else {
					throw Abort(.badRequest, reason: "badRequest.depthHasTooMuchPrecision")
				}
			}
		}
	}
}
