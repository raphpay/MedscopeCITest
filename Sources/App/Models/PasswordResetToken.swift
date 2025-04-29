//
//  PasswordResetToken.swift
//
//
//  Created by Raphaël Payet on 05/11/2024.
//

import Fluent
import Vapor

final class PasswordResetToken: Model, Content, @unchecked Sendable {
    static let schema = PasswordResetToken.V20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: PasswordResetToken.V20240618.token)
    var token: String

    @Parent(key: PasswordResetToken.V20240618.userID)
    var user: User

    @Field(key: PasswordResetToken.V20240618.userEmail)
    var userEmail: String

    @Field(key: PasswordResetToken.V20240618.expiresAt)
    var expiresAt: Date

    init() { }

    init(id: UUID? = nil, token: String, userId: User.IDValue, userEmail: String, expiresAt: Date) {
        self.id = id
        self.token = token
        self.$user.id = userId
        self.userEmail = userEmail
        self.expiresAt = expiresAt
    }

    /// A public representation of the PasswordResetToken model.
    struct Public: Content {
        let id: UUID?
        let userID: User.IDValue
        let userEmail: String
        let expiresAt: Date
    }
}
