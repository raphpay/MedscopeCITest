//
//  File.swift
//
//
//  Created by Raphaël Payet on 27/08/2024.
//

import Fluent
import Vapor
import SendGridKit

extension Email {
    /// Input structure for email
    /// - Note: This structure is used to represent the input of an email.
    ///     It contains the recipient's email, name, and the content of the email.
    ///     The `createContent` function creates the content of the email.
    struct Input: Content {
        let recipient: [String]
        let fromMail: String
        let fromName: String // Can be only fromMail
        let replyTo: String?
        let userName: String
        let patientID: Patient.IDValue
        let treatmentID: Treatment.IDValue
        let surgeryPlansCount: Int
        let surgeryPlanIDs: [SurgeryPlan.IDValue]?
        let apiKey: String

        /// Create the content of the email
        /// - Returns: The content of the email as a string.
        /// - Note: This function creates the content of the email.
        ///     It creates a string with the current date, the user name, the patient ID, the treatment ID, and the number of surgery plans.
        ///     If surgery plans IDs are provided, it appends the IDs of the surgery plans to the string.
        ///     The function returns the content of the email as a string.
        func createContent() -> String {
            let currentDate = Date().formattedAsYearMonthDay()
            var value = """
            A new case was added to MEDSCOPE on the \(currentDate)
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

    /// CustomContentInput structure for email
    /// - Note: This structure is used to represent the input of an email with custom content.
    ///     It contains the recipient's email, name, reply-to email, subject, content, and the API key.
    struct CustomContentInput: Content {
        let recipient: [String]
        let fromMail: String
        let fromName: String
        let replyTo: String?
        let subject: String
        let content: String
        let apiKey: String
        var isHTML: Bool = false
    }
}
