//
//  TreatmentFollowUp+Status.swift
//  Medscope
//
//  Created by Raphaël Payet on 15/10/2024.
//

import Foundation

extension TreatmentFollowUp {
    /// The status of a TreatmentFollowUp
    /// - Note: This enum represents the status of a TreatmentFollowUp.
    ///    The `received` case represents a received status.
    ///    The `inProgress` case represents an in progress status.
    ///    The `sent` case represents a sent status.
    ///    The `open` case represents an open status.
    ///    The `deleted` case represents a deleted status.
    enum Status: String, Codable {
        case received, inProgress, sent, open, deleted
    }
}
