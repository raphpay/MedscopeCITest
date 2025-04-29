//
//  TreatmentFollowUpMiddleware.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

import Fluent
import Vapor

struct TreatmentFollowUpMiddleware {
    /// Validates the input data for the treatment follow up.
    /// - Parameters:
    ///   - input: The input data to validate.
    ///   - db: The database connection to use for the validation.
    /// - Throws: An error if the input data is invalid.
    func validate(_ input: TreatmentFollowUp.Input, on database: Database) async throws {
        guard try await Treatment.find(input.treatmentID, on: database) != nil else {
            throw Abort(.badRequest, reason: "badRequest.inexistantTreatment")
        }

        guard input.creationDate.isValidISOFormat() else {
            throw Abort(.badRequest, reason: "badRequest.invalidCreationDateFormat")
        }

        if let calculationDate = input.calculationDate {
            guard calculationDate.isValidISOFormat() else {
                throw Abort(.badRequest, reason: "badRequest.invalidCalculationDateFormat")
            }
        }

        if let operatorID = input.operatorID {
            guard try await User.find(operatorID, on: database) != nil else {
                throw Abort(.badRequest, reason: "badRequest.inexistantOperator")
            }
        }

        if let validationDate = input.validationDate {
            guard validationDate.isValidISOFormat() else {
                throw Abort(.badRequest, reason: "badRequest.invalidValidationDateFormat")
            }
        }

        if let validatorID = input.validatorID {
            guard try await User.find(validatorID, on: database) != nil else {
                throw Abort(.badRequest, reason: "badRequest.inexistantValidator")
            }
        }

        if let firstOpenDate = input.firstOpenDate {
            guard firstOpenDate.isValidISOFormat() else {
                throw Abort(.badRequest, reason: "badRequest.invalidFirstOpenDateFormat")
            }
        }

        guard input.versionInterface != nil,
			  input.versionCalculator != nil,
			  input.versionAPI != nil else {
            throw Abort(.badRequest, reason: "badRequest.missingVersion")
        }
    }
}

struct TreatmentFollowUpUpdateMiddleware {
    /// Validates the update input data for the treatment follow up.
    /// - Parameters:
    ///   - input: The update input data to validate.
    ///   - db: The database connection to use for the validation.
    /// - Throws: An error if the update input data is invalid.
    func validate(_ input: TreatmentFollowUp.UpdateCalculationInput, on database: Database) async throws {
        if let calculationDate = input.calculationDate {
            guard calculationDate.isValidISOFormat() else {
                throw Abort(.badRequest, reason: "badRequest.invalidCalculationDateFormat")
            }
        }

        if let operatorID = input.operatorID {
            guard try await User.find(operatorID, on: database) != nil else {
                throw Abort(.badRequest, reason: "badRequest.inexistantOperator")
            }
        }
    }

    /// Validates the update input data for the treatment follow up.
    /// - Parameters:
    ///  - input: The update input data to validate.
    ///  - db: The database connection to use for the validation.
    /// - Throws: An error if the update input data is invalid.
    func validate(_ input: TreatmentFollowUp.UpdateValidationInput, on database: Database) async throws {
        if let validationDate = input.validationDate {
            guard validationDate.isValidISOFormat() else {
                throw Abort(.badRequest, reason: "badRequest.invalidValidationDateFormat")
            }
        }

        if let validatorID = input.validatorID {
            guard try await User.find(validatorID, on: database) != nil else {
                throw Abort(.badRequest, reason: "badRequest.inexistantValidator")
            }
        }
    }

    /// Validates the update input data for the treatment follow up.
    /// - Parameters:
    /// - input: The update input data to validate.
    /// - db: The database connection to use for the validation.
    /// - Throws: An error if the update input data is invalid.
    func validate(_ input: TreatmentFollowUp.UpdateOpeningInput, on database: Database) async throws {
        if let firstOpenDate = input.firstOpenDate {
            guard firstOpenDate.isValidISOFormat() else {
                throw Abort(.badRequest, reason: "badRequest.invalidFirstOpenDateFormat")
            }
        }
    }
}
