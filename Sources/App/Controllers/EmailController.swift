//
//  EmailController.swift
//
//
//  Created by Raphaël Payet on 02/08/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI
import SendGridKit

struct EmailController: RouteCollection {
    /// Defines the routes for the EmailController.
    func boot(routes: RoutesBuilder) throws {
        // Define the routes for email management
        let emails = routes.grouped("api").grouped(APIKeyCheckMiddleware())

        // Document the group of routes related to "documents"
        emails.group(
            tags: TagObject(
                name: "emails",
                description: "Everything about emails"
            )
        ) { routes in
            // POST: /api/emails/form
            routes.post("form", use: sendEmail)
                .openAPI(
                    summary: "Send an email with form informations",
                    description: "Send an email to the correct recipient",
                    body: .type(Email.self),
                    contentType: .application(.json),
                    response: .type(String.self),
                    responseContentType: .application(.json)
                )

            // POST: /api/emails/form/apiKey
            routes.post("form", "apiKey", use: sendEmailWithAPIKey)
                .openAPI(
                    summary: "Send an email with form informations",
                    description: "Send an email to the correct recipient",
                    body: .type(Email.Input.self),
                    contentType: .application(.json),
                    response: .type(String.self),
                    responseContentType: .application(.json)
                )

            // POST: /api/emails/custom/content
            routes.post("custom", "content", use: sendEmailWithCustomContent)
                .openAPI(
                    summary: "Send an email with custom content and subject",
                    description: "Send an email to the correct recipient",
                    body: .type(Email.Input.self),
                    contentType: .application(.json),
                    response: .type(String.self),
                    responseContentType: .application(.json)
                )
        }
    }

    // MARK: - CREATE
    /// Sends an email using the SendGrid API.
    ///
    /// This function validates the input parameters and sends an email with the given information. It returns a success message if the email is sent successfully.
    /// - Parameter req: The HTTP request containing the email information.
    /// - Returns: A `String` indicating that the email was sent successfully.
    /// - Throws: An error if the email cannot be sent or if the input validation fails.
    @Sendable
    func sendEmail(req: Request) async throws -> String {
        let input = try req.content.decode(Email.self)
		try EmailMiddleware().validate(tos: input.recipient, from: input.fromMail)

        let httpClient = HTTPClient()
        guard let apiKey = Environment.get("SENDGRID_API_KEY") else {
            throw Abort(.unauthorized, reason: "unauthorized.missingSendGridAPIKey")
        }
        let sendGridClient = SendGridClient(httpClient: httpClient, apiKey: apiKey)

        let from = EmailAddress(email: input.fromMail, name: input.fromName)
        let replyTo: EmailAddress
        if let replyToInput = input.replyTo {
            replyTo = EmailAddress(email: replyToInput)
        } else {
            replyTo = EmailAddress(email: input.fromMail)
        }

		let tos = EmailMiddleware().createToArray(tos: input.recipient)
        let contentValue = input.createContent()
        let content = EmailContent(type: "text/plain", value: contentValue)
        let subject = "MEDSCOPE : New case added"
        let personalization: Personalization = .init(to: tos, subject: subject)

        let email = SendGridEmail(personalizations: [personalization],
                                  from: from, replyTo: replyTo,
                                  subject: subject, content: [content])

        do {
            try await sendGridClient.send(email: email)
        } catch {
            try await httpClient.shutdown()
            throw Abort(.internalServerError, reason: error.localizedDescription)
        }

        try await httpClient.shutdown()

        return "success.emailSent"
    }

    /// Sends an email using the SendGrid API with a custom API key.
    ///
    /// This function validates the input parameters and sends an email with the given information. It returns a success message if the email is sent successfully.
    /// - Parameter req: The HTTP request containing the email information.
    /// - Returns: A `String` indicating that the email was sent successfully.
    /// - Throws: An error if the email cannot be sent or if the input validation fails.
    @Sendable
    func sendEmailWithAPIKey(req: Request) async throws -> String {
        let input = try req.content.decode(Email.Input.self)
        try EmailMiddleware().validate(tos: input.recipient, from: input.fromMail)

        let from = EmailAddress(email: input.fromMail, name: input.fromName)
        let replyTo: EmailAddress
        if let replyToInput = input.replyTo {
            replyTo = EmailAddress(email: replyToInput)
        } else {
            replyTo = EmailAddress(email: input.fromMail)
        }

		let tos = EmailMiddleware().createToArray(tos: input.recipient)
        let contentValue = input.createContent()
        let content = EmailContent(type: "text/plain", value: contentValue)
        let subject = "MEDSCOPE : New case added"

        let email = createEmail(from: from, tos: tos, subject: subject, content: content, replyTo: replyTo)
        try await send(email: email, sendGridApiKey: input.apiKey)

        return "success.emailSent"
    }

