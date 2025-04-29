//
//  TokenController.swift
//
//
//  Created by Raphaël Payet on 30/07/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

struct TokenController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        // Group routes under "/api" and apply APIKeyCheckMiddleware for authentication
        let tokens = routes.grouped("api").grouped(APIKeyCheckMiddleware())
        // Group routes under "/api/tokens" and apply authentication and user guard middlewares
        tokens.group(
            tags: TagObject(
                name: "tokens",
                description: "Everything about tokens"
            )
        ) { routes in
            // DELETE: Logout
            routes.delete("logout", ":tokenID", use: logout)
            // Defines middlewares for basic authentication
            let basicAuthMiddleware = User.authenticator()
            let basicAuthGroup = routes.grouped(basicAuthMiddleware)
            // POST: Login
            basicAuthGroup.post("login", use: login)
                .openAPI(
                    summary: "Create a new token",
                    description: "Authenticate a user with its mail address and password",
					response: .type(Token.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .unauthorized, description: "unauthorized.login.invalidCredentials")

            // Defines middlewares for bearer authentication
            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = routes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
            // GET: Get all tokens
            tokenAuthGroup.get("all", use: getTokens)
                .openAPI(
                    summary: "Get all tokens",
                    response: .type([Token.Output].self),
                    responseContentType: .application(.json)
                )

            // GET: Get a specific token
            tokenAuthGroup.get(":tokenID", use: getTokenByID)
                .openAPI(
                    summary: "Get a specific token",
                    response: .type(Token.Output.self),
                    responseContentType: .application(.json)
                )
            // DELETE: Remove a specific token
            tokenAuthGroup.delete(":remove", "tokenID", use: removeByID)
                .openAPI(
                    summary: "Remove a specific token",
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )
            // DELETE: Remove all tokens
            tokenAuthGroup.delete("all", use: removeAll)
                .openAPI(
                    summary: "Remove all tokens",
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )
        }
    }

    // MARK: - READ
    /// Get all tokens
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An array of `Token.Output` objects representing the retrieved tokens.
    /// - Throws: An error if the database query fails.
    /// - Note: This function retrieves all tokens from the database and returns them as an array of `Token.Output` objects.
    /// - Important: This function should be called with caution and should only be used by administrators.
    @Sendable
    func getTokens(req: Request) async throws -> [Token.Output] {
        var tokenOutputs: [Token.Output] = []
        let tokens = try await Token.query(on: req.db).all()
        for token in tokens {
            let tokenID = try token.requireID()
            let tokenOutput = try token.toPublicOutput(id: tokenID)
            tokenOutputs.append(tokenOutput)
        }

        return tokenOutputs
    }

    /// Get a specific token by ID
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `Token.Output` object representing the retrieved token.
    /// - Throws: An error if the token cannot be found or if the database query fails.
    /// - Note: This function retrieves a token by its ID from the database and returns it as a `Token.Output` object.
    /// - Important: This function should be called with caution and should only be used by administrators.
    @Sendable
    func getTokenByID(req: Request) async throws -> Token.Output {
        guard let token = try await Token.find(req.parameters.get("tokenID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.token")
        }

        let tokenID = try token.requireID()
        return try token.toPublicOutput(id: tokenID)
    }

    // MARK: - Login
    /// Login a user and generate a token
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `Token` object representing the generated token.
    /// - Throws: An error if the user cannot be found or if the password is invalid.
    /// - Note: This function extracts the credentials from the Authorization header using the decodeBasicAuth function.
    ///     It then fetches the user based on the email address from the database.
    ///     If the user is not found, it throws a `notFound` error.
    ///     If the password is invalid, it throws an `unauthorized` error.
    ///     If the user has exceeded the maximum login attempts, it throws an `unauthorized` error.
    ///     If the last failed login attempt is not nil, it checks if the user is locked out.
    ///     If the user is locked out, it throws an `forbidden` error.
    ///     If the user is not locked out, it updates the user's last failed login attempt and saves it to the database.
    ///     It then generates a new token and saves it to the database.
    ///     The function returns the generated token.
    @Sendable
    func login(req: Request) async throws -> Token {
        // 1. Extract credentials from the Authorization header (Basic Auth)
        let credentials = try decodeBasicAuth(req.headers)

        // Fetch the user based on the email address
        guard let user = try await User.query(on: req.db)
            .filter(\.$mailAddress == credentials.mailAddress)
            .first() else {
                throw Abort(.notFound, reason: "notFound.user")
        }

        try await handleMaxLoginAttempt(user: user, on: req)

        let newToken = try await verifyPassword(credentials: credentials, user: user, on: req)
        return newToken
    }

    /// Logout a user and delete the token
    /// - Parameter req: The incoming request containing the token ID.
    /// - Returns: An `HTTPStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the token cannot be found or if the database deletion fails.
    /// - Note: This function retrieves the token by its ID from the database.
    ///     It then deletes the token from the database.
    ///     If the token is not found, it throws a `notFound` error.
    @Sendable
    func logout(req: Request) async throws -> HTTPStatus {
        guard let token = try await Token.find(req.parameters.get("tokenID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.token")
        }

        try await token.delete(force: true, on: req.db)
        return .noContent
    }

    // MARK: - Delete
    /// Remove a specific token by ID
    /// - Parameter req: The incoming request containing the token ID.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the token cannot be found or if the database deletion fails.
    /// - Note: This function retrieves the token by its ID from the database.
    ///     It then deletes the token from the database.
    ///     If the token is not found, it throws a `notFound` error.
    ///     If the database deletion fails, it throws an error.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the token is deleted from the database.
    ///     Use this function only if you want to delete a specific token.
    @Sendable
    func removeByID(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        let tokenID = try await getTokenID(on: req)
        let token = try await getToken(tokenID, on: req.db)

        try await token.delete(force: true, on: req.db)

        return .noContent
    }

    /// Remove all tokens
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the database deletion fails.
    /// - Note: This function retrieves all tokens from the database and deletes them one by one.
    ///     If the database deletion fails, it throws an error.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that all tokens are deleted from the database.
    ///     Use this function only if you want to delete all tokens.
    @Sendable
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        try await Token.query(on: req.db)
            .all()
            .delete(force: true, on: req.db)

        return .noContent
    }
}

