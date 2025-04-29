//
//  MaterialDTO.swift
//
//
//  Created by Raphaël Payet on 26/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

extension Material {
    /// Input for creating a new Material
    /// - Note: This structure is used to represent the input for creating a new Material.
    ///     It contains the material name, E, nu, sigmaDam, and sigmaFa.
    ///    The `toModel` function converts the input to a `Material` model.
    struct Input: Content, WithExample {
        var id: UUID?
        let matName: String
        let e: Float
        let nu: Float
        let sigmaDam: Float
        let sigmaFa: Float

        /// Convert the input to a model
        /// - Returns: A `Material` model representing the input
        func toModel() -> Material {
            .init(
                matName: matName,
                e: e, nu: nu,
                sigmaDam: sigmaDam, sigmaFa: sigmaFa
            )
        }

        static var example : Input {
            .init(
                id: nil,
                matName: "Silicon",
                e: 100.0,
                nu: 0.3,
                sigmaDam: 3200.0,
                sigmaFa: 1000.0
            )
        }
    }
}

extension Material {
    /// Input for updating an existing Material
    /// - Note: This structure is used to represent the input for updating an existing Material.
    ///     It contains the material name, E, nu, sigmaDam, and sigmaFa.
    ///    The `update` function updates the Material with the provided values.
    struct UpdateInput: Content, WithExample {
        let matName: String?
        let e: Float?
        let nu: Float?
        let sigmaDam: Float?
        let sigmaFa: Float?

        /// Update the material with the provided values
        /// - Parameter material: The material to update
        /// - Returns: An updated `Material` model
        /// - Note: This function updates the material with the provided values.
        ///    If a value is `nil`, it will not be updated.
        func update(_ material: Material) -> Material {
            let updatedMaterial = material

            if let matName = matName {
                updatedMaterial.matName = matName
            }

            if let e = e {
                updatedMaterial.e = e
            }

            if let nu = nu {
                updatedMaterial.nu = nu
            }

            if let sigmaDam = sigmaDam {
                updatedMaterial.sigmaDam = sigmaDam
            }

            if let sigmaFa = sigmaFa {
                updatedMaterial.sigmaFa = sigmaFa
            }

            return updatedMaterial
        }

        static var example: Material.UpdateInput {
            .init(
                matName: "Silicon",
                e: 200.0,
                nu: 0.3,
                sigmaDam: 1000.0,
                sigmaFa: 2000.0
            )
        }
    }
}

extension Material {
	/// Output for  Material
	/// - Note: This structure is used to represent the output of a Material.
	///     It contains the id material name, E, nu, sigmaDam, and sigmaFa.
    struct Output : Content, WithExample {
        let id: UUID
        let matName: String
        let e: Float
        let nu: Float
        let sigmaDam: Float
        let sigmaFa: Float

        static var example: Material.Output {
            .init(
                id: UUID(),
                matName: "Silicon",
                e: 200.0,
                nu: 0.3,
                sigmaDam: 1000.0,
                sigmaFa: 2000.0
            )
        }
    }
}
