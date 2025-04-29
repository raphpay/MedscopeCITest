//
//  File.swift
//
//
//  Created by Raphaël Payet on 25/07/2024.
//

@testable import App
import XCTVapor
import Fluent

extension User {
    /// Create a new user
    /// - Parameters:
    ///   - name: The name of the user
    ///   - firstName: The first name of the user
    ///   - mailAddress: The email address of the user
    ///   - password: The password of the user
    ///   - role: The role of the user
    ///   - conditionsAccepted: Whether the user has accepted the conditions
    ///   - conditionsAcceptedTimestamp: The timestamp of when the conditions were accepted
    ///   - address: The address of the user
    ///   - loginFailedAttempts: The number of failed login attempts
    ///   - lastLoginFailedAttempt: The timestamp of the last failed login attempt
    ///   - db: The database connection to use for the creation
    /// - Returns: The created user
    /// - Throws: An error if the user creation fails
    func toUserFormInput() -> User.FormInput {
        .init(id: id ?? UUID(), name: name, firstName: firstName,
              mailAddress: mailAddress,
              role: role,
              password: password,
              address: address,
              conditionsAccepted: conditionsAccepted,
              conditionsAcceptedTimestamp: conditionsAcceptedTimestamp
        )
    }
}

extension UserControllerTests {
    /// Create a new user
    /// - Parameters:
    ///   - name: The name of the user
    ///   - firstName: The first name of the user
    ///   - mailAddress: The email address of the user
    ///   - password: The password of the user
    ///   - role: The role of the user
    ///   - conditionsAccepted: Whether the user has accepted the conditions
    ///   - conditionsAcceptedTimestamp: The timestamp of when the conditions were accepted
    ///   - address: The address of the user
    ///   - loginFailedAttempts: The number of failed login attempts
    ///   - lastLoginFailedAttempt: The timestamp of the last failed login attempt
    ///   - db: The database connection to use for the creation
    /// - Returns: The created user
    /// - Throws: An error if the user creation fails
    func createExpectedUser(on db: Database) async throws -> User {
        let hashedPassword = try Bcrypt.hash(expectedPassword)
        let user = User(name: expectedName, firstName: expectedFirstName,
                        address: expectedAddress, mailAddress: expectedMailAddress,
                        password: hashedPassword, role: expectedRole,
                        conditionsAccepted: expectedConditionsAccepted,
                        conditionsAcceptedTimestamp: expectedConditionsAcceptedTimestamp,
                        loginFailedAttempts: expectedLoginFailedAttempts,
                        lastLoginFailedAttempt: expectedLastLoginFailedAttempt
        )
        try await user.save(on: db)
        return user
    }

    /// Create a new user
    /// - Parameters:
    ///   - name: The name of the user
    ///   - firstName: The first name of the user
    ///   - mailAddress: The email address of the user
    ///   - password: The password of the user
    ///   - role: The role of the user
    ///   - conditionsAccepted: Whether the user has accepted the conditions
    ///   - conditionsAcceptedTimestamp: The timestamp of when the conditions were accepted
    ///   - address: The address of the user
    /// - Returns : The created user
    /// - Throws: An error if the user creation fails
    func createUserInput(name: String? = nil,
                         firstName: String? = nil,
                         mailAddress: String? = nil,
                         password: String? = nil,
                         role: User.Role? = nil,
                         conditionsAccepted: Bool? = nil,
                         conditionsAcceptedTimestamp: String? = nil,
                         address: String? = nil) -> User.Input {
        .init(name: name ?? expectedName, firstName: firstName ?? expectedFirstName,
              mailAddress: mailAddress ?? expectedMailAddress,
              password: password ?? expectedPassword,
              role: role ?? expectedRole,
              address: address ?? expectedAddress,
              conditionsAccepted: conditionsAccepted ?? expectedConditionsAccepted,
              conditionsAcceptedTimestamp: conditionsAcceptedTimestamp ?? expectedConditionsAcceptedTimestamp)
    }

    /// Create a new user
    /// - Parameters:
    ///   - name: The name of the user
    ///   - firstName: The first name of the user
    ///   - address: The address of the user
    ///   - mailAddress: The email address of the user
    ///   - password: The password of the user
    ///   - role: The role of the user
    ///   - conditionsAccepted: Whether the user has accepted the conditions
    ///   - conditionsAcceptedTimestamp: The timestamp of when the conditions were accepted
    ///   - loginFailedAttempts: The number of failed login attempts
    ///   - lastLoginFailedAttempt: The timestamp of the last failed login attempt
    /// - Returns: The created user
    /// - Throws: An error if the user creation fails
    func createAdminUser(on db: Database) async throws -> User {
        let user = User(name: expectedAdminName, firstName: expectedAdminFirstName,
                        address: expectedAdminAddress,
                        mailAddress: expectedAdminMailAddress,
                        password: expectedAdminPassword,
                        role: expectedAdminRole,
                        conditionsAccepted: expectedConditionsAccepted,
                        conditionsAcceptedTimestamp: expectedConditionsAcceptedTimestamp,
                        loginFailedAttempts: expectedLoginFailedAttempts,
                        lastLoginFailedAttempt: expectedLastLoginFailedAttempt
        )
        try await user.save(on: db)
        return user
    }

    /// Create a new user
    /// - Parameters:
    ///   - role: The role of the user
    ///   - name: The name of the user
    ///   - firstName: The first name of the user
    ///   - address: The address of the user
    ///   - mailAddress: The email address of the user
    ///   - password: The password of the user
    ///   - conditionsAccepted: Whether the user has accepted the conditions
    ///   - conditionsAcceptedTimestamp: The timestamp of when the conditions were accepted
    ///   - loginFailedAttempts: The number of failed login attempts
    ///   - lastLoginFailedAttempt: The timestamp of the last failed login attempt
    /// - Returns: The created user
    /// - Throws: An error if the user creation fails
    func createUnauthorizedUser(with role: User.Role, on db: Database) async throws -> User {
        let user = User(name: expectedAdminName, firstName: expectedAdminFirstName,
                        address: expectedAdminAddress, mailAddress: expectedAdminMailAddress,
                        password: expectedAdminPassword,
                        role: role,
                        conditionsAccepted: expectedConditionsAccepted,
                        conditionsAcceptedTimestamp: expectedConditionsAcceptedTimestamp,
                        loginFailedAttempts: expectedLoginFailedAttempts,
                        lastLoginFailedAttempt: expectedLastLoginFailedAttempt
        )
        try await user.save(on: db)
        return user
    }

    /// Create a new user form input
    /// - Parameters:
    ///   - id: The ID of the user
    ///   - password: The password of the user
    /// - Returns: The created user form input
    /// - Throws: An error if the user creation fails
    func createUserFormInput(id: User.IDValue?, password: String?) -> User.FormInput {
        .init(id: id, name: expectedName, firstName: expectedFirstName,
              mailAddress: expectedMailAddress,
              role: expectedRole,
              password: password,
              address: expectedAddress,
              conditionsAccepted: expectedConditionsAccepted,
              conditionsAcceptedTimestamp: expectedConditionsAcceptedTimestamp
        )
    }
}
