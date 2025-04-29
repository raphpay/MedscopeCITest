//
//  ImplantController.swift
//
//
//  Created by Raphaël Payet on 25/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

struct ImplantController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Group routes under "/api" and apply APIKeyCheckMiddleware for authentication
        let implants = routes.grouped("api").grouped(APIKeyCheckMiddleware())
        // POST
        try registerPostRoutes(implants)
        // GET
        try registerGetRoutes(implants)
        // UPDATE
        try registerUpdateRoutes(implants)
        // DELETE
        try registerDeleteRoutes(implants)
    }
}

extension ImplantController {
    private func registerPostRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "implants",
                                     description: "Everything about implants")) { implantRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = implantRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
            // POST: Create a new implant
            tokenAuthGroup.post(use: create)
                .openAPI(
                    summary: "Create a new implant",
                    description: "Create a new implant and attach it to a surgery plan",
                    body: .type(Implant.Input.self),
                    contentType: .application(.json),
					response: .type(Implant.Output.self),
                    responseContentType: .application(.json)
                )
        }
    }

    private func registerGetRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "implants",
                                     description: "Everything about implants")) { implantRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = implantRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // GET: Retrive all implants
            tokenAuthGroup.get(use: getAll)
                .openAPI(
                    summary: "Get all implants",
					response: .type([Implant.Output].self),
                    responseContentType: .application(.json)
                )

            // GET : Retrieve an implant by its reference
            tokenAuthGroup.get("by", "reference", ":reference", use: getByReference)
                .openAPI(
                    summary: "Get an implant by its reference",
					response: .type(Implant.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, contentType: "Implant not found")

            // GET : Retrieve the material associated to a specific implant
            tokenAuthGroup.get("material", ":implantID", use: getMaterial)
                .openAPI(
                    summary: "Get the material a specific implant",
                    response: .type(Material.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Implant not found")
                .response(statusCode: .notFound, description: "Material not found")

            tokenAuthGroup.get("model", "by", "reference", ":reference", use: getModelByReference)
                .openAPI(
                    summary: "Get the model associated to a specific implant",
                    response: .type(Document.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Implant not found")
                .response(statusCode: .notFound, description: "Document not found")

            // GET : Retrieve the download token for a specific model associated to a specific implant
            tokenAuthGroup.get("download", "token", "for", "model", ":reference",
                               use: getDownloadTokenForModel)
                .openAPI(
                    summary: "Get the download token for a specific model associated to a specific implant",
                    response: .type(Document.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Implant not found")
                .response(statusCode: .notFound, description: "Document not found")
        }
    }

    private func registerUpdateRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "implants",
                                     description: "Everything about implants")) { implantRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = implantRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // UPDATE: Update a specific implant
            tokenAuthGroup.put(":reference", use: update)
                .openAPI(
                    summary: "Update a specific implant",
                    body: .type(Implant.UpdateInput.self),
                    contentType: .application(.json),
                    response: .type(Implant.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Implant not found")
                .response(statusCode: .notFound, description: "Document not found")
                .response(statusCode: .unauthorized,
                          description: "User role not authorized to perform the action")
        }
    }

    private func registerDeleteRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "implants",
                                     description: "Everything about implants")) { implantRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = implantRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // DELETE: Delete all implants
            tokenAuthGroup.delete(use: deleteAll)
                .openAPI(
                    summary: "Delete all implants",
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )

            // DELETE: Delete a specific implant
            tokenAuthGroup.delete(":implantID", use: delete)
                .openAPI(
                    summary: "Delete a specific implant",
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Implant not found")
        }
    }
}

extension ImplantController {
    // MARK: - CREATE
    /// Create a new implant
    /// - Parameter req: The incoming request containing the implant information.
    /// - Returns: An `Implant` object representing the created implant.
    /// - Throws: An error if the implant cannot be created or if the database query fails.
    @Sendable
    func create(req: Request) async throws -> Implant.Output {
        let input = try req.content.decode(Implant.Input.self)
        try await ImplantMiddleware().validate(implantInput: input, on: req.db)

        let implant = input.toModel()
        try await implant.save(on: req.db)
		return implant.toOutput()
    }

    // MARK: - READ
    /// Retrieve all implants.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An array of `Implant` objects representing the retrieved implants.
    /// - Throws: An error if the database query fails.
    @Sendable
    func getAll(req: Request) async throws -> [Implant.Output] {
        let implants = try await Implant.query(on: req.db).all()
		return implants.map { $0.toOutput() }
    }

    /// Retrieve an implant by its reference.
    /// - Parameter req: The incoming request containing the reference of the implant.
    /// - Returns: An `Implant` object representing the retrieved implant.
    /// - Throws: An error if the implant cannot be found or if the database query fails.
    /// - Note: This function retrieves the implant by filtering the `Implant` table using the reference provided in the request parameters.
    ///     It returns the first matching implant found in the database.
    ///     If no matching implant is found, it throws a `notFound` error.
    ///     If the reference is not provided, it throws a `badRequest` error.
    @Sendable
    func getByReference(req: Request) async throws -> Implant.Output {
        let reference = try getReferenceFrom(req)
		return try await getByReference(reference, on: req.db).toOutput()
    }

    /// Retrieve the material associated to a specific implant.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `Material` object representing the retrieved material.
    /// - Throws: An error if the implant or material cannot be found or if the database query fails.
    /// - Note: This function retrieves the material associated with the implant by filtering the `Material` table using the implant's `matName`.
    ///      It returns the first matching material found in the database.
    ///      If no matching material is found, it throws a `notFound` error.
    ///      If the implant is not found, it throws a `notFound` error.
    @Sendable
    func getMaterial(req: Request) async throws -> Material.Output {
        let implant = try await getImplant(on: req)
        guard let material = try await Material
				.query(on: req.db)
				.filter(\.$matName == implant.matName)
				.first() else {
            throw Abort(.notFound, reason: "notFound.material")
        }

		return material.toOutput()
    }

    /// Retrieve the model associated to a specific implant.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `Document` object representing the retrieved model.
    /// - Throws: An error if the implant or model cannot be found or if the database query fails.
    /// - Note: This function retrieves the model associated with the implant by filtering the `Document` table using the implant's `modelID`.
    ///      It returns the first matching model found in the database.
    ///      If no matching model is found, it throws a `notFound` error.
    ///      If the implant is not found, it throws a `notFound` error.
    @Sendable
    func getModelByReference(req: Request) async throws -> Document.Output {
      try await getAssociatedDocument(req: req).toOutput()
    }

    /// Retrieve the download token for a specific model associated to a specific implant.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `String` representing the download token.
    /// - Throws: An error if the implant or model cannot be found or if the database query fails.
    /// - Note: This function retrieves the download token for the model associated with the implant by filtering the `Document` table using the implant's `modelID`.
    ///      It returns the first matching download token found in the database.
    ///      If no matching download token is found, it throws a `notFound` error.
    ///      If the implant is not found, it throws a `notFound` error.
    ///      If the model is not found, it throws a `notFound` error.
    ///      If the download token is not found, it throws a `notFound` error.
    @Sendable
    func getDownloadTokenForModel(req: Request) async throws -> String {
        let doc = try await getAssociatedDocument(req: req)
        let path = doc.path + doc.name
        return try await DocumentController().getDownloadToken(at: path, on: req)
    }

    // MARK: - UPDATE
    /// Update a specific implant.
    /// - Parameter req: The incoming request containing the updated implant information.
    /// - Returns: An `Implant` object representing the updated implant.
    /// - Throws: An error if the implant cannot be updated or if the database query fails.
    /// - Note: This function updates the implant with the provided information.
    ///     It first retrieves the implant by its reference from the database.
    ///     It then updates the implant with the provided information.
    ///     If the implant is not found, it throws a `notFound` error.
    ///     If the database query fails, it throws an error.
    ///    If the user does not have the required role to perform the update, it throws an `unauthorized` error.
    @Sendable
    func update(req: Request) async throws -> Implant.Output {
        let authUser = try req.auth.require(User.self)

        guard authUser.role != .user else {
            throw Abort(.unauthorized, reason: "unauthorized.role")
        }

        let reference = try getReferenceFrom(req)
        let implant = try await getByReference(reference, on: req.db)

        let updateInput = try req.content.decode(Implant.UpdateInput.self)

        try await ImplantUpdateMiddleware().validate(implantInput: updateInput, on: req.db)

        let updatedImplant = try await updateInput.update(implant, on: req.db)
        try await updatedImplant.update(on: req.db)

		return updatedImplant.toOutput()
    }

    // MARK: - DELETE
    /// Delete all implants.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves all implants from the database, and deletes each implant one by one. It returns a 204 No Content status upon successful deletion of all implants.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the implants are deleted from the database, including their associated models and documents.
    ///     Use this function only if you want to delete all implants from the database.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting all implants will remove all associated models and documents from the database.
    ///     Ensure that you have proper backups and authorization before using this function.
    @Sendable
    func deleteAll(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        let implants = try await Implant.query(on: req.db).all()

        for implant in implants {
            _ = try await delete(implant, on: req)
        }

        return .noContent
    }

    /// gDelete a specific implant.
    /// - Parameter req: The incoming request containing the implant ID.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the implant cannot be found or if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves an implant by its ID from the database, and deletes it. It returns a 204 No Content status upon successful deletion of the implant.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the implant is deleted from the database, including its associated model and document.
    ///     Use this function only if you want to delete a specific implant from the database.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting an implant will remove its associated model and document from the database.
    ///     Ensure that you have proper backups and authorization before using this function.
    @Sendable
    func delete(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        let implant = try await getImplant(on: req)
        return try await delete(implant, on: req)
    }
}

// MARK: - Utils
extension ImplantController {
    /// Retrieve an implant by its ID.
    /// - Parameter req: The incoming request containing the implant ID.
    /// - Returns: An `Implant` object representing the retrieved implant.
    /// - Throws: An error if the implant cannot be found or if the database query fails.
    /// - Note: This function retrieves an implant by its ID from the database using the provided ID.
    ///     It returns the first matching implant found in the database.
    ///     If no matching implant is found, it throws a `notFound` error.
    ///     If the ID is not provided, it throws a `badRequest` error.
    func getImplant(on req: Request) async throws -> Implant {
        guard let implant = try await Implant.find(req.parameters.get("implantID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.implant")
        }

        return implant
    }

    /// Retrieve an implant by its reference.
    /// - Parameter ref: The reference of the implant to be retrieved.
    /// - Parameter db: The database connection to use for retrieving the implant.
    /// - Returns: An `Implant` object representing the retrieved implant.
    /// - Throws: An error if the implant cannot be found or if the database query fails.
    /// - Note: This function retrieves an implant by its reference from the database using the provided reference.
    ///     It returns the first matching implant found in the database.
    ///     If no matching implant is found, it throws a `notFound` error.
    func getByReference(_ ref: String, on db: Database) async throws -> Implant {
        guard let implant = try await Implant.query(on: db).filter(\.$reference == ref).first() else {
            throw Abort(.notFound, reason: "notFound.implant")
        }
        return implant
    }

    /// Retrieve the model associated to a specific implant.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `Document` object representing the retrieved model.
    /// - Throws: An error if the implant or model cannot be found or if the database query fails.
    /// - Note: This function retrieves the model associated with the implant by filtering the `Document` table using the implant's `modelID`.
    ///      It returns the first matching model found in the database.
    ///      If no matching model is found, it throws a `notFound` error.
    ///      If the implant is not found, it throws a `notFound` error.
    ///      If the model is not found, it throws a `notFound` error.
    ///     If the download token is not found, it throws a `notFound` error.
    func getAssociatedDocument(req: Request) async throws -> Document {
        let reference = try getReferenceFrom(req)
        let implant = try await getByReference(reference, on: req.db)
        return try await DocumentController().getDocument(with: implant.modelID, on: req.db)
    }

    /// Retrieve the reference from the request parameters.
    /// - Parameter req: The incoming request containing the reference.
    /// - Returns: A `String` representing the retrieved reference.
    /// - Throws: An error if the reference is not provided or if the request parameters cannot be parsed.
    /// - Note: This function retrieves the reference from the request parameters using the `reference` key.
    ///     It returns the value of the `reference` key as a `String`.
    ///     If the `reference` key is not found, it throws a `badRequest` error.
    ///     If the request parameters cannot be parsed, it throws a `badRequest` error.
    func getReferenceFrom(_ req: Request) throws -> String {
        guard let reference = req.parameters.get("reference", as: String.self) else {
            throw Abort(.badRequest, reason: "badRequest.reference")
        }

        return reference
    }

    /// Delete an implant.
    /// - Parameter implant: The `Implant` object to be deleted.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the implant cannot be found or if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves an implant by its ID from the database, and deletes it. It returns a 204 No Content status upon successful deletion of the implant.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the implant is deleted from the database, including its associated model and document.
    ///     Use this function only if you want to delete a specific implant from the database.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting an implant will remove its associated model and document from the database.
    ///    Ensure that you have proper backups and authorization before using this function.
    func delete(_ implant: Implant, on req: Request) async throws -> HTTPResponseStatus {
		let doc = try await DocumentController().getDocument(with: implant.modelID, on: req.db)
		let _ = try await DocumentController().delete(document: doc, on: req)

        try await implant.delete(force: true, on: req.db)

        return .noContent
    }
}
