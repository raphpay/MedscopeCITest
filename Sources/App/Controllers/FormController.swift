//
//  FormController.swift
//
//
//  Created by Raphaël Payet on 31/07/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

struct FormController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Group routes under "/api" and apply APIKeyCheckMiddleware for authentication
        let forms = routes.grouped("api").grouped(APIKeyCheckMiddleware())

        forms
            .group(
                tags: TagObject(
                    name: "forms",
                    description: "Everything about forms"
                )
            ) { routes in
                // Apply Token authentication and User guard middleware
                let tokenAuthMiddleware = Token.authenticator()
                let guardAuthMiddleware = User.guardMiddleware()
                let tokenAuthGroup = routes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
                // POST: Create a new form
                tokenAuthGroup.post(use: create)
                    .openAPI(
                        summary: "Create a new form",
                        description: "Create a new form",
                        body: .type(Form.Input.self),
                        contentType: .application(.json),
						response: .type(Form.self),
                        responseContentType: .application(.json)
                    )
            }
    }

    // MARK: - CREATE
    /// Create a new form
    ///
    /// This function creates a new form and returns it as a `Form` object.
    /// - Parameter req: The incoming request containing the form information.
    /// - Returns: A `Form` object representing the created form.
    /// - Throws: An error if the form cannot be created or if the database query fails.
    /// - Note: The form information is expected to be provided in the request body as JSON.
    ///       The function validates the form input and creates a new patient, treatment, and surgery plans.
    ///       It also creates a new user if the user does not exist in the database.
    ///   The function generates the next medscopeID for the new patient and saves it to the database.
    ///   The function also validates the treatment input and saves it to the database.
    ///   The function creates a new treatment and saves it to the database.
    ///   The function also creates surgery plans and saves them to the database.
    @Sendable
	func create(req: Request) async throws -> Form {
        let input = try req.content.decode(Form.Input.self)
        try await input.validate(on: req)

        var user: User?
        let savedUser = try await User
            .query(on: req.db)
            .filter(\.$mailAddress == input.user.mailAddress)
            .first()

        if let castedUser = savedUser {
            // User exist
            user = castedUser
        } else {
            // User doesn't exist, save to DB
            user = try input.toUser()
            let userInput = try input.toUserInput()
            try await UserMiddleware().validate(userInput: userInput, on: req.db)
            try await user!.save(on: req.db)
        }
        let userID = try user!.requireID()

        let patientInput = input.toPatientInput(userID)
        // Generate the next medscopeID for the new patient
        let newMedscopeID = try await PatientController().generateNextMedscopeID(on: req.db)
        // Create the patient
        let patient = try await PatientController().create(input: patientInput,
                                                           medscopeID: newMedscopeID,
                                                           on: req)
        let patientID = try patient.requireID()

        let treatmentInput = input.toTreatmentInput(patientID)
        try await TreatmentMiddleware().validate(treatmentInput, with: patientID, on: req.db)
        let treatment = try await TreatmentController().create(from: treatmentInput, on: req)

        let treatmentID = try treatment.requireID()
        var plans: [SurgeryPlan] = []
        for surgeryPlanInput in input.surgeryPlans {
            let surgeryPlanInput = input.toSurgeryPlanInput(surgeryPlanInput, treatmentID: treatmentID)
            let plan = try await SurgeryPlanController().create(surgeryPlanInput, on: req)
            plans.append(plan)
        }

        let form = input.toModel(with: user!, patient: patient, treatment: treatment, surgeryPlans: plans)

        return form
    }
}
