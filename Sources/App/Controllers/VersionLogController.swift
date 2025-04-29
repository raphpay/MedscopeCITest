//
//  VersionLogController.swift
//  Medscope
//
//  Created by Raphaël Payet on 14/10/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

struct VersionLogController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Group the routes under the "api" path
        let versionLogs = routes.grouped("api").grouped(APIKeyCheckMiddleware())
        // Group the routes under the "versionLogs" path
        versionLogs
            .group(
                tags: TagObject(
                    name: "versionLogs",
                    description: "Everything about version log"
                )
            ) { routes in
                // Define middlewares for token-based authentication and user guard
                let tokenAuthMiddleware = Token.authenticator()
                let guardAuthMiddleware = User.guardMiddleware()
                let tokenAuthGroup = routes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
                // POST: Create a new version log
                tokenAuthGroup.post(use: create)
                    .openAPI(
                        summary: "Create a new version log",
                        description: "Create a new version log. Could only be one in the API",
                        body: .type(VersionLog.Input.self),
                        contentType: .application(.json),
						response: .type(VersionLog.Output.self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "unauthorized.role")

                // GET: Get the version log
                routes.get(use: get)
                    .openAPI(
                        summary: "Get the version log",
						response: .type(VersionLog.Output.self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "notFound.versionLog")

                // UPDATE: Update the version log
                tokenAuthGroup.put(use: update)
                    .openAPI(
                        summary: "Update the version log",
                        body: .type(VersionLog.UpdateInput.self),
                        contentType: .application(.json),
						response: .type(VersionLog.Output.self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "notFound.versionLog")
                    .response(statusCode: .notFound, description: "unauthorized.role")

                // PUT: Update the version log's package
                tokenAuthGroup.put("package", use: updatePackage)
                    .openAPI(
                        summary: "Update the version log's package",
                        body: .type(VersionLog.PackageUpdateInput.self),
                        contentType: .application(.json),
						response: .type(VersionLog.Output.self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "notFound.versionLog")
                    .response(statusCode: .notFound, description: "unauthorized.role")

                // PUT: Reset the version log's package
                tokenAuthGroup.put("reset", "package", use: resetPackage)
                    .openAPI(
                        summary: "Reset the version log's package",
                        body: .type(VersionLog.UpdateInput.self),
                        contentType: .application(.json),
						response: .type(VersionLog.Output.self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "notFound.versionLog")
                    .response(statusCode: .notFound, description: "unauthorized.role")
            }
    }

    // MARK: - CREATE
    /// Create a new version log
    /// - Parameter req: The incoming request containing the version log information.
    /// - Returns: A `VersionLog` object representing the created version log.
    /// - Throws: An error if the version log cannot be created or if the database query fails.
    @Sendable
	func create(req: Request) async throws -> VersionLog.Output {
        // TODO: Merge with 116 code
        // TODO: Enable company operator too
        try Utils.checkAdminRole(on: req)
        let input = try req.content.decode(VersionLog.Input.self)

        if try await !VersionLog.query(on: req.db).all().isEmpty {
            throw Abort(.conflict, reason: "conflict.versionLogAlreadyExists")
        }

        let versionLog = input.toModel(timestamp: .now)
        try await versionLog.save(on: req.db)

		return versionLog.toOutput()
    }

    // MARK: - READ
    /// Get the version log
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `VersionLog` object representing the retrieved version log.
    /// - Throws: An error if the database query fails.
    @Sendable
	func get(req: Request) async throws -> VersionLog.Output {
		try await get(on: req).toOutput()
    }

    // MARK: - UPDATE
    /// Update the version log
    /// - Parameter req: The incoming request containing the version log ID and updated information.
    /// - Returns: A `VersionLog` object representing the updated version log.
    /// - Throws: An error if the version log cannot be found or if the database update fails.
    /// - Note: This function is used to update the version log's information.
    @Sendable
	func update(req: Request) async throws -> VersionLog.Output {
        try Utils.checkAdminRole(on: req)
        let versionLog = try await get(on: req)

        let updateInput = try req.content.decode(VersionLog.UpdateInput.self)
        let updatedVersionLog = try updateInput.update(versionLog)

        try await updatedVersionLog.update(on: req.db)

		return updatedVersionLog.toOutput()
    }

    /// Update the version log's package
    /// - Parameter req: The incoming request containing the version log ID and updated package information.
    /// - Returns: A `VersionLog` object representing the updated version log.
    /// - Throws: An error if the version log cannot be found or if the database update fails.
    /// - Note: This function is used to update the package version of the version log.
    @Sendable
	func updatePackage(req: Request) async throws -> VersionLog.Output {
        try Utils.checkAdminRole(on: req)
        let versionLog = try await get(on: req)

        let input = try req.content.decode(VersionLog.PackageUpdateInput.self).package

        versionLog.package = input
        try await versionLog.update(on: req.db)

		return versionLog.toOutput()
    }

    /// Reset the version log's package
    /// - Parameter req: The incoming request containing the version log ID and updated information.
    /// - Returns: A `VersionLog` object representing the updated version log.
    /// - Throws: An error if the version log cannot be found or if the database update fails.
    /// - Note: This function is used to reset the package version of the version log.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///     It ensures that the version log is updated and the package version is reset.
    @Sendable
	func resetPackage(req: Request) async throws -> VersionLog.Output {
        try Utils.checkAdminRole(on: req)
        let versionLog = try await get(on: req)
        versionLog.package = 0
        try await versionLog.update(on: req.db)
		return versionLog.toOutput()
    }
}

extension VersionLogController {
    /// Get the version log
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `VersionLog` object representing the retrieved version log.
    /// - Throws: An error if the database query fails.
    /// - Note: This function retrieves the version log from the database using the provided ID.
    ///     It returns the first matching version log found in the database.
    ///     If no matching version log is found, it throws a `notFound` error.
    func get(on req: Request) async throws -> VersionLog {
        guard let versionLog = try await VersionLog.query(on: req.db).first() else {
            throw Abort(.notFound, reason: "notFound.versionLog")
        }

        return versionLog
    }
}
