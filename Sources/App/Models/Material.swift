//
//  Material.swift
//
//
//  Created by Raphaël Payet on 26/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

final class Material: Model, Content, @unchecked Sendable, WithExample {
    static let schema = Material.V20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: Material.V20240618.matName)
    var matName: String

    @Field(key: Material.V20240618.e)
    var e: Float

    @Field(key: Material.V20240618.nu)
    var nu: Float

    @Field(key: Material.V20240618.sigmaDam)
    var sigmaDam: Float

    @Field(key: Material.V20240618.sigmaFa)
    var sigmaFa: Float

    init() { }

    init(id: UUID? = nil,
         matName: String,
         e: Float, nu: Float,
         sigmaDam: Float, sigmaFa: Float
    ) {
        self.id = id
        self.matName = matName
        self.e = e
        self.nu = nu
        self.sigmaDam = sigmaDam
        self.sigmaFa = sigmaFa
    }

    static let example: Material = .init(
        id: UUID(),
        matName: "Concrete",
        e: 87.0,
        nu: 0.3,
        sigmaDam: 762.0,
        sigmaFa: 212.0
    )

    func toOutput() -> Material.Output {
        .init(
            id: id ?? UUID(),
            matName: matName,
            e: e,
            nu: nu,
            sigmaDam: sigmaDam,
            sigmaFa: sigmaFa
        )
    }
}
