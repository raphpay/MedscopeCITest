//
//  PasswordResetTokenDTO.swift
//
//
//  Created by Raphaël Payet on 05/11/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

extension PasswordResetToken {
    /// The DTO for the password reset token.
	struct RequestInput: Content, WithExample {
        let toEmail: String
        let fromMail: String
        let fromName: String
        let replyTo: String?
        let subject: String
        let apiKey: String

        /// Creates the content for the email.
        func createContent(with resetToken: String) -> String {
            "Your reset token is : \(resetToken)"
        }

		static var example: RequestInput {
			.init(toEmail: "johndoe@example.com",
				  fromMail: "medscope@email.com",
				  fromName: "John Doe",
				  replyTo: "John Doe", subject: "Test email",
				  apiKey: "IUH8UHIH37")
		}
    }

    /// The DTO for the password reset token.
    struct ResetPasswordRequest: Content, WithExample{
        let token: String
        let newPassword: String

		static var example: ResetPasswordRequest {
			.init(token: "UH7Y7Y3", newPassword: "Passwordlong1(")
		}
    }
}
