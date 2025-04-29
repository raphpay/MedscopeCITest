//
//  Formulaire.swift
//  
//
//  Created by Raphaël Payet on 31/07/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

final class Form: Model, Content, @unchecked Sendable {
    static let schema = Form.V20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: Form.V20240618.user)
    var user: User

    @Field(key: Form.V20240618.patient)
    var patient: Patient

    @Field(key: Form.V20240618.treatment)
    var treatment: Treatment

    @Field(key: Form.V20240618.surgeryPlans)
    var surgeryPlans: [SurgeryPlan]

    init() {}

    init(id: UUID? = nil, user: User, patient: Patient, treatment: Treatment, surgeryPlans: [SurgeryPlan]) {
        self.id = id
        self.user = user
        self.patient = patient
        self.treatment = treatment
        self.surgeryPlans = surgeryPlans
    }
}