extension TokenController {
    /// Get a token by ID
    /// - Parameter id: The ID of the token to be retrieved.
    /// - Parameter db: The database connection to use for retrieving the token.
    /// - Returns: A `Token` object representing the retrieved token.
    /// - Throws: An error if the token cannot be found or if the database query fails.
    /// - Note: This function retrieves a token by its ID from the database and returns it as a `Token` object.
    /// - Important: This function should be called with caution and should only be used by administrators.
    func getToken(_ id: Token.IDValue, on database: Database) async throws -> Token {
        guard let token = try await Token.find(id, on: database) else {
            throw Abort(.notFound, reason: "notFound.token")
        }
        return token
    }

    /// Get the token ID from the request parameters.
    /// - Parameter req: The incoming request containing the token ID.
    /// - Returns: A `Token.IDValue` representing the retrieved token ID.
    /// - Throws: An error if the token ID is missing or if the request parameters cannot be parsed.
    /// - Note: This function retrieves the token ID from the request parameters using the `tokenID` key.
    ///     It returns the value of the `tokenID` key as a `Token.IDValue`.
    ///     If the `tokenID` key is not found, it throws a `badRequest` error.
    ///     If the request parameters cannot be parsed, it throws a `badRequest` error.
    /// - Important: This function should be called with caution and should only be used by administrators.
    private func getTokenID(on req: Request) async throws -> Token.IDValue {
        guard let tokenID = req.parameters.get("userID", as: Token.IDValue.self) else {
            throw Abort(.badRequest, reason: "badRequest.missingTokenID")
        }

        return tokenID
    }

    /// Decode the basic authentication credentials from the request headers.
    /// - Parameter headers: The HTTP headers containing the Authorization header.
    /// - Returns: A tuple containing the decoded mail address and password.
    /// - Throws: An error if the Authorization header is missing or if the Authorization header is not in the correct format.
    /// - Note: This function extracts the Authorization header from the request headers.
    ///     It checks that the Authorization header starts with "Basic".
    ///     If the Authorization header does not start with "Basic", it throws a `unauthorized` error.
    ///     It then extracts the base64 encoded part of the Authorization header.
    ///     If the base64 encoded part is not valid, it throws a `unauthorized` error.
    ///     It then decodes the base64 encoded string into data.
    ///     If the decoding fails, it throws a `unauthorized` error.
    ///     Finally, it splits the decoded string into username (email) and password.
    ///     It returns a tuple containing the decoded mail address and password.
    private func decodeBasicAuth(_ headers: HTTPHeaders) throws -> (mailAddress: String, password: String) {
        // Get the Authorization header from the request headers
        guard let authHeader = headers.first(name: .authorization) else {
            throw Abort(.unauthorized, reason: "unauthorized.missingAuthorizationHeader")
        }

        // Check that the Authorization header starts with "Basic"
        guard authHeader.lowercased().hasPrefix("basic ") else {
            throw Abort(.unauthorized, reason: "unauthorized.invalidAuthorizationHeader")
        }

        // Extract the base64 encoded part of the Authorization header
        let base64String = authHeader.dropFirst(6) // Drop "Basic " prefix

        // Decode the base64 encoded string into data
        guard let data = Data(base64Encoded: String(base64String)) else {
            throw Abort(.unauthorized, reason: "unauthorized.wrongAuthorizationHeader")
        }

        // Convert the decoded data into a UTF-8 string
        guard let decodedString = String(data: data, encoding: .utf8) else {
            throw Abort(.unauthorized, reason: "unauthorized.wrongAuthorizationHeaderData")
        }

        // Split the decoded string into username (email) and password
        let components = decodedString.split(separator: ":")
        guard components.count == 2 else {
            throw Abort(.unauthorized, reason: "unauthorized.invalidAuthorizationFormat")
        }

        // Return the username (email) and password
        let mailAddress = String(components[0])
        let password = String(components[1])

        return (mailAddress, password)
    }

