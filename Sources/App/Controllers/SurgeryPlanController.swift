//
//  SurgeryPlanController.swift
//
//
//  Created by Raphaël Payet on 21/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

struct SurgeryPlanController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Group the routes under the "api" path
        let surgeryPlans = routes.grouped("api").grouped(APIKeyCheckMiddleware())
        // POST
        try registerPostRoutes(surgeryPlans)
        // GET
        try registerGetRoutes(surgeryPlans)
        // UPDATE
        try registerUpdateRoutes(surgeryPlans)
        // DELETE
        try registerDeleteRoutes(surgeryPlans)
    }
}

extension SurgeryPlanController {
    private func registerPostRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "surgeryPlans",
                                     description: "Everything about surgeryPlans")) { surgeryPlanRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = surgeryPlanRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // POST: Create a new surgery plan
            tokenAuthGroup.post(use: create)
                .openAPI(
                    summary: "Create a new surgery plan",
                    description: "Create a new surgery plan with the provided informations",
                    body: .type(SurgeryPlan.Input.self),
                    contentType: .application(.json),
					response: .type(SurgeryPlan.Output.self),
                    responseContentType: .application(.json)
                )
        }
    }

    private func registerGetRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "surgeryPlans",
                                     description: "Everything about surgeryPlans")) { surgeryPlanRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = surgeryPlanRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // GET: Get all surgery plans
            tokenAuthGroup.get(use: getAll)
                .openAPI(
                    summary: "Get all surgery plans",
					response: .type([SurgeryPlan.Output].self),
                    responseContentType: .application(.json)
                )

            // GET: Get a specific surgery plan
            tokenAuthGroup.get(":surgeryPlanID", use: getSurgeryPlan)
                .openAPI(
                    summary: "Get a specific surgery plan",
					response: .type(SurgeryPlan.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Surgery plan not found")

            // GET: Get the implants related to a specific surgery plan
            tokenAuthGroup.get(":surgeryPlanID", "implants", use: getImplants)
                .openAPI(
                    summary: "Get the implants related to a specific surgery plan",
					response: .type([Implant.Output].self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Surgery plan not found")
                .response(statusCode: .notFound, contentType: "Implant not found")
        }
    }

    private func registerUpdateRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "surgeryPlans",
                                     description: "Everything about surgeryPlans")) { surgeryPlanRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = surgeryPlanRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            let description = """
                Update an existing surgery plan with the provided informations.
                All informations are optionals
            """
            // PUT: Update a specific surgery plan
            tokenAuthGroup.put(":surgeryPlanID", use: update)
                .openAPI(
                    summary: "Update an existing surgery plan",
                    description: description,
                    body: .type(SurgeryPlan.UpdateInput.self),
                    contentType: .application(.json),
                    response: .type(SurgeryPlan.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Surgery plan not found")

            // PUT: Update the isTreated parameter of a specific surgery plan
            tokenAuthGroup.put(":surgeryPlanID", "toggle", "treated", use: toggleIsTreated)
                .openAPI(
                    summary: "Update the isTreated parameter  of an existing surgery plan",
                    description: "Update the isTreated parameter of an existing surgery plan.",
                    contentType: .application(.json),
                    response: .type(SurgeryPlan.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Surgery plan not found")
        }
    }

    private func registerDeleteRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "surgeryPlans",
                                     description: "Everything about surgeryPlans")) { surgeryPlanRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = surgeryPlanRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // DELETE: Delete all surgery plans
            tokenAuthGroup.delete("all", use: deleteAll)
                .openAPI(
                    summary: "Delete surgery plans",
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )

            // DELETE: Delete a specific surgery plan
            tokenAuthGroup.delete(":surgeryPlanID", use: delete)
                .openAPI(
                    summary: "Delete a specific surgery plan",
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )
        }
    }
}

extension SurgeryPlanController {
    // MARK: - CREATE
    /// Create a new surgery plan
    /// - Parameter req: The incoming request containing the surgery plan information.
    /// - Returns: A `SurgeryPlan` object representing the created surgery plan.
    /// - Throws: An error if the surgery plan cannot be created or if the database query fails.
    /// - Note: This function retrieves the surgery plan information from the request body,
    ///    generates a new medscope ID, and creates a new surgery plan in the database.
    @Sendable
    func create(req: Request) async throws -> SurgeryPlan.Output {
        let input = try req.content.decode(SurgeryPlan.Input.self)
        let surgeryPlan = try await create(input, on: req)
		return surgeryPlan.toOutput()
    }

