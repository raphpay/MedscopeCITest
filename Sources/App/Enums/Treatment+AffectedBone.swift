//
//  Treatment+AffectedBone.swift
//
//
//  Created by Raphaël Payet on 21/06/2024.
//

import Foundation

extension Treatment {
    /// The affected bone of a Treatment
    /// - Note: This enum represents the affected bone of a Treatment.
    ///    The `mandible` case represents a mandible affected bone.
    ///    The `maxillary` case represents a maxillary affected bone.
    ///    The `both` case represents a both affected bone.
    enum AffectedBone: String, Codable {
        case mandible, maxillary, both
    }
}
