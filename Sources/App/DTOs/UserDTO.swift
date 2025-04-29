//
//  UserDTO.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

// MARK: - Input
extension User {
    /// Input for creating a new User
    /// - Note: This structure is used to represent the input for creating a new User.
    ///     It contains the user name, first name, mail address, password, role, address, conditions accepted, and conditions accepted timestamp.
    ///     The `toModel` function converts the input to a `User` model.
    struct Input: Content, WithExample {
        let name: String
        let firstName: String
        let mailAddress: String
        let password: String
        let role: Role
        let address: String?
        let conditionsAccepted: Bool
        let conditionsAcceptedTimestamp: String?

        /// Convert the input to a model
        /// - Parameter hashedPassword: The hashed password
        /// - Returns: A `User` model representing the input
        /// - Throws: An error if the conversion fails
        func toModel(with hashedPassword: String)-> User {
            .init(name: name, firstName: firstName,
                  address: address, mailAddress: mailAddress,
                  password: hashedPassword, role: role,
                  conditionsAccepted: conditionsAccepted, conditionsAcceptedTimestamp: conditionsAcceptedTimestamp,
                  loginFailedAttempts: 0, lastLoginFailedAttempt: nil
            )
        }

		static var example: User.Input {
			.init(name: "Doe",
				  firstName: "John",
				  mailAddress: "john_doe@example.com",
				  password: "Passwordlong12(",
				  role: .user,
				  address: "Optional address",
				  conditionsAccepted: true,
				  conditionsAcceptedTimestamp: "1745586420"
			)
		}
    }

    /// Input for creating a new User from a form
    struct FormInput: Content, WithExample {
        let id: User.IDValue?
        let name: String
        let firstName: String
        let mailAddress: String
        let role: Role
        let password: String?
        let address: String?
        let conditionsAccepted: Bool
        let conditionsAcceptedTimestamp: String?

		static var example: FormInput {
			.init(id: UUID(),
				  name: "Doe",
				  firstName: "John",
				  mailAddress: "john_doe@example.com",
				  role: .user,
				  password: "Passwordlong12(",
				  address: "Optional address",
				  conditionsAccepted: true,
				  conditionsAcceptedTimestamp: "1745586420"
			)
		}
    }
}

// MARK: - Update Input
extension User {
    /// Input for updating an existing User
    /// - Note: This structure is used to represent the input for updating an existing User.
    ///     The `update` function updates the User with the provided values.
    struct UpdateInput: Content, WithExample {
        let name: String?
        let firstName: String?
        let address: String?
        let mailAddress: String?
        let conditionsAccepted: Bool?
        let conditionsAcceptedTimestamp: String?
        let role: Role?

        /// Update the User with the provided values
        /// - Parameter user: The User to update
        /// - Returns: An updated `User` model
        /// - Throws: An error if the update fails
        /// - Note: This function updates the User with the provided values.
        ///    If a value is not provided, it will not be updated.
        func update(_ user: User) throws -> User {
            let updatedUser = user
            if let name = name {
                updatedUser.name = name
            }
            if let firstName = firstName {
                updatedUser.firstName = firstName
            }
            if let address = address {
                updatedUser.address = address
            }
            if let mailAddress = mailAddress {
                guard mailAddress.isValidEmail() else {
                    throw Abort(.badRequest, reason: "badRequest.incorrectMailAddressFormat")
                }

                updatedUser.mailAddress = mailAddress
            }
            if let conditionsAccepted = conditionsAccepted {
                updatedUser.conditionsAccepted = conditionsAccepted
            }
            if let conditionsAcceptedTimestamp = conditionsAcceptedTimestamp {
                updatedUser.conditionsAcceptedTimestamp = conditionsAcceptedTimestamp
            }
            return updatedUser
        }

        /// Update the User's role with the provided role
        /// - Parameter user: The User to update
        /// - Parameter role: The role to update the User with
        /// - Returns: An updated `User` model
        /// - Throws: An error if the update fails
        func updateRole(on user: User, with role: Role) -> User {
            let updatedUser = user
            updatedUser.role = role
            return updatedUser
        }

		static var example: UpdateInput {
			.init(name: "Doe",
				  firstName: "John",
				  address: "Optional address",
				  mailAddress: "john_doe@example.com",
				  conditionsAccepted: true,
				  conditionsAcceptedTimestamp: "1745586420",
				  role: .user
			)
		}
    }
}

// MARK: - Output
extension User {
    /// Output for a User
    /// - Note: This structure is used to represent the output for a User.
    ///     The password is not included in the output.
    ///     The `toPublicOutput` function converts the output to a `User.PublicOutput` model.
    struct PublicOutput: Content, WithExample {
        let id: User.IDValue
        let name: String
        let firstName: String
        let mailAddress: String
        let role: Role
        let address: String?
        let conditionsAccepted: Bool
        let conditionsAcceptedTimestamp: String?
        let loginFailedAttempts: Int
        let lastLoginFailedAttempt: String?

		static var example: User.PublicOutput {
			.init(id: UUID(),
				  name: "Doe",
				  firstName: "John",
				  mailAddress: "john_does@example.com",
				  role: .user,
				  address: "Optional address",
				  conditionsAccepted: true,
				  conditionsAcceptedTimestamp: "1745586420",
				  loginFailedAttempts: 0,
				  lastLoginFailedAttempt: nil)
		}
    }

    /// Convert a User to a PublicOutput
    /// - Returns: A `User.PublicOutput` model representing the User
    func toPublicOutput() throws -> User.PublicOutput {
        let selfID = try self.requireID()
        return User.PublicOutput(id: selfID,
                                 name: name,
								 firstName: firstName,
                                 mailAddress: mailAddress,
                                 role: role, address: address,
                                 conditionsAccepted: conditionsAccepted,
                                 conditionsAcceptedTimestamp: conditionsAcceptedTimestamp,
                                 loginFailedAttempts: loginFailedAttempts,
								 lastLoginFailedAttempt: lastLoginFailedAttempt)
    }
}
