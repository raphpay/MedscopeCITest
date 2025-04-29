//
//  UserController.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI
import SendGridKit

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Group the routes under the "api" path
        let users = routes.grouped("api").grouped(APIKeyCheckMiddleware())
        // POST
        try registerPostRoutes(users)
        // GET
        try registerGetRoutes(users)
        // UPDATE
        try registerUpdateRoutes(users)
        // DELETE
        try registerDeleteRoutes(users)
    }
}

extension UserController {
	private func registerPostRoutes(_ routes: RoutesBuilder) throws {
		routes.group(tags: TagObject(name: "users",
									 description: "Everything about users")) { userRoutes in

			let tokenAuthMiddleware = Token.authenticator()
			let guardAuthMiddleware = User.guardMiddleware()
			let tokenAuthGroup = userRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

			// POST: Create a new user
			tokenAuthGroup.post(use: create)
				.openAPI(
					summary: "Create a new user",
					description: "Create a new user with the provided information",
					body: .type(User.Input.self),
					contentType: .application(.json),
					response: .type(User.PublicOutput.self),
					responseContentType: .application(.json)
				)
				.response(statusCode: .badRequest, description: "User already exists")

			// TODO: Should be included in documentation
			// TODO: Should be renamed to register
			// POST: Create a new user without authentication
			routes.post("first", use: create)
				.excludeFromOpenAPI()
		}
	}

	private func registerGetRoutes(_ routes: RoutesBuilder) throws {
		routes.group(tags: TagObject(name: "users",
									 description: "Everything about users")) { userRoutes in

			let tokenAuthMiddleware = Token.authenticator()
			let guardAuthMiddleware = User.guardMiddleware()
			let tokenAuthGroup = userRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

			// GET: Retrieve all users
			tokenAuthGroup.get(use: getAll)
				.openAPI(
					summary: "Get all users",
					response: .type([User.PublicOutput].self),
					responseContentType: .application(.json)
				)

			// GET: Retrieve a specific user by ID
			tokenAuthGroup.get(":userID", use: getUser)
				.openAPI(
					summary: "Get a user by ID",
					description: "Retrieve a specific user's information using their unique ID",
					response: .type(User.PublicOutput.self),
					responseContentType: .application(.json)
				)
				.response(statusCode: .badRequest, description: "Missing or wrong user ID format")
				.response(statusCode: .notFound, description: "User not found")

			// GET: Retrieve a specific user by email
			tokenAuthGroup.get("patients", ":userID", use: getPatients)
				.openAPI(
					summary: "Get a user's list of patient",
					description: "Retrieve a user's list of patients using their unique ID",
					response: .type([Patient.Output].self),
					responseContentType: .application(.json)
				)
				.response(statusCode: .badRequest, description: "Missing or wrong user ID format")
				.response(statusCode: .notFound, description: "User not found")

			// GET: Retrieve a specific patient by ID
			tokenAuthGroup.get(":userID", "patient", ":patientID", use: getPatient)
				.openAPI(
					summary: "Check if the user has access to the patient",
					description: "If the user has access, return the patient, else, return an error",
					response: .type(Patient.Output.self),
					responseContentType: .application(.json)
				)
				.response(statusCode: .badRequest, contentType: "Missing or wrong user ID format")
				.response(statusCode: .badRequest, contentType: "Missing or wrong patient ID format")
				.response(statusCode: .notFound, contentType: "User not found")
				.response(statusCode: .notFound, contentType: "Patient not found")
				.response(statusCode: .expectationFailed, contentType: "User has no access to the patient")
		}
	}

