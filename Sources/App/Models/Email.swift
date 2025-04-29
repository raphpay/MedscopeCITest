//
//  File.swift
//
//
//  Created by Raphaël Payet on 02/08/2024.
//

import Fluent
import Vapor
import SendGridKit
import VaporToOpenAPI

struct Email: Content, OpenAPIDescriptable {
    let recipient: [String]
    let fromMail: String
    let fromName: String // Can be only fromMail
    let replyTo: String?
    let userName: String
    let patientID: Patient.IDValue
    let treatmentID: Treatment.IDValue
    let surgeryPlansCount: Int
    let surgeryPlanIDs: [SurgeryPlan.IDValue]?

    static var openAPIDescription: OpenAPIDescriptionType? {
        OpenAPIDescription<CodingKeys>("Email request body.")
			.add(for: .recipient, "Username string.")
            .add(for: .fromMail, "Password string. Encoded.")
    }

    /// Creates an email content.
    /// - Returns: The email content.
    func createContent() -> String {
        var value = """
        A new case was added to MEDSCOPE on the XXX
        User name: \(userName)
        UUID Patient: \(patientID)
        UUID Treatment: \(treatmentID)
        Number of plans: \(surgeryPlansCount)\n
        """
        if let surgeryPlanIDs = surgeryPlanIDs {
            for index in 0..<surgeryPlanIDs.count {
                value.append("UUID Plan \(index + 1) : \(surgeryPlanIDs[index])\n")
            }
        }
        return value
    }
}