    // MARK: - READ
    /// Get all surgery plans
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An array of `SurgeryPlan` objects representing the retrieved surgery plans.
    /// - Throws: An error if the database query fails.
    /// - Note: This function retrieves all surgery plans from the database.
    ///    It returns an array of `SurgeryPlan` objects.
    @Sendable
    func getAll(req: Request) async throws -> [SurgeryPlan.Output] {
        let surgeryPlans = try await SurgeryPlan.query(on: req.db).all()
		return surgeryPlans.map { $0.toOutput() }
    }

    /// Get a specific surgery plan
    /// - Parameter req: The incoming request containing the surgery plan ID.
    /// - Returns: A `SurgeryPlan` object representing the retrieved surgery plan.
    /// - Throws: An error if the surgery plan cannot be found or if the database query fails.
    /// - Note: This function retrieves the surgery plan by its ID from the database using the provided ID.
    ///     It returns the first matching surgery plan found in the database.
    @Sendable
    func getSurgeryPlan(req: Request) async throws -> SurgeryPlan.Output {
		try await getSurgeryPlan(on: req).toOutput()
    }

    /// Get the implants related to a specific surgery plan
    /// - Parameter req: The incoming request containing the surgery plan ID.
    /// - Returns: An array of `Implant` objects representing the implants related to the surgery plan.
    /// - Throws: An error if the surgery plan cannot be found or if the database query fails.
    @Sendable
    func getImplants(req: Request) async throws -> [Implant.Output] {
        let surgeryPlan = try await getSurgeryPlan(on: req)
        let implantsSet = Set(surgeryPlan.implantsReference.map { $0 })
        var implants: [Implant] = []
        for implantRef in implantsSet {
            let implant = try await ImplantController().getByReference(implantRef, on: req.db)
            implants.append(implant)
        }
		return implants.map { $0.toOutput() }
    }

    // MARK: - UPDATE
    /// Update a specific surgery plan
    /// - Parameter req: The incoming request containing the surgery plan ID and updated information.
    /// - Returns: A `SurgeryPlan` object representing the updated surgery plan.
    /// - Throws: An error if the surgery plan cannot be found or if the database update fails.
    @Sendable
    func update(req: Request) async throws -> SurgeryPlan.Output {
        let surgeryPlan = try await getSurgeryPlan(on: req)

        // Decode the update input from the request body
        let updateInput = try req.content.decode(SurgeryPlan.UpdateInput.self)

        // Validate the input
		try await SurgeryPlanUpdateMiddleware().validate(updateInput, on: req.db)

        // Apply the updates to the existing SurgeryPlan
        let updatedSurgeryPlan = try await updateInput.update(surgeryPlan)
        try await updatedSurgeryPlan.update(on: req.db)

		return surgeryPlan.toOutput()
    }

    /// Update the isTreated parameter of a specific surgery plan
    /// - Parameter req: The incoming request containing the surgery plan ID and updated information.
    /// - Returns: A `SurgeryPlan` object representing the updated surgery plan.
    /// - Throws: An error if the surgery plan cannot be found or if the database update fails.
    @Sendable
    func toggleIsTreated(req: Request) async throws -> SurgeryPlan.Output {
        let surgeryPlan = try await getSurgeryPlan(on: req)

        let updatedSurgeryPlan = surgeryPlan
        updatedSurgeryPlan.isTreated.toggle()

        try await updatedSurgeryPlan.update(on: req.db)

		return updatedSurgeryPlan.toOutput()
    }

    // MARK: - DELETE
    /// Delete all surgery plans
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves all surgery plans from the database, and deletes each surgery plan one by one. It returns a 204 No Content status upon successful deletion of all surgery plans.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the surgery plans are deleted from the database, including their associated implants.
    ///     Use this function only if you want to delete all surgery plans from the database.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting all surgery plans will remove all associated implants from the database.
    @Sendable
    func deleteAll(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        let surgeryPlans = try await SurgeryPlan
            .query(on: req.db)
            .all()

        for surgeryPlan in surgeryPlans {
             _ = try await delete(surgeryPlan: surgeryPlan, on: req)
        }

        return .noContent
    }

