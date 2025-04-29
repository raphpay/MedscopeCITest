//
//  Token.swift
//
//
//  Created by Raphaël Payet on 30/07/2024.
//

import Vapor
import Fluent

final class Token: Model, Content, @unchecked Sendable {
    static let schema = Token.V20240618.schemaName

    @ID
    var id: UUID?

    @Field(key: Token.V20240618.value)
    var value: String

    @Parent(key: Token.V20240618.userID)
    var user: User

    init() {}

    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}
