//
//  VersionLogDTO.swift
//  Medscope
//
//  Created by Raphaël Payet on 14/10/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

// MARK: - Input
extension VersionLog {
	/// Input for creating a new VersionLog
	/// - Note: This structure is used to represent the input for creating a new VersionLog.
	///    The `toModel` function converts the input to a `VersionLog` model.
	struct Input: Content, WithExample {
		let interface: String
		let api: String
		let calculator: String
		let package: Int
		let udi: String

		/// Convert the input to a model
		/// - Parameter timestamp: The timestamp of the package update
		/// - Returns: A `VersionLog` model representing the input
		func toModel(timestamp: Date) -> VersionLog {
			.init(interface: interface,
				  api: api,
				  calculator: calculator,
				  package: package,
				  packageUpdateTimestamp: timestamp,
				  udi: udi
			)
		}

		static var example: VersionLog.Input {
			.init(interface: "0.1.0", api: "1.0.0", calculator: "3.2.4", package: 3, udi: "873JH234")
		}
	}
}

// MARK: - Update Input
extension VersionLog {
	/// Input for updating an existing VersionLog
	/// - Note: This structure is used to represent the input for updating an existing VersionLog.
	///    The `update` function updates the VersionLog with the provided values.
	struct UpdateInput: Content, WithExample {
		let interface: String?
		let api: String?
		let calculator: String?
		let udi: String?

		/// Update the VersionLog with the provided values
		/// - Parameter versionLog: The VersionLog to update
		/// - Returns: An updated `VersionLog` model
		/// - Throws: An error if the update fails
		/// - Note: This function updates the VersionLog with the provided values.
		///    If a value is not provided, it will not be updated.
		///    If the version is regressed, it will throw an error.
		func update(_ versionLog: VersionLog) throws -> VersionLog {
			let updatedVersionLog = versionLog

			if let interface = interface {
				if isVersionRegressed(current: versionLog.interface, new: interface) {
					throw Abort(.badRequest, reason: "badRequest.interfaceRegression")
				} else {
					updatedVersionLog.interface = interface
				}
			}
			if let api = api {
				if isVersionRegressed(current: versionLog.api, new: api) {
					throw Abort(.badRequest, reason: "badRequest.apiRegression")
				} else {
					updatedVersionLog.api = api
				}
			}
			if let calculator = calculator {
				if isVersionRegressed(current: versionLog.calculator, new: calculator) {
					throw Abort(.badRequest, reason: "badRequest.calculatorRegression")
				} else {
					updatedVersionLog.calculator = calculator
				}
			}

			if let udi = udi {
				updatedVersionLog.udi = udi
			}

			return updatedVersionLog
		}

		/// Checks if a version is regressed
		/// - Parameters:
		///   - current: The current version
		///   - new: The new version
		/// - Returns: A boolean indicating if the version is regressed
		private func isVersionRegressed(current: String, new: String) -> Bool {
			let currentComponents = current.split(separator: ".").compactMap { Int($0) }
			let newComponents = new.split(separator: ".").compactMap { Int($0) }

			// Compare each version component: major, minor, patch
			for (currentPart, newPart) in zip(currentComponents, newComponents) {
				if newPart > currentPart {
					return false // No regression
				} else if newPart < currentPart {
					return true // Regression
				}
			}

			// If all parts are equal but `new` has fewer components, it’s considered a regression
			return newComponents.count < currentComponents.count
		}

		static var example: VersionLog.UpdateInput {
			.init(interface: "0.1.0", api: "1.0.0", calculator: "3.2.4", udi: "873JH234")
		}
	}

	/// Input for updating the package update timestamp of a VersionLog
	/// - Note: This structure is used to represent the input for updating the package update timestamp of a VersionLog.
	///    The `updatePackageUpdateTimestamp` function updates the package update timestamp of the VersionLog.
	struct PackageUpdateInput: Content, WithExample {
		let package: Int

		static var example: PackageUpdateInput {
			.init(package: 1)
		}
	}
}

extension VersionLog {
	/// Output structure for returning a `VersionLog` model.
	///
	/// This structure is used to serialize and return all relevant fields of a `VersionLog`,
	/// including version identifiers, the update timestamp, and the UDI.
	/// Conforms to `Content` and `WithExample` for use in API responses and OpenAPI documentation.
	struct Output: Content, WithExample {
		let id: UUID?
		let interface: String
		let api: String
		let calculator: String
		let package: Int
		let packageUpdateTimestamp: Date
		let udi: String

		static var example: VersionLog.Output {
			.init(id: UUID(),
				  interface: "0.1.0",
				  api: "1.0.0",
				  calculator: "3.2.4",
				  package: 3,
				  packageUpdateTimestamp: .now,
				  udi: "873JH234")
		}
	}
}