    /// Handle the maximum login attempts for a user.
    /// - Parameter user: The `User` object representing the user to be checked.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Throws: An error if the user cannot be found or if the database query fails.
    /// - Note: This function checks if the user has exceeded the maximum login attempts.
    ///     If the user has exceeded the maximum login attempts, it checks if the user's last failed login attempt is not nil.
    ///     If the last failed login attempt is not nil, it sets up an ISO8601 date formatter with appropriate options.
    ///     It then checks if the user's last failed login attempt is within the lockout duration.
    ///     If the user is locked out, it throws a `forbidden` error.
    ///     If the user is not locked out, it updates the user's login failed attempts and last failed login attempt.
    ///     It then saves the updated user to the database.
    private func handleMaxLoginAttempt(user: User, on req: Request) async throws {
        // Define max attempts and lockout duration
        let maxAttempts = 5
        let lockoutDuration: TimeInterval = 24 * 60 * 60 // 24 hours in seconds
        // Check if the user has exceeded the max login attempts
        if user.loginFailedAttempts >= maxAttempts {
            if let lastFailed = user.lastLoginFailedAttempt {
                // Setup ISO8601 date formatter with appropriate options
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]

                if let lastFailedDate = formatter.date(from: lastFailed) {
                    // Check if the user is locked out
                    if Date().timeIntervalSince(lastFailedDate) < lockoutDuration {
                        // User is still locked out
                        throw Abort(.forbidden, reason: "forbidden.tooManyFailedAttempts")
                    } else {
                        // Lockout period has passed, reset attempts
                        user.loginFailedAttempts = 0
                        user.lastLoginFailedAttempt = nil
                        try await user.save(on: req.db)  // Save reset
                    }
                } else {
                    throw Abort(.unauthorized, reason: "unauthorized.invalidLastFailedTimestamp")
                }
            }
        }
    }

    /// Verify the password for a user.
    /// - Parameters:
    ///   - credentials: A tuple containing the mail address and password.
    ///   - user: The `User` object representing the user to be checked.
    ///   - req: The incoming request containing the database connection.
    /// - Returns: A `Token` object representing the generated token.
    /// - Throws: An error if the password is invalid or if the database query fails.
    /// - Note: This function verifies the password for a user.
    ///     It first checks if the password is valid using the Bcrypt library.
    ///     If the password is valid, it resets the user's login failed attempts and last failed login attempt.
    ///     It then generates a new token and saves it to the database.
    ///     The function returns the generated token.
    private func verifyPassword(credentials: (mailAddress: String, password: String), user: User, on req: Request) async throws -> Token {
        // Verify the password
        if try Bcrypt.verify(credentials.password, created: user.password) {
            // Successful login, reset failed attempts
            user.loginFailedAttempts = 0
            user.lastLoginFailedAttempt = nil
            try await user.save(on: req.db)

            // Generate or update the token
            let token = try await Token
                .query(on: req.db)
                .filter(\.$user.$id == user.id!)
                .first()

            if let token = token {
                token.value = [UInt8].random(count: 16).base64
                try await token.update(on: req.db)
                return token
            } else {
                // If no token exists, create a new one
                let newToken = try Token.generate(for: user)
                try await newToken.save(on: req.db)
                return newToken
            }
        } else {
            // Failed login attempt
            user.loginFailedAttempts += 1

            // Get current timestamp in desired ISO 8601 format with fractional seconds
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let currentTimestamp = formatter.string(from: Date())

            user.lastLoginFailedAttempt = currentTimestamp
            try await user.save(on: req.db)

            // Throw unauthorized error
            throw Abort(.unauthorized, reason: "unauthorized.invalidCredentials")
        }
    }
}
