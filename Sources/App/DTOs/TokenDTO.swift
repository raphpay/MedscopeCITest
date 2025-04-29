//
//  TokenDTO.swift
//
//
//  Created by Raphaël Payet on 01/08/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

extension Token {
	/// Output structure for returning a `Token` model.
	///
	/// This structure is used to expose only the necessary fields of a token, typically in authentication contexts.
	/// It contains the token's ID and the associated user's ID.
	/// Conforms to `Content` and `WithExample` for use in API responses and OpenAPI documentation.
	struct Output: Content, WithExample {
		let id: Token.IDValue
		let userID: User.IDValue

		static var example: Output {
			.init(
				id: UUID(),
				userID: UUID()
			)
		}
	}
}

extension Token {
	/// Convert a Token to an Output
	/// - Parameter id: The ID of the Token
	/// - Returns: An Output representing the Token
	func toPublicOutput(id: Token.IDValue) throws -> Token.Output {
		let userID = self.$user.id
		return Token.Output(id: id, userID: userID)
	}
}
