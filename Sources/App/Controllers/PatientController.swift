//
//  PatientController.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

struct PatientController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Group routes under "/api" and apply APIKeyCheckMiddleware for authentication
        let patients = routes.grouped("api").grouped(APIKeyCheckMiddleware())
        // POST
        try registerPostRoutes(patients)
        // GET
        try registerGetRoutes(patients)
        // UPDATE
        try registerUpdateRoutes(patients)
        // DELETE
        try registerDeleteRoutes(patients)
    }
}

extension PatientController {
    private func registerPostRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "patients",
                                     description: "Everything about patients")) { patientRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = patientRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // POST: Create a new patient
            tokenAuthGroup.post(use: create)
                .openAPI(
                    summary: "Create a new patient",
                    description: "Create a new patient with the provided informations",
                    body: .type(Patient.Input.self),
                    contentType: .application(.json),
					response: .type(Patient.Output.self),
                    responseContentType: .application(.json)
                )
        }
    }

    private func registerGetRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "patients",
                                     description: "Everything about patients")) { patientRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = patientRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // GET: Get all patients
            tokenAuthGroup.get(use: getAll)
                .openAPI(
                    summary: "Get all patients",
					response: .type([Patient.Output].self),
                    responseContentType: .application(.json)
                )

            // GET: Get a specific patient
            tokenAuthGroup.get(":patientID", use: getPatient)
                .openAPI(
                    summary: "Get a specific patient",
					response: .type(Patient.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Patient not found")
                .response(statusCode: .badRequest, description: "Missing or incorrectly formatted patient ID")

            // GET: Get all patient's treatments
            tokenAuthGroup.get("treatment", ":patientID", use: getTreatments)
                .openAPI(
                    summary: "Get all patient's treatments",
					response: .type([Treatment.Output].self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Patient not found")
                .response(statusCode: .badRequest, description: "Missing or incorrectly formatted patient ID")

            // GET: Get the first patient treatment at the designated date
            tokenAuthGroup.get("treatment", "atDate", ":patientID", use: getTreatmentAtDate)
                .openAPI(
                    summary: "Get the first patient treatment at the designated date",
					response: .type(Treatment.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Patient not found")
                .response(statusCode: .badRequest, description: "Missing or incorrectly formatted patient ID")
                .response(statusCode: .notFound, description: "Treatment not found")

            // GET: Get the patient with the specific medscope ID
            tokenAuthGroup.get("medscopeID", ":medscopeID", use: getByMedscopeID)
                .openAPI(
                    summary: "Get the patient with the specific medscope ID",
					response: .type(Patient.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .badRequest, description: "Missing medscope ID")
                .response(statusCode: .notFound, description: "Patient not found")
        }
    }

    private func registerUpdateRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "patients",
                                     description: "Everything about patients")) { patientRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = patientRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // UPDATE: Update a specific patient
            tokenAuthGroup.put(":patientID", use: update)
                .openAPI(
                    summary: "Update a specific patient",
                    body: .type(Patient.UpdateInput.self),
                    contentType: .application(.json),
					response: .type(Patient.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .badRequest, description: "See log message for more information")
                .response(statusCode: .badRequest, description: "Missing patient ID")
                .response(statusCode: .notFound, description: "Patient not found")
                .response(statusCode: .conflict, description: "Patient already exist")
        }
    }

    private func registerDeleteRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "patients",
                                     description: "Everything about patients")) { patientRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = patientRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // DELETE: Delete all patients
            tokenAuthGroup.delete("all", use: deleteAll)
                .openAPI(
                    summary: "Delete all patients",
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )

            // DELETE: Delete a specific patient
            tokenAuthGroup.delete(":patientID", use: delete)
                .openAPI(
                    summary: "Delete a patient",
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Patient not found")
        }
    }
}

extension PatientController {
    // MARK: - CREATE
    /// Create a new patient
    /// - Parameter req: The incoming request containing the patient information.
    /// - Returns: A `Patient` object representing the created patient.
    /// - Throws: An error if the patient cannot be created or if the database query fails.
    /// - Note: This function retrieves the patient information from the request body,
    ///    generates a new medscope ID, and creates a new patient in the database.
    ///   If the patient already exists, it returns the existing patient.
    @Sendable
	func create(req: Request) async throws -> Patient.Output {
        let input = try req.content.decode(Patient.Input.self)

        // Generate the next medscopeID for the new patient
        let newMedscopeID = try await generateNextMedscopeID(on: req.db)

		return try await create(input: input, medscopeID: newMedscopeID, on: req).toOutput()
    }

    // MARK: - READ
    /// Retrieve all patients.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An array of `Patient` objects representing the retrieved patients.
    /// - Throws: An error if the database query fails.
    /// - Note: This function retrieves all patients from the database.
    ///    It returns an array of `Patient` objects.
    ///    If the database query fails, it throws an error.
    @Sendable
	func getAll(req: Request) async throws -> [Patient.Output] {
		let patients = try await Patient.query(on: req.db).all()
		return patients.map { $0.toOutput() }
    }

    /// Retrieve a specific patient.
    /// - Parameter req: The incoming request containing the patient ID.
    /// - Returns: A `Patient` object representing the retrieved patient.
    /// - Throws: An error if the patient cannot be found or if the database query fails.
    /// - Note: This function retrieves the patient by its ID from the database using the provided ID.
    ///     It returns the first matching patient found in the database.
    ///     If no matching patient is found, it throws a `notFound` error.
    ///     If the ID is not provided, it throws a `badRequest` error.
    @Sendable
    func getPatient(req: Request) async throws -> Patient {
        return try await getPatient(on: req)
    }

    /// Retrieve a specific patient by its medscope ID.
    /// - Parameter req: The incoming request containing the medscope ID.
    /// - Returns: A `Patient` object representing the retrieved patient.
    /// - Throws: An error if the patient cannot be found or if the database query fails.
    /// - Note: This function retrieves the patient by its medscope ID from the database using the provided ID.
    ///     It returns the first matching patient found in the database.
    ///     If no matching patient is found, it throws a `notFound` error.
    ///     If the medscope ID is not provided, it throws a `badRequest` error.
    @Sendable
    func getTreatments(req: Request) async throws -> [Treatment] {
        let patient = try await getPatient(on: req)
        return try await patient.$treatments.get(on: req.db)
    }

    /// Retrieve the first treatment at a specific date.
    /// - Parameter req: The incoming request containing the patient ID and the date.
    /// - Returns: A `Treatment` object representing the retrieved treatment.
    /// - Throws: An error if the patient or treatment cannot be found or if the database query fails.
    /// - Note: This function retrieves the first treatment at the specified date from the database using the provided patient ID and date.
    ///     It returns the first matching treatment found in the database.
    ///     If no matching treatment is found, it throws a `notFound` error.
    ///     If the patient ID or date is not provided, it throws a `badRequest` error.
    @Sendable
    func getTreatmentAtDate(req: Request) async throws -> Treatment {
        let patient = try await getPatient(on: req)

        let input = try req.content.decode(Patient.TreatmentDateInput.self)

        guard let treatment = try await patient.$treatments.query(on: req.db)
            .filter(\.$date == input.date)
            .first() else {
            throw Abort(.notFound, reason: "notFound.treatment")
        }

        return treatment
    }

    /// Retrieve a specific patient by its medscope ID.
    /// - Parameter req: The incoming request containing the medscope ID.
    /// - Returns: A `Patient` object representing the retrieved patient.
    /// - Throws: An error if the patient cannot be found or if the database query fails.
    /// - Note: This function retrieves the patient by its medscope ID from the database using the provided ID.
    ///     It returns the first matching patient found in the database.
    ///     If no matching patient is found, it throws a `notFound` error.
    ///    If the medscope ID is not provided, it throws a `badRequest` error.
    @Sendable
	func getByMedscopeID(req: Request) async throws -> Patient.Output {
        let medscopeID = try getMedscopeID(req: req)
        guard let patient = try await Patient.query(on: req.db).filter(\.$medscopeID == medscopeID)
            .first() else {
            throw Abort(.notFound, reason: "notFound.patient")
        }

		return patient.toOutput()
    }

    // MARK: - UPDATE
    /// Update a specific patient.
    /// - Parameter req: The incoming request containing the patient ID and updated information.
    /// - Returns: A `Patient` object representing the updated patient.
    /// - Throws: An error if the patient cannot be found or if the database update fails.
    /// - Note: This function updates the patient with the provided information.
    ///     It first retrieves the patient by its ID from the database.
    ///     It then updates the patient with the provided information.
    ///     If the patient is not found, it throws a `notFound` error.
    ///     If the database update fails, it throws an error.
    ///     If the user does not have the required role to perform the update, it throws an `unauthorized` error.
    ///     If the input is invalid, it throws a `badRequest` error.
    ///     If the patient already exists, it throws a `conflict` error.
    ///     If the patient ID is not provided, it throws a `badRequest` error.
    @Sendable
	func update(req: Request) async throws -> Patient.Output {
        let updatedInput = try req.content.decode(Patient.UpdateInput.self)
        try await PatientUpdateMiddleware().validate(input: updatedInput, on: req)
        let patient = try await getPatient(on: req)

        let updatedPatient = updatedInput.update(patient)
        try await PatientMiddleware().checkIfPatientExist(patient: updatedPatient, on: req)

        try await updatedPatient.update(on: req.db)

		return updatedPatient.toOutput()
    }

    // MARK: - DELETE
    /// Delete a specific patient.
    /// - Parameter req: The incoming request containing the patient ID.
    /// - Returns: An `HTTPResponseStatus` indicating the status of the deletion.
    /// - Throws: An error if the patient cannot be found or if the database deletion fails.
    /// - Note: This function deletes the patient with the provided ID from the database.
    ///     It first retrieves the patient by its ID from the database.
    ///     It then deletes the patient from the database.
    ///     If the user does not have the required role to perform the deletion, it throws an `unauthorized` error.
    ///     If the patient has treatments, it deletes them as well.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the patient is deleted from the database, including its associated treatments.
    ///     Use this function only if you want to delete a specific patient from the database.
    ///     Deleting a patient will remove its associated treatments from the database.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting a patient will remove all associated treatments from the database.
    ///    Ensure that you have proper backups and authorization before using this function.
    @Sendable
    func delete(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        let patient = try await getPatient(on: req)
        return try await delete(patient: patient, on: req)
    }

    /// Delete all patients.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves all patients from the database, and deletes each patient one by one. It returns a 204 No Content status upon successful deletion of all patients.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///    It ensures that the patients are deleted from the database, including their associated treatments.
    ///     Use this function only if you want to delete all patients from the database.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting all patients will remove all associated treatments from the database.
    ///    Ensure that you have proper backups and authorization before using this function.
    @Sendable
    func deleteAll(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        let patients = try await Patient
            .query(on: req.db)
            .all()

        for patient in patients {
            _ = try await delete(patient: patient, on: req)
        }

        return .noContent
    }
}

// MARK: - Utils
extension PatientController {
    /// Retrieve a specific patient by its ID.
    /// - Parameter req: The incoming request containing the patient ID.
    /// - Returns: A `Patient` object representing the retrieved patient.
    /// - Throws: An error if the patient cannot be found or if the database query fails.
    /// - Note: This function retrieves the patient by its ID from the database using the provided ID.
    ///     It returns the first matching patient found in the database.
    ///     If no matching patient is found, it throws a `notFound` error.
    ///     If the ID is not provided, it throws a `badRequest` error.
    ///     If the patient ID is not a valid ID, it throws a `badRequest` error.
    private func getPatient(on req: Request) async throws -> Patient {
        guard let id = req.parameters.get("patientID", as: Patient.IDValue.self) else {
            throw Abort(.badRequest, reason: "badRequest.missingPatientID")
        }

        guard let patient = try await Patient.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.patient")
        }

        return patient
    }

    /// Retrieve a specific patient by its ID.
    /// - Parameter id: The ID of the patient to be retrieved.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `Patient` object representing the retrieved patient.
    /// - Throws: An error if the patient cannot be found or if the database query fails.
    /// - Note: This function retrieves the patient by its ID from the database using the provided ID.
    ///     It returns the first matching patient found in the database.
    func getPatient(_ id: Patient.IDValue, on req: Request) async throws -> Patient {
        guard let patient = try await Patient.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.patient")
        }

        return patient
    }

    /// Create a new patient with the provided information.
    /// - Parameters:
    ///   - input: The `Patient.Input` containing the patient information.
    ///   - medscopeID: The medscope ID for the new patient.
    ///   - req: The incoming request containing the database connection.
    /// - Returns: A `Patient` object representing the created patient.
    /// - Throws: An error if the patient cannot be created or if the database query fails.
    /// - Note: This function creates a new patient with the provided information.
    ///     It first normalizes the name and first name of the patient.
    ///     It then checks if the patient already exists in the database.
    ///     If the patient already exists, it returns the existing patient.
    ///     The function also generates a new medscope ID for the new patient.
    func create(input: Patient.Input, medscopeID: String, on req: Request) async throws -> Patient {
        var patient = input.toModel(medscopeID)

        let normalizedName = input.name.trimAndLowercase()
        let normalizedFirstName = input.firstName.trimAndLowercase()

        if let existingPatient = try await Patient.query(on: req.db)
            .filter(\.$name == normalizedName)
            .filter(\.$firstName == normalizedFirstName)
            .filter(\.$birthdate == input.birthdate)
            .filter(\.$user.$id  == input.userID)
            .first() {
            patient = existingPatient
        } else {
            try await patient.save(on: req.db)
        }

        return patient
    }

    /// Find the highest medscope ID currently in use.
    /// - Parameter db: The database connection to use for retrieving the highest medscope ID.
    /// - Returns: An integer representing the highest medscope ID currently in use.
    /// - Throws: An error if the database query fails.
    /// - Note: This function retrieves the highest medscope ID currently in use from the database.
    ///     It sorts the patients by medscope ID in descending order.
    ///     It then retrieves the first patient in the sorted list.
    ///     If no patient is found, it returns 0.
    func findMaxMedscopeID(on db: Database) async throws -> Int {
        let maxMedscopeID = try await Patient.query(on: db)
            .sort(\.$medscopeID, .descending)
            .first()

        if let medscopeID = maxMedscopeID?.medscopeID {
            let numberString = medscopeID.replacingOccurrences(of: "MEDP", with: "")
            let number = Int(numberString) ?? 0
            return number
        }

        return 0
    }

    /// Generate the next medscope ID.
    /// - Parameter db: The database connection to use for retrieving the highest medscope ID.
    /// - Returns: A string representing the next medscope ID.
    /// - Throws: An error if the database query fails.
    /// - Note: This function retrieves the highest medscope ID currently in use from the database.
    ///     It sorts the patients by medscope ID in descending order.
    ///     It then retrieves the first patient in the sorted list.
    ///     If no patient is found, it returns 0.
    ///     It then generates the next medscope ID by incrementing the current highest medscope ID.
    func generateNextMedscopeID(on db: Database) async throws -> String {
        // Find the highest medscopeID currently in use
        let maxNumber = try await findMaxMedscopeID(on: db)

        // Generate the next medscopeID
        let nextNumber = maxNumber + 1
        return String(format: "MEDP%04d", nextNumber)
    }

    /// Retrieve the medscope ID from the request parameters.
    /// - Parameter req: The incoming request containing the medscope ID.
    /// - Returns: A string representing the retrieved medscope ID.
    /// - Throws: An error if the medscope ID is not provided or if the request parameters cannot be parsed.
    private func getMedscopeID(req: Request) throws -> String {
        guard let medscopeID = req.parameters.get("medscopeID") else {
            throw Abort(.badRequest, reason: "badRequest.missingMedscopeID")
        }

        let isValid = medscopeID.isValidMedscopeID()
        if !isValid {
            throw Abort(.badRequest, reason: "badRequest.medscopeIDBadlyFormatted")
        }

        return medscopeID
    }

    /// Delete a specific patient.
    /// - Parameters:
    ///   - patient: The `Patient` object to be deleted.
    ///   - req: The incoming request containing the database connection.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the patient cannot be found or if the database deletion fails.
    /// - Note: This function deletes the patient with the provided ID from the database.
    ///     It first retrieves the patient by its ID from the database.
    ///     It then deletes the patient from the database.
    ///     If the patient has treatments, it deletes them as well.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the patient is deleted from the database, including its associated treatments.
    ///     Use this function only if you want to delete a specific patient from the database.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting a patient will remove all associated treatments from the database.
    func delete(patient: Patient, on req: Request) async throws -> HTTPResponseStatus {
        let treatments = try await patient.$treatments.query(on: req.db).all()
        for treatment in treatments {
            _ = try await TreatmentController().delete(treatment: treatment, on: req)
        }

        try await patient.delete(force: true, on: req.db)
        return .noContent
    }
}
