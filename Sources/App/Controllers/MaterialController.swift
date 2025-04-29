//
//  MaterialController.swift
//
//
//  Created by Raphaël Payet on 26/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

struct MaterialController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Group the routes under the "api" path
        let materials = routes.grouped("api").grouped(APIKeyCheckMiddleware())

        // Group the routes under the "materials" path
        materials
            .group(
                tags: TagObject(
                    name: "materials",
                    description: "Everything about materials"
                )
            ) { routes in
                // Defines middlewares for token-based authentication and user guard
                let tokenAuthMiddleware = Token.authenticator()
                let guardAuthMiddleware = User.guardMiddleware()
                let tokenAuthGroup = routes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
                // POST: Create a new material
                tokenAuthGroup.post(use: create)
                    .openAPI(
                        summary: "Create a new material",
                        description: "Create a new material",
                        body: .type(Material.Input.self),
                        contentType: .application(.json),
                        response: .type(Material.self),
                        responseContentType: .application(.json)
                    )
                // GET: Get all materials
                tokenAuthGroup.get(use: getAll)
                    .openAPI(
                        summary: "Get all materials",
                        response: .type([Material.Output].self),
                        responseContentType: .application(.json)
                    )

                // UPDATE: Update a specific material
                tokenAuthGroup.put(":materialID", use: update)
                    .openAPI(
                        summary: "Update a specific material",
                        body: .type(Material.UpdateInput.self),
                        contentType: .application(.json),
                        response: .type(Material.Output.self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "Material not found")

                // DELETE: Delete all materials
                tokenAuthGroup.delete(use: deleteAll)
                    .openAPI(
                        summary: "Delete all implants",
                        response: .type(HTTPResponseStatus.self),
                        responseContentType: .application(.json)
                    )
            }
    }

    // MARK: - CREATE
    /// Creates a new material
    /// - Parameter req: The incoming request containing the material information.
    /// - Returns: A `Material` object representing the created material.
    /// - Throws: An error if the material creation fails.
    @Sendable
    func create(req: Request) async throws -> Material {
        let input = try req.content.decode(Material.Input.self)
        let material = input.toModel()
        try await material.save(on: req.db)

        return material
    }

    // MARK: - READ
    /// Retrieves all materials from the database.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An array of `Material` objects representing the retrieved materials.
    /// - Throws: An error if the database query fails.
    @Sendable
    func getAll(req: Request) async throws -> [Material] {
        try await Material.query(on: req.db).all()
    }

    // MARK: - UPDATE
    /// Updates a specific material in the database.
    /// - Parameter req: The incoming request containing the material ID and updated information.
    /// - Returns: A `Material` object representing the updated material.
    /// - Throws: An error if the material cannot be found or if the database update fails.
    /// - Note: The material ID is extracted from the request parameters.
    /// - Note: The updated information is provided in the request body.
    @Sendable
    func update(req: Request) async throws -> Material.Output {
        guard let material = try await Material.find(req.parameters.get("materialID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.material")
        }

        let updateInput = try req.content.decode(Material.UpdateInput.self)
        let updatedMaterial = updateInput.update(material)

        try await updatedMaterial.update(on: req.db)

        return updatedMaterial.toOutput()
    }

    // MARK: - DELETE
    /// Deletes all materials from the database.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves all materials from the database, and deletes each material one by one. It returns a 204 No Content status upon successful deletion of all materials.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the materials are deleted from the database, including their associated documents.
    ///     Use this function only if you want to delete all materials from the database.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting all materials will remove all associated documents from the database.
    ///     Ensure that you have proper backups and authorization before using this function.
    @Sendable
    func deleteAll(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        try await Material.query(on: req.db).all().delete(force: true, on: req.db)

        return .noContent
    }
}