    /// Delete a specific surgery plan
    /// - Parameter req: The incoming request containing the surgery plan ID.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the surgery plan cannot be found or if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves a surgery plan by its ID from the database, and deletes it.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the surgery plan is deleted from the database, including its associated implants.
    ///     Use this function only if you want to delete a specific surgery plan from the database.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting a surgery plan will remove its associated implants from the database.
    @Sendable
    func delete(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        let surgeryPlan = try await getSurgeryPlan(on: req)
        return try await delete(surgeryPlan: surgeryPlan, on: req)
    }
}

// MARK: - Utils
extension SurgeryPlanController {
    /// Retrieve a specific surgery plan by its ID.
    /// - Parameter req: The incoming request containing the surgery plan ID.
    /// - Returns: A `SurgeryPlan` object representing the retrieved surgery plan.
    /// - Throws: An error if the surgery plan cannot be found or if the database query fails.
    /// - Note: This function retrieves the surgery plan by its ID from the database using the provided ID.
    ///     It returns the first matching surgery plan found in the database.
    ///     If no matching surgery plan is found, it throws a `notFound` error.
    private func getSurgeryPlan(on req: Request) async throws -> SurgeryPlan {
        guard let surgeryPlan = try await SurgeryPlan.find(req.parameters.get("surgeryPlanID"),
                                                           on: req.db) else {
            throw Abort(.notFound, reason: "notFound.surgeryPlan")
        }

        return surgeryPlan
    }

    /// Retrieve a specific surgery plan by its ID.
    /// - Parameter id: The ID of the surgery plan to be retrieved.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `SurgeryPlan` object representing the retrieved surgery plan.
    /// - Throws: An error if the surgery plan cannot be found or if the database query fails.
    /// - Note: This function retrieves the surgery plan by its ID from the database using the provided ID.
    ///     It returns the first matching surgery plan found in the database.
    ///     This is the version with `async` return type.
    func getSurgeryPlan(with id: SurgeryPlan.IDValue, on req: Request) async throws -> SurgeryPlan {
        guard let surgeryPlan = try await SurgeryPlan.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.surgeryPlan")
        }

