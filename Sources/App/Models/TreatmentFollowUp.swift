//
//  TreatmentFollowUp.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

import Fluent
import Vapor

final class TreatmentFollowUp: Model, Content, @unchecked Sendable {
    static let schema = TreatmentFollowUp.V20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: TreatmentFollowUp.V20240618.creationDate)
    var creationDate: String

    @Field(key: TreatmentFollowUp.V20240618.treatmentID)
    var treatmentID: Treatment.IDValue

    @Field(key: TreatmentFollowUp.V20240618.status)
    var status: Status

    @OptionalField(key: TreatmentFollowUp.V20240618.calculationDate)
    var calculationDate: String?

    @OptionalField(key: TreatmentFollowUp.V20240618.operatorID)
    var operatorID: User.IDValue?

    @OptionalField(key: TreatmentFollowUp.V20240618.validationDate)
    var validationDate: String?

    @OptionalField(key: TreatmentFollowUp.V20240618.validatorID)
    var validatorID: User.IDValue?

    @OptionalField(key: TreatmentFollowUp.V20240618.firstOpenDate)
    var firstOpenDate: String?

    @OptionalField(key: TreatmentFollowUp.V20240618.versionInterface)
    var versionInterface: String?

    @OptionalField(key: TreatmentFollowUp.V20240618.versionCalculator)
    var versionCalculator: String?

    @OptionalField(key: TreatmentFollowUp.V20240618.versionSP)
    var versionSP: String?

    @OptionalField(key: TreatmentFollowUp.V20240618.versionAPI)
    var versionAPI: String?

    init() { }

    init(
		id: UUID? = nil,
		creationDate: String,
		treatmentID: Treatment.IDValue,
		status: Status,
		calculationDate: String? = nil,
		operatorID: User.IDValue? = nil,
		validationDate: String? = nil,
		validatorID: User.IDValue? = nil,
		firstOpenDate: String? = nil,
		versionInterface: String? = nil,
		versionCalculator: String? = nil,
		versionSP: String? = nil,
		versionAPI: String? = nil
    ) {
		self.id = id
        self.creationDate = creationDate
        self.treatmentID = treatmentID
        self.status = status
        self.calculationDate = calculationDate
        self.operatorID = operatorID
        self.validationDate = validationDate
        self.validatorID = validatorID
        self.firstOpenDate = firstOpenDate
        self.versionInterface = versionInterface
        self.versionCalculator = versionCalculator
        self.versionSP = versionSP
        self.versionAPI = versionAPI
    }

	func toOutput() -> TreatmentFollowUp.Output {
		.init(id: id,
			  creationDate: creationDate,
			  treatmentID: treatmentID,
			  status: status,
			  calculationDate: calculationDate,
			  operatorID: operatorID,
			  validationDate: validationDate,
			  validatorID: validatorID,
			  firstOpenDate: firstOpenDate,
			  versionInterface: versionInterface,
			  versionCalculator: versionCalculator,
			  versionSP: versionSP,
			  versionAPI: versionAPI)
	}
}
