//
//  User.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class User: Model, Content, @unchecked Sendable, WithExample {
    static let schema = User.V20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: User.V20240618.name)
    var name: String

    @Field(key: User.V20240618.firstName)
    var firstName: String

    @OptionalField(key: User.V20240618.address)
    var address: String?

    @Field(key: User.V20240618.mailAddress)
    var mailAddress: String

    @Field(key: User.V20240618.password)
    var password: String

	@Field(key: User.V20240618.roleEnum)
    var role: Role

    @Field(key: User.V20241129.conditionsAccepted)
    var conditionsAccepted: Bool

    @OptionalField(key: User.V20241129.conditionsAcceptedTimestamp)
    var conditionsAcceptedTimestamp: String?

    @Field(key: User.V20241216.loginFailedAttempts)
    var loginFailedAttempts: Int

    @OptionalField(key: User.V20241216.lastLoginFailedAttempt)
    var lastLoginFailedAttempt: String?

    @Children(for: \.$user)
    var patients: [Patient]

    @Children(for: \.$user)
    var tokens: [Token]

    init() { }

    init(
		id: UUID? = nil,
		name: String,
		firstName: String,
		address: String? = nil,
		mailAddress: String,
		password: String, role: Role,
		conditionsAccepted: Bool,
		conditionsAcceptedTimestamp: String? = nil,
		loginFailedAttempts: Int,
		lastLoginFailedAttempt: String? = nil
    ) {
		self.id = id
        self.name = name
        self.firstName = firstName
        self.address = address
        self.mailAddress = mailAddress
        self.password = password
        self.role = role
        self.conditionsAccepted = conditionsAccepted
        self.conditionsAcceptedTimestamp = conditionsAcceptedTimestamp
        self.loginFailedAttempts = loginFailedAttempts
        self.lastLoginFailedAttempt = lastLoginFailedAttempt
    }

	static var example: User {
		User(
			name: "Doe",
			firstName: "John",
			mailAddress: "john_doe@example.com",
			password: "Passwordlong12(",
			role: .user,
			conditionsAccepted: true,
			loginFailedAttempts: 0
		)
	}
}
