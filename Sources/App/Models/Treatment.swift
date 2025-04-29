//
//  Treatment.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Fluent
import Vapor

// TODO: Create relation between Treatment and Patient
final class Treatment: Model, Content, @unchecked Sendable {
    static let schema = Treatment.V20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: Treatment.V20240618.date)
    var date: String

    @Field(key: Treatment.V20240618.affectedBoneEnum)
    var affectedBone: AffectedBone

    @Field(key: Treatment.V20240618.dicomID)
    var dicomID: Document.IDValue

    @Field(key: Treatment.V20240618.model3Ds)
    var model3Ds: [Document.IDValue]

    @Parent(key: Treatment.V20240618.patientID)
    var patient: Patient

    @Children(for: \.$treatment)
    var surgeryPlans: [SurgeryPlan]

    init() { }

    init(
		id: UUID? = nil,
		date: String,
		affectedBone: AffectedBone,
		patientID: Patient.IDValue,
		dicomID: Document.IDValue,
		model3Ds: [Document.IDValue]) {
			self.id = id
			self.date = date
			self.affectedBone = affectedBone
			self.$patient.id = patientID
			self.dicomID = dicomID
			self.model3Ds = model3Ds
    }

	func toOutput() throws -> Treatment.Output {
		let surgeryPlanIDs = try self.surgeryPlans.map { try $0.requireID() }
		return Treatment.Output(id: id,
								date: date,
								affectedBone: affectedBone,
								dicomID: dicomID,
								model3Ds: model3Ds,
								patientID: $patient.id,
								surgeryPlans: surgeryPlanIDs)
	}
}
