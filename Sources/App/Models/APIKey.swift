//
//  APIKey.swift
//
//
//  Created by Raphaël Payet on 13/07/2024.
//

import Fluent
import Vapor

final class APIKey: Model, Content, @unchecked Sendable {
    static let schema = APIKey.V20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: APIKey.V20240618.name)
    var name: String

    @Field(key: APIKey.V20240618.value)
    var value: String

    init() { }

    init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}
