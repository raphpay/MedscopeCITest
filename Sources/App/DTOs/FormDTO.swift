//
//  FormDTO.swift
//
//
//  Created by Raphaël Payet on 31/07/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

extension Form {
    /// Input structure for form
    /// - Note: This structure is used to represent the input of a form.
    ///   It contains the user, patient, treatment, and surgery plans.
    ///   The `toModel` function converts the input to a `Form` model.
    ///   The `toUser` function converts the user input to a `User` model.
    ///   The `toPatientInput` function converts the patient input to a `Patient` model.
    ///   The `toTreatmentInput` function converts the treatment input to a `Treatment` model.
    ///   The `toSurgeryPlanInput` function converts the surgery plan input to a `SurgeryPlan` model.
    struct Input: Content, WithExample {
        let user: User.FormInput
        let patient: Patient.FormInput
        let treatment: Treatment.FormInput
        let surgeryPlans: [SurgeryPlan.FormInput]

        /// Convert the input to a `Form` model
        /// - Parameter user: The user associated with the form. Default is nil.
        /// - Parameter patient: The patient associated with the form. Default is nil.
        /// - Parameter treatment: The treatment associated with the form. Default is nil.
        /// - Parameter surgeryPlans: The surgery plans associated with the form. Default is nil.
        /// - Returns: A `Form` model representing the converted input.
        /// - Note: This function converts the input to a `Form` model.
        ///     It sets the user, patient, treatment, and surgery plans of the form.
        ///     If a user, patient, treatment, or surgery plans are provided, it sets the corresponding properties of the form.
        ///     The function returns the converted `Form` model.
        func toModel(with user: User, patient: Patient, treatment: Treatment, surgeryPlans: [SurgeryPlan]) -> Form {
            .init(user: user, patient: patient, treatment: treatment, surgeryPlans: surgeryPlans)
        }

        /// Convert the user input to a `User` model
        /// - Returns: A `User` model representing the converted input.
        func toUser() throws -> User {
            if let password = user.password {
                return User(name: user.name, firstName: user.firstName,
                            address: user.address, mailAddress: user.mailAddress,
                            password: password, role: user.role,
                            conditionsAccepted: user.conditionsAccepted,
                            conditionsAcceptedTimestamp: user.conditionsAcceptedTimestamp,
                            loginFailedAttempts: 0,
                            lastLoginFailedAttempt: nil
                )
            } else {
                throw Abort(.badRequest, reason: "badRequest.missingUserPassword")
            }
        }

        /// Convert the user input to a `User` model
        /// - Returns: A `User` model representing the converted input.
        /// - Note: This function converts the user input to a `User` model.
        ///     It sets the name, first name, mail address, password, role, address, conditions accepted, and conditions accepted timestamp of the user.
        ///     If the password is not provided, it throws an error.
        ///     The function returns the converted `User` model.
        func toUserInput() throws -> User.Input {
            if let password = user.password {
                return User.Input(name: user.name, firstName: user.firstName,
                                  mailAddress: user.mailAddress,
                                  password: password, role: user.role,
                                  address: user.address,
                                  conditionsAccepted: user.conditionsAccepted,
                                  conditionsAcceptedTimestamp: user.conditionsAcceptedTimestamp
                )
            } else {
                throw Abort(.badRequest, reason: "badRequest.missingUserPassword")
            }
        }

        /// Convert the patient input to a `Patient` model
        /// - Parameter userID: The ID of the user associated with the patient. Default is nil.
        /// - Returns: A `Patient` model representing the converted input.
        /// - Note: This function converts the patient input to a `Patient` model.
        ///     It sets the name, first name, birthdate, gender, user ID, and la Galaxy ID of the patient.
        ///     The function returns the converted `Patient` model.
        func toPatientInput(_ userID: User.IDValue) -> Patient.Input {
            .init(name: patient.name,
                  firstName: patient.firstName,
                  birthdate: patient.birthdate,
                  gender: patient.gender,
                  userID: userID,
                  laGalaxyID: patient.laGalaxyID)
        }

