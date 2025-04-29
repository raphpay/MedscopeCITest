//
//  TreatmentFollowUpController.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

struct TreatmentFollowUpController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let materials = routes.grouped("api").grouped(APIKeyCheckMiddleware())

        materials
            .group(
                tags: TagObject(
                    name: "treatmentFollowUps",
                    description: "Everything about treatment follow ups"
                )
            ) { routes in
                // Defines middlewares for token-based authentication and user guard
                let tokenAuthMiddleware = Token.authenticator()
                let guardAuthMiddleware = User.guardMiddleware()
                let tokenAuthGroup = routes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
                // POST: Create a new treatment follow up
                tokenAuthGroup.post(use: create)
                    .openAPI(
                        summary: "Create a new treatment follow up",
                        description: "Create a new treatment follow up.",
                        body: .type(TreatmentFollowUp.Input.self),
                        contentType: .application(.json),
                        response: .type(TreatmentFollowUp.self),
                        responseContentType: .application(.json)
                    )
                // GET: Get all treatment follow ups
                tokenAuthGroup.get(use: getAll)
                    .openAPI(
                        summary: "Get all treatment follow ups",
                        response: .type([TreatmentFollowUp].self),
                        responseContentType: .application(.json)
                    )

                // GET: Get a specific treatment follow up
                tokenAuthGroup.get(":treatmentFollowUpID", use: getTreatmentFollowUp)
                    .openAPI(
                        summary: "Get a specific treatment follow up",
                        response: .type([TreatmentFollowUp].self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "Treatment follow up not found")

                // UPDATE: Update a specific treatment follow up
                tokenAuthGroup.put("calculate", ":treatmentFollowUpID", use: calculate)
                    .openAPI(
                        summary: "Update an existing treatment follow up after calculation",
                        body: .type(TreatmentFollowUp.UpdateCalculationInput.self),
                        contentType: .application(.json),
                        response: .type(TreatmentFollowUp.self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "treatmentFollowUp")
                    .response(statusCode: .badRequest, description: "invalidCalculationDateFormat")
                    .response(statusCode: .badRequest, description: "inexistantOperator")
                    .response(statusCode: .badRequest, description: "missingOperatorID")
                    .response(statusCode: .badRequest, description: "missingCalculationDate")

                // UPDATE: Update a specific treatment follow up
                tokenAuthGroup.put("validate", ":treatmentFollowUpID", use: validate)
                    .openAPI(
                        summary: "Update an existing treatment follow up after validation",
                        body: .type(TreatmentFollowUp.UpdateValidationInput.self),
                        contentType: .application(.json),
                        response: .type(TreatmentFollowUp.self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "treatmentFollowUp")
                    .response(statusCode: .badRequest, description: "missingValidatorID")
                    .response(statusCode: .badRequest, description: "missingValidationDate")
                    .response(statusCode: .badRequest, description: "incorrectFollowUpState")
                    .response(statusCode: .badRequest, description: "invalidValidationDateFormat")
                    .response(statusCode: .badRequest, description: "inexistantValidator")

                // UPDATE: Update a specific treatment follow up
                tokenAuthGroup.put("open", ":treatmentFollowUpID", use: updateOpen)
                    .openAPI(
                        summary: "Update an existing treatment follow up after opening",
                        body: .type(TreatmentFollowUp.UpdateOpeningInput.self),
                        contentType: .application(.json),
                        response: .type(TreatmentFollowUp.self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "treatmentFollowUp")
                    .response(statusCode: .badRequest, description: "missingOpeningDate")
                    .response(statusCode: .badRequest, description: "incorrectFollowUpState")
                    .response(statusCode: .badRequest, description: "invalidFirstOpenDateFormat")

                // UPDATE: Update a specific treatment follow up
                tokenAuthGroup.put("status", ":treatmentFollowUpID", use: updateStatus)
                    .openAPI(
                        summary: "Update an existing treatment follow up status",
                        body: .type(TreatmentFollowUp.UpdateStatusInput.self),
                        contentType: .application(.json),
                        response: .type(TreatmentFollowUp.self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "treatmentFollowUp")
            }
    }

    // MARK: - CREATE
    /// Create a new treatment follow up
    /// - Parameter req: The incoming request containing the treatment follow up information.
    /// - Returns: A `TreatmentFollowUp` object representing the created treatment follow up.
    /// - Throws: An error if the treatment follow up cannot be created or if the database query fails.
    @Sendable
    func create(req: Request) async throws -> TreatmentFollowUp.Output {
        let input = try req.content.decode(TreatmentFollowUp.Input.self)
        let versionnedFollowUp = try await input.getAndUpdateVersionLog(on: req)
        try await TreatmentFollowUpMiddleware().validate(versionnedFollowUp, on: req.db)

        let treatmentFollowUp = versionnedFollowUp.toModel()

        try await treatmentFollowUp.save(on: req.db)

		return treatmentFollowUp.toOutput()
    }

    // MARK: - READ
    /// Get all treatment follow ups
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An array of `TreatmentFollowUp` objects representing the retrieved treatment follow ups.
    /// - Throws: An error if the database query fails
    @Sendable
    func getAll(req: Request) async throws -> [TreatmentFollowUp.Output] {
        let treatmentFollowUps = try await TreatmentFollowUp.query(on: req.db).all()
		return treatmentFollowUps.map { $0.toOutput() }
    }

    @Sendable
	func getTreatmentFollowUp(req: Request) async throws -> TreatmentFollowUp.Output {
		try await get(on: req).toOutput()
    }

    // MARK: - UPDATE
    /// Update a specific treatment follow up - Step 1
    /// - Parameter req: The incoming request containing the treatment follow up ID and updated information.
    /// - Returns: A `TreatmentFollowUp` object representing the updated treatment follow up.
    /// - Throws: An error if the treatment follow up cannot be found or if the database update fails.
    /// - Note: This function is the first step of the update process for a treatment follow up.
    ///     It first retrieves the treatment follow up by its ID from the database.
    ///     It then updates the treatment follow up with the provided information.
    ///     If the treatment follow up is not found, it throws a `notFound` error.
    ///     If the database update fails, it throws an error.
    @Sendable
    func calculate(req: Request) async throws -> TreatmentFollowUp.Output {
        let input = try req.content.decode(TreatmentFollowUp.UpdateCalculationInput.self)
        try await TreatmentFollowUpUpdateMiddleware().validate(input, on: req.db)

        let treatmentFollowUp = try await get(on: req)
        let updatedTreatmentFollowUp = try input.updateCalculationDetails(treatmentFollowUp)

        try await updatedTreatmentFollowUp.update(on: req.db)

		return updatedTreatmentFollowUp.toOutput()
    }

    /// Update a specific treatment follow up - Step 2
    /// - Parameter req: The incoming request containing the treatment follow up ID and updated information.
    /// - Returns: A `TreatmentFollowUp` object representing the updated treatment follow up.
    /// - Throws: An error if the treatment follow up cannot be found or if the database update fails.
    /// - Note: This function is the second step of the update process for a treatment follow up.
    ///     It first retrieves the treatment follow up by its ID from the database.
    ///     It then updates the treatment follow up with the provided information.
    ///     If the treatment follow up is not found, it throws a `notFound` error.
    ///     If the database update fails, it throws an error.
    @Sendable
    func validate(req: Request) async throws -> TreatmentFollowUp.Output {
        let input = try req.content.decode(TreatmentFollowUp.UpdateValidationInput.self)
        try await TreatmentFollowUpUpdateMiddleware().validate(input, on: req.db)

        let treatmentFollowUp = try await get(on: req)
        let updatedTreatmentFollowUp = try input.updateValidationDetails(treatmentFollowUp)

        try await updatedTreatmentFollowUp.update(on: req.db)

		return updatedTreatmentFollowUp.toOutput()
    }

    /// Update a specific treatment follow up - Step 3
    /// - Parameter req: The incoming request containing the treatment follow up ID and updated information.
    /// - Returns: A `TreatmentFollowUp` object representing the updated treatment follow up.
    /// - Throws: An error if the treatment follow up cannot be found or if the database update fails.
    /// - Note: This function is the third step of the update process for a treatment follow up.
    ///     It first retrieves the treatment follow up by its ID from the database.
    ///     It then updates the treatment follow up with the provided information.
    ///     If the treatment follow up is not found, it throws a `notFound` error.
    ///     If the database update fails, it throws an error.
    @Sendable
    func updateOpen(req: Request) async throws -> TreatmentFollowUp.Output {
        let input = try req.content.decode(TreatmentFollowUp.UpdateOpeningInput.self)
        try await TreatmentFollowUpUpdateMiddleware().validate(input, on: req.db)

        let treatmentFollowUp = try await get(on: req)
        let updatedTreatmentFollowUp = try input.updateFirstOpenDate(treatmentFollowUp)

        try await updatedTreatmentFollowUp.update(on: req.db)

		return updatedTreatmentFollowUp.toOutput()
    }

    /// Update a specific treatment follow up - Step 4
    /// - Parameter req: The incoming request containing the treatment follow up ID and updated information.
    /// - Returns: A `TreatmentFollowUp` object representing the updated treatment follow up.
    /// - Throws: An error if the treatment follow up cannot be found or if the database update fails.
    /// - Note: This function is the fourth step of the update process for a treatment follow up.
    ///     It first retrieves the treatment follow up by its ID from the database.
    ///     It then updates the treatment follow up with the provided information.
    ///     If the treatment follow up is not found, it throws a `notFound` error.
    ///     If the database update fails, it throws an error.
    ///     If the user does not have the required role to perform the update,
	///     it throws an `unauthorized` error.
    ///     If the treatment follow up is not in the correct state, it throws an `badRequest` error.
    ///     If the database update fails, it throws an error.
    @Sendable
    func updateStatus(req: Request) async throws -> TreatmentFollowUp.Output {
        let input = try req.content.decode(TreatmentFollowUp.UpdateStatusInput.self)
        let treatmentFollowUp = try await get(on: req)
        let updatedTreatmentFollowUp = input.updateStatus(treatmentFollowUp)

        try await updatedTreatmentFollowUp.update(on: req.db)

		return updatedTreatmentFollowUp.toOutput()
    }
}

extension TreatmentFollowUpController {
    /// Get a treatment follow up by its ID
    /// - Parameter req: The incoming request containing the treatment follow up ID.
    /// - Returns: A `TreatmentFollowUp` object representing the retrieved treatment follow up.
    /// - Throws: An error if the treatment follow up cannot be found or if the database query fails.
    /// - Note: This function retrieves the treatment follow up by its ID from the database and returns it as a `TreatmentFollowUp` object.
    ///     If the treatment follow up is not found, it throws a `notFound` error.
    func get(on req: Request) async throws -> TreatmentFollowUp {
        guard let treatmentFollowUp = try await TreatmentFollowUp
                .find(req.parameters.get("treatmentFollowUpID"),
                      on: req.db) else {
            throw Abort(.notFound, reason: "notFound.treatmentFollowUp")
        }

        return treatmentFollowUp
    }
}
