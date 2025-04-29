//
//  OpenAPIController.swift
//
//
//  Created by Raphaël Payet on 01/07/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

struct OpenAPIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Group the routes under the "api" path
        let docs = routes.grouped("api", "docs")
        // GET: Get the OpenAPI documentation
        docs.get("swagger", "swagger.json", use: getDocumentation)
            .excludeFromOpenAPI()
    }

    // MARK: - READ
    /// Get the OpenAPI documentation
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An `OpenAPIObject` representing the OpenAPI documentation.
    /// - Throws: An error if the database query fails.
    @Sendable
    func getDocumentation(req: Request) -> OpenAPIObject {
        req.application.routes.openAPI(
            info: InfoObject(
                title: "Swagger Medscope - OpenAPI 3.0",
                description: "This is the Medscope Server based on the OpenAPI 3.0.1 specification.",
                termsOfService: URL(string: "http://swagger.io/terms/"),
                contact: ContactObject(
                    email: Environment.get("TWINPAW_EMAIL_ADDRESS")
                ),
                license: LicenseObject(
                    name: "Apache 2.0",
                    url: URL(string: "http://www.apache.org/licenses/LICENSE-2.0.html")
                ),
                version: Version(1, 0, 17)
            ),
            externalDocs: ExternalDocumentationObject(
                description: "Find out more about Swagger",
                url: URL(string: "http://swagger.io")!
            )
        )
    }
}