        return surgeryPlan
    }

    /// Retrieve a specific surgery plan by its ID.
    /// - Parameter id: The ID of the surgery plan to be retrieved.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `SurgeryPlan` object representing the retrieved surgery plan.
    /// - Throws: An error if the surgery plan cannot be found or if the database query fails.
    /// - Note: This function retrieves the surgery plan by its ID from the database using the provided ID.
    ///     It returns the first matching surgery plan found in the database.
    ///     This is the version with `EventLoopFuture` return type.
    func getSurgeryPlan(with id: SurgeryPlan.IDValue, on req: Request) -> EventLoopFuture<SurgeryPlan> {
        return SurgeryPlan.find(id, on: req.db).flatMap { surgeryPlan in
            guard let surgeryPlan = surgeryPlan else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "notFound.surgeryPlan"))
            }
            return req.eventLoop.makeSucceededFuture(surgeryPlan)
        }
    }

    /// Create a new surgery plan
    /// - Parameter input: The `SurgeryPlan.Input` containing the surgery plan information.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `SurgeryPlan` object representing the created surgery plan.
    /// - Throws: An error if the surgery plan cannot be created or if the database query fails.
    /// - Note: This function retrieves the surgery plan information from the request body,
    ///    generates a new medscope ID, and creates a new surgery plan in the database.
    func create(_ input: SurgeryPlan.Input, on req: Request) async throws -> SurgeryPlan {
        // Validate input
        try await SurgeryPlanMiddleware().validate(input: input, on: req.db)
        // Generate Medscope ID
        let newMedscopeID = try await generateNextMedscopeID(on: req.db)

        let surgeryPlan = input.toModel(newMedscopeID)
        try await surgeryPlan.save(on: req.db)
        return surgeryPlan
    }

    /// Find the maximum medscope ID in the database.
    /// - Parameter db: The database connection.
    /// - Returns: An `Int` representing the maximum medscope ID found in the database.
    /// - Throws: An error if the database query fails.
    /// - Note: This function retrieves the maximum medscope ID from the `SurgeryPlan` table in the database.
    ///    If no matching medscope ID is found, it returns 0.
    func findMaxMedscopeID(on db: Database) async throws -> Int {
        let maxMedscopeID = try await SurgeryPlan.query(on: db)
            .sort(\.$medscopeID, .descending)
            .first()

        if let medscopeID = maxMedscopeID?.medscopeID {
            let numberString = medscopeID.replacingOccurrences(of: "PLAN", with: "")
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
    ///     It sorts the surgery plans by medscope ID in descending order.
    ///     It then retrieves the first surgery plan in the sorted list.
    ///     If no surgery plan is found, it returns 0.
    ///     It then generates the next medscope ID by incrementing the current highest medscope ID.
    func generateNextMedscopeID(on db: Database) async throws -> String {
        // Find the highest medscopeID currently in use
        let maxNumber = try await findMaxMedscopeID(on: db)

        // Generate the next medscopeID
        let nextNumber = maxNumber + 1
        return String(format: "PLAN%08d", nextNumber)
    }

    /// Delete a specific surgery plan
    /// - Parameter req: The incoming request containing the surgery plan ID.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the surgery plan cannot be found or if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves a surgery plan by its ID from the database, and deletes it.
    ///   It also deletes all associated documents related to the surgery plan.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the surgery plan is deleted from the database, including its associated implants.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting a surgery plan will remove its associated implants from the database.
    ///    Ensure that you have proper backups and authorization before using this function.
    func delete(surgeryPlan: SurgeryPlan, on req: Request) async throws -> HTTPResponseStatus {
        var documentsToDelete: [Document.IDValue] = []

        for report in surgeryPlan.surgeryReport {
            documentsToDelete.append(report)
        }

        if let implantsModels = surgeryPlan.implantsModels {
            documentsToDelete.append(implantsModels)
        }

        if let imagesBoneStress = surgeryPlan.imagesBoneStress {
            for image in imagesBoneStress {
                documentsToDelete.append(image)
            }
        }

        if let imagesImplantStress = surgeryPlan.imagesImplantStress {
            for image in imagesImplantStress {
                documentsToDelete.append(image)
            }
        }

        if let imagesDensity = surgeryPlan.imagesDensity {
            for image in imagesDensity {
                documentsToDelete.append(image)
            }
        }

        if let finalReport = surgeryPlan.finalReport {
            documentsToDelete.append(finalReport)
        }

        if let surgeryGuide = surgeryPlan.surgeryGuide {
            documentsToDelete.append(surgeryGuide)
        }

        if let resultsBoneStress = surgeryPlan.resultsBoneStress {
            for result in resultsBoneStress {
                documentsToDelete.append(result)
            }
        }

        if let resultsImplantStress = surgeryPlan.resultsImplantStress {
            for result in resultsImplantStress {
                documentsToDelete.append(result)
            }
        }

        if let resultsDensity = surgeryPlan.resultsDensity {
            for result in resultsDensity {
                documentsToDelete.append(result)
            }
        }

        if let resultsBoneQualityPercentage = surgeryPlan.resultsBoneStress {
            for result in resultsBoneQualityPercentage {
                documentsToDelete.append(result)
            }
        }

        if let otherResults = surgeryPlan.otherResults {
            documentsToDelete.append(otherResults)
        }

        let docsToDelete = Array(Set(documentsToDelete))

        for document in docsToDelete {
            try await deleteRelatedDocument(document, on: req)
        }

        try await surgeryPlan.delete(force: true, on: req.db)
        return .noContent
    }

    /// Delete a specific document related to a surgery plan
    /// - Parameter document: The `Document.IDValue` representing the document to be deleted.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Throws: An error if the document cannot be found or if the database deletion fails.
    /// - Note: This function checks if the document exists in the database and deletes it if it does.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the document is deleted from the database.
    ///     Use this function only if you want to delete a specific document related to a surgery plan.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///   Deleting a document will remove it from the database.
    ///   Ensure that you have proper backups and authorization before using this function.
    private func deleteRelatedDocument(_ document: Document.IDValue, on req: Request) async throws {
		if let doc = try await DocumentController().getOptionalDocument(with: document, on: req.db) {
			_ = try await DocumentController().delete(document: doc, on: req)
		}
    }
}
