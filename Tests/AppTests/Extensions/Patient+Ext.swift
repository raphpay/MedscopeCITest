//
//  Patient+Ext.swift
//
//
//  Created by Raphaël Payet on 25/07/2024.
//

@testable import App
import XCTVapor
import Fluent


extension PatientControllerTests {
    /// Create a new patient
    /// - Parameters:
    ///  - userID: The user ID of the patient
    /// - save: Whether to save the patient in the database
    /// - db: The database connection to use for the creation
    /// - Returns: The created patient
    /// - Throws: An error if the patient creation fails
    func createExpectedPatient(with userID: User.IDValue = UUID(), save: Bool = true, on db: Database) async throws -> Patient {
        let patient = Patient(name: expectedName, firstName: expectedFirstName, birthdate: expectedBirthdate, gender: expectedGender, userID: userID, medscopeID: expectedMedscopeID, laGalaxyID: expectedLaGalaxyID)
        if save == true {
            try await patient.save(on: db)
        } else {
            patient.id = UUID()
        }
        return patient
    }

    /// Create a new patient
    /// - Parameters:
    ///  - userID: The user ID of the patient
    /// - save: Whether to save the patient in the database
    /// - db: The database connection to use for the creation
    /// - Returns: The created patient
    /// - Throws: An error if the patient creation fails
    func createExpectedPatientFormInput(with userID: User.IDValue = UUID(), birthdate: String? = nil) -> Patient.FormInput {
        var patientBirthdate = birthdate
        if birthdate == nil {
            patientBirthdate = expectedBirthdate
        }

        return Patient.FormInput(name: expectedName, firstName: expectedFirstName, birthdate: patientBirthdate!, gender: expectedGender, laGalaxyID: expectedLaGalaxyID)
    }
}

extension Patient {
    /// Create a new patient
    /// - Parameters:
    ///   - name: The name of the patient
    ///   - firstName: The first name of the patient
    ///   - birthdate: The birthdate of the patient
    ///   - userID: The ID of the patient's user
    ///   - medscopeID: The medscope ID of the patient
    ///   - laGalaxyID: The laGalaxy ID of the patient
    ///   - db: The database connection to use for the creation
    static func create(
        name: String,
        firstName: String,
        birthdate: String,
        gender: Patient.Gender,
        userID: User.IDValue,
        medscopeID: String,
        laGalaxyID: String,
        on db: Database
    ) async throws -> Patient {
        let patient = Patient(name: name, firstName: firstName, birthdate: birthdate, gender: gender, userID: userID, medscopeID: medscopeID, laGalaxyID: laGalaxyID)
        try await patient.save(on: db)
        return patient
    }
}