	private func registerUpdateRoutes(_ routes: RoutesBuilder) throws {
		routes.group(tags: TagObject(name: "users",
									 description: "Everything about users")) { userRoutes in

			let tokenAuthMiddleware = Token.authenticator()
			let guardAuthMiddleware = User.guardMiddleware()
			let tokenAuthGroup = userRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
			// UPDATE: Modify a user
			tokenAuthGroup.put(":userID", use: update)
				.openAPI(
					summary: "Modify a user",
					description: "Update a specific user's information using their unique ID",
					response: .type(User.self),
					responseContentType: .application(.json)
				)
				.response(statusCode: .badRequest, description: "Missing or wrong user ID format")
				.response(statusCode: .badRequest, description: "Wrong mail format")
				.response(statusCode: .notFound, description: "User not found")

			// UPDATE: Modify a user's mail address
			tokenAuthGroup.put("mail", ":userID", use: updateUserMailAddress)
				.openAPI(
					summary: "Modify a user mail address",
					description: "Update a specific user's mail address using their unique ID",
					response: .type(User.PublicOutput.self),
					responseContentType: .application(.json)
				)
				.response(statusCode: .badRequest, description: "Missing or wrong user ID format")
				.response(statusCode: .badRequest, description: "User already exists")
				.response(statusCode: .notFound, description: "User not found")
		}
	}

	private func registerDeleteRoutes(_ routes: RoutesBuilder) throws {
		routes.group(tags: TagObject(name: "users",
									 description: "Everything about users")) { userRoutes in

			let tokenAuthMiddleware = Token.authenticator()
			let guardAuthMiddleware = User.guardMiddleware()
			let tokenAuthGroup = userRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
			// DELETE: Remove a user
			tokenAuthGroup.delete("all", use: deleteAll)
				.openAPI(
					summary: "Remove all users",
					description: "Delete all users from the database",
					response: .type(HTTPResponseStatus.self),
					responseContentType: .application(.json)
				)

			// DELETE: Remove a specific user
			tokenAuthGroup.delete(":userID", use: delete)
				.openAPI(
					summary: "Remove a specific user",
					description: "Delete a user from the database",
					response: .type(HTTPResponseStatus.self),
					responseContentType: .application(.json)
				)
				.response(statusCode: .badRequest, description: "Missing or wrong user ID format")
				.response(statusCode: .notFound, description: "User not found")
		}
	}
}

extension UserController {
    // MARK: - CREATE
    /// Create a new user
    /// - Parameter req: The incoming request containing the user information.
    /// - Returns: A `User.PublicOutput` object representing the created user.
    /// - Throws: An error if the user cannot be created or if the database query fails.
    /// - Note: This function validates the input parameters and creates a new user with the provided information.
    ///        It also hashes the password before saving it to the database.
    @Sendable
    func create(req: Request) async throws -> User.PublicOutput {
        let input = try req.content.decode(User.Input.self)
        let userOutput = try await create(input: input, on: req.db)
        return userOutput
    }

    // MARK: - READ
    /// Retrieve all users
    /// - Parameter req: The incoming request.
    /// - Returns: An array of `User.PublicOutput` objects representing the retrieved users.
    /// - Throws: An error if the database query fails.
    /// - Note: This function fetches all users from the database and returns their public output.
    ///        It is intended for use by admin users only.
    /// - Warning: This function should only be called by admin users.
    @Sendable
    func getAll(req: Request) async throws -> [User.PublicOutput] {
        var users: [User.PublicOutput] = []
        let savedUsers = try await User.query(on: req.db).all()
        for user in savedUsers {
            let userOutput = try user.toPublicOutput()
            users.append(userOutput)
        }

        return users
    }

    /// Retrieve a specific user by ID
    /// - Parameter req: The incoming request containing the user ID.
    /// - Returns: A `User.PublicOutput` object representing the retrieved user.
    /// - Throws: An error if the user cannot be found or if the database query fails.
    @Sendable
    func getUser(req: Request) async throws -> User.PublicOutput {
        let userID = try await getUserID(on: req)
        let user = try await getUser(userID, on: req)
        return try user.toPublicOutput()
    }

    /// Retrieve a specific user's patients
    /// - Parameter req: The incoming request containing the user ID.
    /// - Returns: An array of `Patient` objects representing the retrieved patients.
    /// - Throws: An error if the user cannot be found or if the database query fails.
    /// - Note: This function fetches all patients associated with the user from the database.
    @Sendable
    func getPatients(req: Request) async throws -> [Patient] {
        let userID = try await getUserID(on: req)
        let user = try await getUser(userID, on: req)

        return try await user
            .$patients
            .get(on: req.db)
    }