        /// Convert the treatment input to a `Treatment` model
        /// - Parameter patientID: The ID of the patient associated with the treatment. Default is nil.
        /// - Returns: A `Treatment` model representing the converted input.
        /// - Note: This function converts the treatment input to a `Treatment` model.
        ///     It sets the affected bone, date, patient ID, dicom ID, and model 3Ds of the treatment.
        ///     The function returns the converted `Treatment` model.
        func toTreatmentInput(_ patientID: Patient.IDValue) -> Treatment.Input {
            .init(affectedBone: treatment.affectedBone,
                  date: treatment.date,
                  patientID: patientID,
                  dicomID: treatment.dicomID,
                  model3Ds: treatment.model3Ds)
        }

        /// Convert the surgery plan input to a `SurgeryPlan` model
        /// - Parameter surgeryPlan: The surgery plan associated with the form. Default is nil.
        /// - Parameter treatmentID: The ID of the treatment associated with the surgery plan. Default is nil.
        /// - Returns: A `SurgeryPlan` model representing the converted input.
        /// - Note: This function converts the surgery plan input to a `SurgeryPlan` model.
        func toSurgeryPlanInput(_ surgeryPlan: SurgeryPlan.FormInput, treatmentID: Treatment.IDValue) -> SurgeryPlan.Input {
            .init(naturalTeeth: surgeryPlan.naturalTeeth, artificialTeeth: surgeryPlan.artificialTeeth,
                  position: surgeryPlan.position, center: surgeryPlan.center, apex: surgeryPlan.apex,
                  upIndex: surgeryPlan.upIndex, implantsReference: surgeryPlan.implantsReference, surgeryReport: surgeryPlan.surgeryReport,
                  isTreated: surgeryPlan.isTreated,
                  depth: surgeryPlan.depth,
                  implantsModels: surgeryPlan.implantsModels,
                  loadingProtocol: surgeryPlan.loadingProtocol,
                  imagesBoneStress: surgeryPlan.imagesBoneStress,
                  imagesImplantStress: surgeryPlan.imagesImplantStress,
                  imagesDensity: surgeryPlan.imagesDensity,
                  finalReport: surgeryPlan.finalReport,
                  surgeryGuide: surgeryPlan.surgeryGuide,
                  resultsBoneStress: surgeryPlan.resultsBoneStress,
                  resultsImplantStress: surgeryPlan.resultsImplantStress,
                  resultsDensity: surgeryPlan.resultsDensity,
                  otherResults: surgeryPlan.otherResults,
                  treatmentID: treatmentID)
        }

        /// Validate the form input
        /// - Parameter request: The request containing the form input. Default is nil.
        /// - Throws: An error if the form input is invalid.
        /// - Note: This function validates the form input.
        ///     It checks if the birthdate of the patient is in a valid ISO format and if the age of the patient is between 1 and 120.
        ///     It also checks if the dicom ID of the treatment is valid and if the patient is in the database.
        ///     The function throws an error if the form input is invalid.
        func validate(on request: Request) async throws {
            // Patient validation
            guard patient.birthdate.isValidISOFormat() else {
                throw Abort(.badRequest, reason: "badRequest.invalidPatientBirthdateFormat")
            }

            guard let age = patient.birthdate.ageFromISODate(),
                  1 < age && age < 120 else {
                throw Abort(.badRequest, reason: "badRequest.invalidAge")
            }

            // Treatment validation
            guard treatment.date.isValidISOFormat() else {
                throw Abort(.badRequest, reason: "badRequest.invaliTreatmentDateFormat")
            }

            guard try await Document.find(treatment.dicomID, on: request.db) != nil else {
                throw Abort(.badRequest, reason: "badRequest.inexistantDicomDocument")
            }
        }

      static var example: Input {
        .init(user: User.FormInput.example,
            patient: Patient.FormInput.example,
            treatment: Treatment.FormInput.example,
            surgeryPlans: [SurgeryPlan.FormInput.example])
      }
    }
}
