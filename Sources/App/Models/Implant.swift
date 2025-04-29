//
//  Implant.swift
//
//
//  Created by Raphaël Payet on 25/06/2024.
//

import Fluent
import Vapor

final class Implant: Model, Content, @unchecked Sendable {
    static let schema = Implant.V20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: Implant.V20240618.reference)
    var reference: String

    @Field(key: Implant.V20240618.internalDiam)
    var internalDiam: Float

    @Field(key: Implant.V20240618.abutmentContactHeight)
    var abutmentContactHeight: Float

    @Field(key: Implant.V20240618.diameter)
    var diameter: Float

    @Field(key: Implant.V20240618.hneck)
    var hneck: Float

    @Field(key: Implant.V20240618.length)
    var length: Float

    @Field(key: Implant.V20240618.matName)
    var matName: String

    @Field(key: Implant.V20240618.upCenter)
    var upCenter: [Float]

    @Field(key: Implant.V20240618.centerZ)
    var centerZ: [Float]

    @Field(key: Implant.V20240618.upIndex)
    var upIndex: [Float]

    @Field(key: Implant.V20240618.modelID)
    var modelID: Document.IDValue

    init() { }

    init(
        id: UUID? = nil,
        reference: String,
        internalDiam: Float, abutmentContactHeight: Float, diameter: Float, hneck: Float, length: Float,
        matName: String,
        upCenter: [Float], centerZ: [Float], upIndex: [Float],
        modelID: Document.IDValue
    ) {
        self.id = id
        self.reference = reference
        self.internalDiam = internalDiam
        self.abutmentContactHeight = abutmentContactHeight
        self.diameter = diameter
        self.hneck = hneck
        self.length = length
        self.matName = matName
        self.upCenter = upCenter
        self.centerZ = centerZ
        self.upIndex = upIndex
        self.modelID = modelID
    }

	func toOutput() -> Implant.Output {
		.init(id: id,
			  reference: reference,
			  internalDiam: internalDiam,
			  abutmentContactHeight: abutmentContactHeight,
			  diameter: diameter,
			  hneck: hneck,
			  length: length,
			  matName: matName,
			  upCenter: upCenter,
			  centerZ: centerZ,
			  upIndex: upIndex,
			  modelID: modelID)
	}
}