    /// Retrieve a specific patient by ID
    /// - Parameter req: The incoming request containing the patient ID.
    /// - Returns: A `Patient` object representing the retrieved patient.
    /// - Throws: An error if the patient cannot be found or if the database query fails.
    /// - Note: This function retrieves the patient by its ID from the database and returns it as a `Patient` object.
    ///       It also checks if the user has access to the patient.
    ///       Only the user linked to the patient can access it.
    @Sendable
    func getPatient(req: Request) async throws -> Patient {
        let userID = try await getUserID(on: req)
        let user = try await getUser(userID, on: req)

        guard let patientID = req.parameters.get("patientID", as: Patient.IDValue.self) else {
            throw Abort(.badRequest, reason: "missingOrIncorrectPatientID")
        }

        let patient = try await PatientController().getPatient(patientID, on: req)

        let isLinked = try await user.$patients.query(on: req.db)
            .filter(\.$id == patientID)
            .first() != nil

        guard isLinked else {
            throw Abort(.expectationFailed, reason: "expectationFailed.userNotLinkedToPatient")
        }

        return patient
    }

    // MARK: - UPDATE
    /// Update a user
    /// - Parameter req: The incoming request containing the user ID and updated information.
    /// - Returns: A `User.PublicOutput` object representing the updated user.
    /// - Throws: An error if the user cannot be found or if the database update fails.
    /// - Note: This function updates the user with the provided information.
    ///     It first retrieves the user by its ID from the database.
    ///     It then updates the user with the provided information.
    ///     If the user is not found, it throws a `notFound` error.
    ///     If the database update fails, it throws an error.
    ///     If the user does not have the required role to perform the update, it throws an `unauthorized` error.
    @Sendable
    func update(req: Request) async throws -> User.PublicOutput {
        let userID = try await getUserID(on: req)
        let user = try await getUser(userID, on: req)
        var updatedUser = user

        let updatedInput = try req.content.decode(User.UpdateInput.self)

        if updatedInput.role != nil {
            let authenticatedUser = try Utils.getAuthenticatedUser(on: req)
            if authenticatedUser.role == .admin,
               let role = updatedInput.role {
                updatedUser = updatedInput.updateRole(on: user, with: role)
            } else {
                throw Abort(.unauthorized, reason: "unauthorized.role")
            }
        }

        try await UserUpdateMiddleware().validate(userInput: updatedInput, on: req.db)
        updatedUser = try updatedInput.update(updatedUser)

        try await updatedUser.update(on: req.db)

        return try user.toPublicOutput()
    }

    /// Update a user's mail address
    /// - Parameter req: The incoming request containing the user ID and updated mail address.
    /// - Returns: A `User.PublicOutput` object representing the updated user.
    /// - Throws: An error if the user cannot be found or if the database update fails.
    @Sendable
    func updateUserMailAddress(req: Request) async throws -> User.PublicOutput {
        let userID = try await getUserID(on: req)
        let user = try await getUser(userID, on: req)

        let updatedUserMailAddress = try req.content.decode(String.self)
        try await UserMiddleware().checkUserAvailability(mailAddress: updatedUserMailAddress, on: req.db)

        user.mailAddress = updatedUserMailAddress
        try await user.update(on: req.db)

        return try user.toPublicOutput()
    }

    // MARK: - DELETE
    /// Delete all users
    /// - Parameter req: The incoming request.
    /// - Returns: An HTTP response status indicating the result of the operation.
    /// - Throws: An error if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves all users from the database, and deletes each user one by one. It returns a 204 No Content status upon successful deletion of all users.
    /// - Important: This function should be called with caution and should only be used by administrators.
    /// - Warning: This function deletes all users from the database, including the authenticated user. Use with caution.
    @Sendable
    func deleteAll(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        let users = try await User
            .query(on: req.db)
            .all()

        for user in users {
            _ = try await delete(user: user, on: req)
        }

        return .noContent
    }

    /// Delete a specific user
    /// - Parameter req: The incoming request containing the user ID.
    /// - Returns: An HTTP response status indicating the result of the operation.
    /// - Throws: An error if the user cannot be found or if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves a user by its ID from the database, and deletes it. It returns a 204 No Content status upon successful deletion of the user.
    /// - Important: This function should be called with caution and should only be used by administrators.
    /// - Warning: This function deletes the specified user from the database. Use with caution.
    @Sendable
    func delete(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        let userID = try await getUserID(on: req)
        let user = try await getUser(userID, on: req)
        return try await delete(user: user, on: req)
    }
}