    /// Sends an email using the SendGrid API with custom content.
    ///
    /// This function validates the input parameters and sends an email with the given information. It returns a success message if the email is sent successfully.
    /// - Parameter req: The HTTP request containing the email information.
    /// - Returns: A `String` indicating that the email was sent successfully.
    /// - Throws: An error if the email cannot be sent or if the input validation fails.
    /// - Note: This function is used to send an email with custom content and subject.
    @Sendable
    func sendEmailWithCustomContent(req: Request) async throws -> String {
        let input = try req.content.decode(Email.CustomContentInput.self)
        try EmailMiddleware().validate(tos: input.recipient, from: input.fromMail)

        let from = EmailAddress(email: input.fromMail, name: input.fromName)
        let replyTo: EmailAddress
        if let replyToInput = input.replyTo {
            replyTo = EmailAddress(email: replyToInput)
        } else {
            replyTo = EmailAddress(email: input.fromMail)
        }

		let tos = EmailMiddleware().createToArray(tos: input.recipient)
        let content = EmailContent(type: input.isHTML ? "text/html" : "text/plain",
                                   value: input.content)

        let email = createEmail(from: from,
                                tos: tos,
                                subject: input.subject,
                                content: content,
                                replyTo: replyTo)
        try await send(email: email, sendGridApiKey: input.apiKey)

        return "success.emailSent"
    }
}

// MARK: - Utils
/// This extension provides utility functions for creating and sending emails using the SendGrid API.
extension EmailController {
    /// Creates an email object with the given parameters.
    ///
    /// - Parameters:
    ///   - from: The email address of the sender.
    ///   - tos: An array of email addresses to receive the email.
    ///   - subject: The subject of the email.
    ///   - content: The content of the email.
    ///   - replyTo: The email address to which the reply should be sent. If not provided, the email will be sent to the sender.
    ///   - Returns: A `SendGridEmail` object representing the email to be sent.
    ///   - Throws: An error if the email cannot be created.
    /// - Note: This function is used to create an email object with the specified parameters.
    /// - Important: The `replyTo` parameter is optional. If not provided, the email will be sent to the sender.
    /// - Warning: Ensure that the `from` and `tos` email addresses are valid and properly formatted.
    func createEmail(from: EmailAddress,
                     tos: [EmailAddress],
                     subject: String,
                     content: EmailContent,
                     replyTo: EmailAddress? = nil) -> SendGridEmail {
        let personalization: Personalization = .init(to: tos, subject: subject)

        var replyToEmailAddress = replyTo
        if replyToEmailAddress == nil { replyToEmailAddress = from }
        let email = SendGridEmail(personalizations: [personalization],
                                  from: from,
                                  replyTo: replyToEmailAddress,
                                  subject: subject,
                                  content: [content])

        return email
    }

    /// Sends an email using the SendGrid API.
    ///
    /// - Parameters:
    ///  - email: The `SendGridEmail` object representing the email to be sent.
    ///  - sendGridApiKey: The API key for the SendGrid API.
    /// - Throws: An error if the email cannot be sent.
    /// - Note: This function is used to send an email using the SendGrid API.
    func send(email: SendGridEmail, sendGridApiKey: String) async throws {
        let httpClient = HTTPClient()
        let sendGridClient = SendGridClient(httpClient: httpClient, apiKey: sendGridApiKey)

        do {
            try await sendGridClient.send(email: email)
        } catch {
            try await httpClient.shutdown()
            throw Abort(.internalServerError, reason: error.localizedDescription)
        }

        try await httpClient.shutdown()
    }
}
