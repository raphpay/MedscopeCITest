//
//  TreatmentMiddleware.swift
//
//
//  Created by Raphaël Payet on 23/07/2024.
//

import Fluent
import Vapor

struct TreatmentMiddleware {
    /// Validates the input data for the treatment.
    /// - Parameters:
    ///   - input: The input data to validate.
    ///   - patientID: The ID of the patient associated with the treatment.
    ///   - db: The database connection to use for the validation.
    /// - Throws: An error if the input data is invalid.
    func validate(
		_ input: Treatment.Input,
		with patientID: Patient.IDValue,
		on database: Database) async throws {
        let existingTreatment = try await Treatment.query(on: database)
            .filter(\.$patient.$id == patientID)
            .filter(\.$date == input.date)
            .first()

        if existingTreatment != nil {
            throw Abort(.conflict, reason: "conflict.treatmentAlreadyExists")
        }

        guard input.date.isValidISOFormat() else {
            throw Abort(.badRequest, reason: "badRequest.invalidDateFormat")
        }

        guard try await Patient.find(input.patientID, on: database) != nil else {
            throw Abort(.badRequest, reason: "badRequest.inexistantPatient")
        }

        guard try await Document.find(input.dicomID, on: database) != nil else {
            throw Abort(.badRequest, reason: "badRequest.inexistantDicomDocument")
        }

        guard input.model3Ds.count <= 2 else {
            throw Abort(.badRequest, reason: "badRequest.tooManyModel3Ds")
        }

        for model in input.model3Ds {
            guard try await Document.find(model, on: database) != nil else {
                throw Abort(.badRequest, reason: "badRequest.inexistantModel3DDocument")
            }
        }
    }
}

struct TreatmentUpdateMiddleware {
    /// Validates the input data for updating the treatment.
    /// - Parameters:
    ///  - input: The input data to validate.
    ///  - patientID: The ID of the patient associated with the treatment.
    ///  - db: The database connection to use for the validation.
    /// - Throws: An error if the input data is invalid.
    func validate(
		_ input: Treatment.UpdateInput,
		with patientID: Patient.IDValue,
		on database: Database) async throws {
        if let date = input.date {
            guard date.isValidISOFormat() else {
                throw Abort(.badRequest, reason: "badRequest.invalidDateFormat")
            }

            let existingTreatment = try await Treatment.query(on: database)
                .filter(\.$patient.$id == patientID)
                .filter(\.$date == date)
                .first()

            if existingTreatment != nil {
                throw Abort(.conflict, reason: "conflict.treatmentAlreadyExists")
            }
        }

        if let dicomID = input.dicomID {
            guard try await Document.find(dicomID, on: database) != nil else {
                throw Abort(.badRequest, reason: "badRequest.inexistantDocument")
            }
        }

        if let model3Ds = input.model3Ds {
            guard model3Ds.count <= 2 else {
                throw Abort(.badRequest, reason: "badRequest.tooManyModel3Ds")
            }

            for model in model3Ds {
                guard try await Document.find(model, on: database) != nil else {
                    throw Abort(.badRequest, reason: "badRequest.inexistantModel3DDocument")
                }
            }
        }
    }
}