// MARK: - Utils
extension UserController {
    /// Create a new user
    /// - Parameters:
    ///   - input: The `User.Input` containing the user information.
    ///   - db: The database connection to use for creating the user.
    /// - Returns: A `User.PublicOutput` object representing the created user.
    /// - Throws: An error if the user cannot be created or if the database query fails.
    /// - Note: This function validates the input parameters and creates a new user with the provided information.
    ///        It also hashes the password before saving it to the database.
    func create(input: User.Input, on db: Database) async throws -> User.PublicOutput {
        try await UserMiddleware().validate(userInput: input, on: db)
        // Validate password
        do {
            try PasswordValidation().validatePassword(input.password)
        } catch {
            throw error
        }
        let passwordHash = try Bcrypt.hash(input.password)
        let user = input.toModel(with: passwordHash)

        try await user.save(on: db)
        return try user.toPublicOutput()
    }

    /// Retrieve a user by ID
    /// - Parameters:
    ///   - id: The ID of the user to be retrieved.
    ///   - req: The incoming request containing the database connection.
    /// - Returns: A `User` object representing the retrieved user.
    /// - Throws: An error if the user cannot be found or if the database query fails.
    func getUser(_ id: User.IDValue, on req: Request) async throws -> User {
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }

        return user
    }
}

// MARK: - Private Utils
extension UserController {
    /// Retrieve the user ID from the request parameters.
    /// - Parameter req: The incoming request containing the user ID.
    /// - Returns: A `User.IDValue` representing the retrieved user ID.
    /// - Throws: An error if the user ID is missing or if the request parameters cannot be parsed.
    /// - Note: This function retrieves the user ID from the request parameters using the `userID` key.
    ///     It returns the value of the `userID` key as a `User.IDValue`.
    ///     If the `userID` key is not found, it throws a `badRequest` error.
    private func getUserID(on req: Request) async throws -> User.IDValue {
        guard let userID = req.parameters.get("userID", as: User.IDValue.self) else {
            throw Abort(.badRequest, reason: "badRequest.missingUserID")
        }

        return userID
    }

    /// Retrieve a user by email
    /// - Parameters:
    ///   - email: The email of the user to be retrieved.
    ///   - db: The database connection to use for retrieving the user.
    /// - Returns: A `User` object representing the retrieved user.
    /// - Throws: An error if the user cannot be found or if the database query fails.
    /// - Note: This function retrieves the user by its email from the database.
    ///       It returns the user object if found.
    ///       If the user is not found, it throws a `notFound` error.
    ///       If the database query fails, it throws an error.
    private func getUser(with email: String, on db: Database) async throws -> User {
        guard let user = try await User.query(on: db).filter(\.$mailAddress == email).first() else {
            throw Abort(.notFound, reason: "notFound.user")
        }

        return user
    }

    /// Delete a user
    /// - Parameters:
    ///   - user: The `User` object representing the user to be deleted.
    ///   - req: The incoming request containing the database connection.
    /// - Returns: An HTTP response status indicating the result of the operation.
    /// - Throws: An error if the user cannot be found or if the database deletion fails.
    /// - Note: This function deletes a user from the database.
    ///     It first retrieves the user by its ID from the database.
    ///     It then deletes the user from the database.
    ///     If the user is not found, it throws a `notFound` error.
    ///     If the database deletion fails, it throws an error.
    /// - Important: This function should be called with caution and should only be used by administrators.
    /// - Warning: This function deletes the specified user from the database. Use with caution.
    func delete(user: User, on req: Request) async throws -> HTTPResponseStatus {
        // Delete all user's patients ( cascade )
        let patients = try await user.$patients.query(on: req.db).all()
        for patient in patients {
            _ = try await PatientController().delete(patient: patient, on: req)
        }
        // Delete user
        try await user.delete(force: true, on: req.db)

        return .noContent
    }
}
