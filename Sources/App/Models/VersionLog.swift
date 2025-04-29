//
//  VersionLog.swift
//  Medscope
//
//  Created by Raphaël Payet on 14/10/2024.
//

import Fluent
import Vapor

final class VersionLog: Model, Content, @unchecked Sendable {
    static let schema = VersionLog.V20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: VersionLog.V20240618.interface)
    var interface: String
    
    @Field(key: VersionLog.V20240618.api)
    var api: String
    
    @Field(key: VersionLog.V20240618.calculator)
    var calculator: String
    
    @Field(key: VersionLog.V20241216.package)
    var package: Int
    
    @Field(key: VersionLog.V20241216.packageUpdateTimestamp)
    var packageUpdateTimestamp: Date
    
    @Field(key: VersionLog.V20241216.udi)
    var udi: String

    init() { }

    init(id: UUID? = nil,
         interface: String,
         api: String,
         calculator: String,
         package: Int,
         packageUpdateTimestamp: Date,
         udi: String
    ) {
        self.id = id
        self.interface = interface
        self.api = api
        self.calculator = calculator
        self.package = package
        self.packageUpdateTimestamp = packageUpdateTimestamp
        self.udi = udi
    }

	func toOutput() -> VersionLog.Output {
		.init(id: UUID(),
			  interface: interface,
			  api: api,
			  calculator: calculator,
			  package: package,
			  packageUpdateTimestamp: packageUpdateTimestamp,
			  udi: udi)
	}
}
