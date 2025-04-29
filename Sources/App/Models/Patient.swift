//
//  Patient.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Fluent
import Vapor

final class Patient: Model, Content, @unchecked Sendable {
	static let schema = Patient.V20240618.schemaName

	@ID(key: .id)
	var id: UUID?

	@Field(key: Patient.V20240618.name)
	var name: String

	@Field(key: Patient.V20240618.firstName)
	var firstName: String

	@Field(key: Patient.V20240618.birthdate)
	var birthdate: String

	@Enum(key: Patient.V20240618.genderEnum)
	var gender: Gender

	@Field(key: Patient.V20240618.laGalaxyID)
	var laGalaxyID: String? // TODO: To be removed

	@Field(key: Patient.V20240823.medscopeID)
	var medscopeID: String

	@Parent(key: Patient.V20240618.userID)
	var user: User

	@Children(for: \.$patient)
	var treatments: [Treatment]

	init() { }

	init(
		id: UUID? = nil,
		name: String,
		firstName: String,
		birthdate: String,
		gender: Gender,
		userID: User.IDValue,
		medscopeID: String,
		laGalaxyID: String? = nil) {
			self.id = id
			self.name = name.trimAndLowercase()
			self.firstName = firstName.trimAndLowercase()
			self.birthdate = birthdate
			self.gender = gender
			self.$user.id = userID
			self.medscopeID = medscopeID
			self.laGalaxyID = laGalaxyID
	}

	func toOutput() -> Patient.Output {
		.init(id: self.id,
			  name: self.name,
			  firstName: self.firstName,
			  birthdate: self.birthdate,
			  gender: self.gender,
			  medscopeID: self.medscopeID,
			  userID: self.$user.id,
			  laGalaxyID: laGalaxyID
		)
	}
}
