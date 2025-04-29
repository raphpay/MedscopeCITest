//
//  PatientDTO.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

// MARK: - Create Inputs
extension Patient {
	/// Input for creating a new Patient
	/// - Note: This structure is used to represent the input for creating a new Patient.
	///     It contains the patient name, first name, birthdate, gender, and user ID.
	///    The `toModel` function converts the input to a `Patient` model.
	struct Input: Content, WithExample {
		var id: UUID?
		let name: String
		let firstName: String
		let birthdate: String
		let gender: Patient.Gender
		let userID: User.IDValue
		var laGalaxyID: String? = nil

		/// Convert the input to a model
		/// - Returns: A `Patient` model representing the input
		func toModel(_ medscopeID: String) -> Patient {
			.init(name: name,
				  firstName: firstName,
				  birthdate: birthdate,
				  gender: gender,
				  userID: userID,
				  medscopeID: medscopeID,
				  laGalaxyID: laGalaxyID)
		}

		static var example: Input {
			.init(name: "Jane",
				  firstName: "Doe",
				  birthdate: "1745586420",
				  gender: .female,
				  userID: UUID(),
				  laGalaxyID: nil)
		}
	}


	/// Input for getting a treatment with its date
	struct TreatmentDateInput: Content {
		let date: String
	}

	/// Input for creating a new Patient via a form
	struct FormInput: Content, WithExample {
		let name: String
		let firstName: String
		let birthdate: String
		let gender: Patient.Gender
		var laGalaxyID: String?

		static var example: FormInput {
			.init(name: "Jane",
				  firstName: "Doe",
				  birthdate: "1745586420",
				  gender: .female)
		}
	}
}

// MARK: - Update Inputs
extension Patient {
	/// Input for updating an existing Patient
	/// - Note: This structure is used to represent the input for updating an existing Patient.
	///     It contains the patient name, first name, birthdate, gender, and user ID.
	///    The `update` function updates the Patient with the provided values.
	struct UpdateInput: Content {
		var name: String?
		var firstName: String?
		var birthdate: String?
		var gender: Patient.Gender?
		var userID: User.IDValue?
		var laGalaxyID: String?

		/// Update the patient with the provided values
		/// - Parameter patient: The patient to update
		/// - Returns: An updated `Patient` model
		/// - Note: This function updates the patient with the provided values.
		///    If a value is `nil`, it will not be updated.
		func update(_ patient: Patient) -> Patient {
			let updatedPatient = patient

			applyIfPresent(name) { updatedPatient.name = $0 }
			applyIfPresent(firstName) { updatedPatient.firstName = $0 }
			applyIfPresent(birthdate) { updatedPatient.birthdate = $0 }
			applyIfPresent(gender) { updatedPatient.gender = $0 }
			applyIfPresent(laGalaxyID) { updatedPatient.laGalaxyID = $0 }

			return updatedPatient
		}

		private func applyIfPresent<T>(_ value: T?, _ apply: (T) -> Void) {
			if let value = value {
				apply(value)
			}
		}
	}
}

extension Patient {
	/// Output structure for returning a `Patient` model.
	///
	/// This structure is used to return a complete representation of a patient to the client.
	/// It includes all key identifying and descriptive fields of a patient, including database IDs.
	/// Conforms to `Content` and `WithExample` for use in API responses and auto-generated documentation.
	struct Output: Content, WithExample {
		let id: UUID?
		let name: String
		let firstName: String
		let birthdate: String
		let gender: Patient.Gender
		let medscopeID: String
		let userID: User.IDValue
		var laGalaxyID: String?

		static var example: Patient.Output {
			.init(id: UUID(),
				  name: "Jane",
				  firstName: "Smith",
				  birthdate: "1745822754",
				  gender: .female,
				  medscopeID: "MEDP0002",
				  userID: UUID())
		}
	}
}
