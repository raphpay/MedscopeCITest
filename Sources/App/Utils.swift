//
//  File.swift
//
//
//  Created by Raphaël Payet on 01/08/2024.
//

import Vapor

struct Utils {
    /// Checks if the user is authenticated and has the admin role.
    /// - Parameter req: The request object.
    /// - Throws: An error if the user is not authenticated or does not have the admin role.
    static func checkAdminRole(on req: Request) throws {
        let user = try req.auth.require(User.self)
        guard user.role == .admin else {
            throw Abort(.unauthorized, reason: "unauthorized.role")
        }
    }

    /// Checks if the user is authenticated and has the operator role.
    /// - Parameter req: The request object.
    /// - Throws: An error if the user is not authenticated or does not have the operator role.
    static func getAuthenticatedUser(on req: Request) throws -> User {
        try req.auth.require(User.self)
    }
}
