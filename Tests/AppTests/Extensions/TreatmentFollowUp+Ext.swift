//
//  TreatmentFollowUp+Ext.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

@testable import App
import XCTVapor
import Fluent

extension TreatmentFollowUpControllerTests {
    /// Create a new treatment follow-up
    /// - Parameters:
    ///   - treatmentID: The ID of the treatment
    ///   - operatorID: The ID of the operator
    ///   - validatorID: The ID of the validator
    ///   - db: The database connection
    /// - Returns: The created treatment follow-up
    /// - Throws: An error if the treatment follow-up creation fails
    func createExpectedTreatmentFollowUpAtCreation(with treatmentID: Treatment.IDValue?, on db: Database) async throws -> TreatmentFollowUp {
        let treatmentFollowUp = TreatmentFollowUp(creationDate: expectedCreationDate, treatmentID: treatmentID ?? UUID(), status: expectedCreationStatus)
        try await treatmentFollowUp.save(on: db)
        return treatmentFollowUp
    }

    /// Create a new treatment follow-up
    /// - Parameters:
    ///   - treatmentID: The ID of the treatment
    ///   - operatorID: The ID of the operator
    ///   - validatorID: The ID of the validator
    ///   - db: The database connection
    /// - Returns: The created treatment follow-up
    /// - Throws: An error if the treatment follow-up creation fails
    func createExpectedTreatmentFollowUpAtCalculation(with treatmentID: Treatment.IDValue?, and operatorID: User.IDValue?, on db: Database) async throws -> TreatmentFollowUp {
        let treatmentFollowUp = TreatmentFollowUp(
            creationDate: expectedCreationDate, treatmentID: treatmentID ?? UUID(), status: expectedCalculationStatus,
            calculationDate: expectedCalculationDate, operatorID: operatorID ?? UUID()
        )
        try await treatmentFollowUp.save(on: db)
        return treatmentFollowUp
    }

    /// Create a new treatment follow-up
    /// - Parameters:
    ///   - treatmentID: The ID of the treatment
    ///   - operatorID: The ID of the operator
    ///   - validatorID: The ID of the validator
    ///   - db: The database connection
    /// - Returns: The created treatment follow-up
    /// - Throws: An error if the treatment follow-up creation fails
    func createExpectedTreatmentFollowUpAtValidation(with treatmentID: Treatment.IDValue?, operatorID: User.IDValue?,
                                                     validatorID: User.IDValue?, on db: Database) async throws -> TreatmentFollowUp {
        let treatmentFollowUp = TreatmentFollowUp(
            creationDate: expectedCreationDate, treatmentID: treatmentID ?? UUID(), status: expectedValidationStatus,
            calculationDate: expectedCalculationDate, operatorID: operatorID ?? UUID(),
            validationDate: expectedValidationDate, validatorID: validatorID ?? UUID()
        )
        try await treatmentFollowUp.save(on: db)
        return treatmentFollowUp
    }


    /// Create a new treatment follow-up
    /// - Parameters:
    ///   - treatmentID: The ID of the treatment
    ///   - operatorID: The ID of the operator
    ///   - validatorID: The ID of the validator
    ///   - db: The database connection
    /// - Returns: The created treatment follow-up
    /// - Throws: An error if the treatment follow-up creation fails
    func createExpectedTreatmentFollowUpAtOpening(with treatmentID: Treatment.IDValue?, operatorID: User.IDValue?,
                                                  validatorID: User.IDValue?, on db: Database) async throws -> TreatmentFollowUp {
        let treatmentFollowUp = TreatmentFollowUp(
            creationDate: expectedCreationDate, treatmentID: treatmentID ?? UUID(), status: expectedFirstOpenStatus,
            calculationDate: expectedCalculationDate, operatorID: operatorID ?? UUID(),
            validationDate: expectedValidationDate, validatorID: validatorID ?? UUID(),
            firstOpenDate: expectedFirstOpenDate
        )
        try await treatmentFollowUp.save(on: db)
        return treatmentFollowUp
    }
}
