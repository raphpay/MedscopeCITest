//
//  PasswordResetTokenController.swift
//
//
//  Created by Raphaël Payet on 05/11/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI
import SendGridKit

struct PasswordResetTokenController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
      // Group routes under "/api" and apply APIKeyCheckMiddleware for authentication
        let passwordResetTokens = routes.grouped("api").grouped(APIKeyCheckMiddleware())
        // Group routes under "/api/passwordResetTokens" and apply authentication and user guard middlewares
        passwordResetTokens.group(
            tags: TagObject(
                name: "passwordResetTokens",
                description: "Everything about password reset tokens"
            )
        ) { routes in
            // POST: Request a new password token
            routes.post("request", use: requestPasswordReset)
                .openAPI(
                    summary: "Request a new password token",
                    description: "Send via email a token to change the user's password",
                    body: .type(PasswordResetToken.RequestInput.self),
                    contentType: .application(.json),
                    response: .type(String.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "User not found")

            // POST: Reset a password
            routes.post("reset", use: resetPassword)
                .openAPI(
                    summary: "Reset a password",
                    description: "reset a password by checking the token and the new password validity",
                    body: .type(PasswordResetToken.ResetPasswordRequest.self),
                    contentType: .application(.json),
                    response: .type(HTTPStatus.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .badRequest, description: "Token expired")
                .response(statusCode: .notFound, description: "Reset token not found")
                .response(statusCode: .notFound, description: "User not found")

        }
    }

    // MARK: - Create
    /// Request a new password token
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: A `String` representing the email sent.
    /// - Throws: An error if the user cannot be found or if the database query fails.
    /// - Note: This function retrieves the user with the provided email address from the database.
    ///     It then generates a new password reset token and saves it to the database.
    ///     The function also sends an email to the user with a link to reset their password.
    @Sendable
    func requestPasswordReset(req: Request) async throws -> String {
        let input = try req.content.decode(PasswordResetToken.RequestInput.self)

        guard let user = try await User.query(on: req.db)
            .filter(\.$mailAddress == input.toEmail)
            .first() else {
            throw Abort(.notFound, reason: "notFound.user")
        }

        let userID = try user.requireID()

        let token = try await PasswordResetToken
            .query(on: req.db)
            .filter(\.$user.$id == userID)
            .first()
        var currentToken: PasswordResetToken?

        if let existingToken = token {
            existingToken.token = PasswordResetToken.generate()
            existingToken.expiresAt = Date().addingTimeInterval(3600)
            currentToken = existingToken
            try await existingToken.update(on: req.db)
        } else {
            let token = PasswordResetToken.generate()
            let resetToken = PasswordResetToken(token: token,
                                                userId: userID,
                                                userEmail: input.toEmail,
                                                expiresAt: Date().addingTimeInterval(3600))
            currentToken = resetToken
            try await resetToken.save(on: req.db)
        }

        try await sendEmail(with: input, and: currentToken)

        return "Email sent"
    }

    /// Reset a password
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An `HTTPStatus` indicating that the password has been reset successfully.
    /// - Throws: An error if the reset token cannot be found or if the database query fails.
    /// - Note: This function retrieves the reset token from the database using the provided token.
    ///     It then validates the token and the new password.
    ///     If the token is valid, it hashes the new password and updates the user's password in the database.
    ///     If the token is not valid, it throws a `badRequest` error.
    ///     If the database query fails, it throws an error.
    @Sendable
    func resetPassword(req: Request) async throws -> HTTPStatus {
        let input = try req.content.decode(PasswordResetToken.ResetPasswordRequest.self)

        guard let token = try await PasswordResetToken.query(on: req.db)
            .filter(\.$token == input.token)
            .first() else {
            throw Abort(.notFound, reason: "notFound.resetToken")
        }

        guard token.expiresAt > Date() else {
            throw Abort(.badRequest, reason: "badRequest.tokenExpired")
        }

        do {
            try PasswordValidation().validatePassword(input.newPassword)
        } catch {
            throw error
        }

        // Hash the new password
        let hashedNewPassword = try Bcrypt.hash(input.newPassword)

        guard let user = try await User.find(token.$user.id, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }

        user.password = hashedNewPassword
        user.loginFailedAttempts = 0
        user.lastLoginFailedAttempt = nil
        try await user.update(on: req.db)

        try await token.delete(force: true, on: req.db)

        return .ok
    }
}

// MARK: - Utils
extension PasswordResetTokenController {
    /// Send an email with a link to reset the user's password.
    /// - Parameters:
    ///   - input: The `PasswordResetToken.RequestInput` containing the email address and other information.
    ///   - token: The `PasswordResetToken` object representing the reset token.
    /// - Throws: An error if the email cannot be sent or if the input validation fails.
    /// - Note: This function validates the input parameters and sends an email with the provided information.
    ///     It generates a unique reset token and saves it to the database.
    ///     The function also creates a new email with a link to reset the user's password.
    ///     The email is sent using the SendGrid API.
    func sendEmail(with input: PasswordResetToken.RequestInput, and token: PasswordResetToken?) async throws {
        guard let token = token else {
            throw Abort(.internalServerError, reason: "Unable to generate reset token")
        }

        try EmailMiddleware().validate(tos: [input.toEmail], from: input.fromMail)

        let from = EmailAddress(email: input.fromMail, name: input.fromName)
        let replyTo: EmailAddress
        if let replyToInput = input.replyTo {
            replyTo = EmailAddress(email: replyToInput)
        } else {
            replyTo = EmailAddress(email: input.fromMail)
        }

        let tos = EmailMiddleware().createToArray(tos: [input.toEmail])
        let contentValue = input.createContent(with: token.token)
        let content = EmailContent(type:  "text/html", value: contentValue)

        let email = EmailController().createEmail(from: from,
                                                  tos: tos,
                                                  subject: input.subject,
                                                  content: content,
                                                  replyTo: replyTo)
        try await EmailController().send(email: email, sendGridApiKey: input.apiKey)
    }
}
