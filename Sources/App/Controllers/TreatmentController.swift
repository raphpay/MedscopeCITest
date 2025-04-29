//
//  TreatmentController.swift
//
//
//  Created by Raphaël Payet on 19/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

struct TreatmentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Group the routes under the "api" path
        let treatments = routes.grouped("api").grouped(APIKeyCheckMiddleware())
        // POST
        try registerPostRoutes(treatments)
        // GET
        try registerGetRoutes(treatments)
        try registerDownloadRoutes(treatments)
        // UPDATE
        try registerUpdateRoutes(treatments)
        // DELETE
        try registerDeleteRoutes(treatments)
    }
}

extension TreatmentController {
    private func registerPostRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "treatments",
                                     description: "Everything about treatments")) { treatmentRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = treatmentRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // POST: Create a new treatment
            tokenAuthGroup.post(use: create)
                .openAPI(
                    summary: "Create a new treatment",
                    description: "Create a new treatment and upload a dicom file",
                    body: .type(Treatment.Input.self),
                    contentType: .application(.json),
					response: .type(Treatment.Output.self),
                    responseContentType: .application(.json)
                )
        }
    }

    private func registerGetRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "treatments",
                                     description: "Everything about treatments")) { treatmentRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = treatmentRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // GET: Get all treatments
            tokenAuthGroup.get(use: getAll)
                .openAPI(
                    summary: "Get all treatments",
					response: .type([Treatment.Output].self),
                    responseContentType: .application(.json)
                )

            // GET: Get a specific treatment
            tokenAuthGroup.get(":treatmentID", use: getByID)
                .openAPI(
                    summary: "Get a specific treatment",
                    description: "Get a specific treatment",
					response: .type(Treatment.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Treatment not found")
                .response(statusCode: .badRequest,
                          description: "Missing or incorrectly formatted treatment id")

            // GET: Get a specific treatment's patient
            tokenAuthGroup.get("patient", ":treatmentID", use: getPatient)
                .openAPI(
                    summary: "Get a specific treatment's patient",
					response: .type(Patient.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Treatment not found")
                .response(statusCode: .badRequest,
                          description: "Missing or incorrectly formatted treatment id")

            // GET: Get a specific treatment's surgery plans
            tokenAuthGroup.get("surgeryPlans", ":treatmentID", use: getSurgeryPlans)
                .openAPI(
                    summary: "Get a specific treatment's surgery plans",
					response: .type(Patient.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Treatment not found")
                .response(statusCode: .badRequest,
                          description: "Missing or incorrectly formatted treatment id")
        }
    }

    private func registerDownloadRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "treatments",
                                     description: "Everything about treatments")) { treatmentRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = treatmentRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // GET: Get a download token for a specific treatment's dicom
            tokenAuthGroup.get("download", "token", "for", "dicom", ":treatmentID",
                               use: getDicomDownloadToken)
                .openAPI(
                    summary: "Get a download token for a specific treatment's dicom",
                    description: "Get a download token for a dicom related to a specific treatment",
                    response: .type(String.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Treatment not found")
                .response(statusCode: .badRequest,
                          description: "Missing or incorrectly formatted treatment id")

            // GET: Download a specific treatment's dicom
            tokenAuthGroup.get("download", "dicom", ":token", use: downloadDicom)
                .openAPI(
                    summary: "Download a specific treatment's dicom",
                    description: "Download a dicom related to a specific treatment",
                    responseContentType: .application(.octetStream)
                )
                .response(statusCode: .badRequest, description: "Incorrect download token")
                .response(statusCode: .notFound, description: "File download token not found")
                .response(statusCode: .gone, description: "Token expired")
                .response(statusCode: .forbidden, description: "Token already used")
        }
    }

    private func registerUpdateRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "treatments",
                                     description: "Everything about treatments")) { treatmentRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = treatmentRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // UPDATE: Update a specific treatment
            tokenAuthGroup.put(":treatmentID", use: update)
                .openAPI(
                    summary: "Update a specific treatment",
                    body: .type(Treatment.UpdateInput.self),
                    contentType: .application(.json),
					response: .type(Treatment.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Treatment not found")
                .response(statusCode: .badRequest,
                          description: "Missing or incorrectly formatted treatment id")
                .response(statusCode: .badRequest, description: "Check the data")
        }
    }

    private func registerDeleteRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "treatments",
                                     description: "Everything about treatments")) { treatmentRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = treatmentRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // DELETE: Delete all treatments
            tokenAuthGroup.delete("all", use: deleteAll)
                .openAPI(
                    summary: "Delete all treatments",
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )

            // DELETE: Delete a specific treatment
            tokenAuthGroup.delete(":treatmentID", use: delete)
                .openAPI(
                    summary: "Delete a specific treatment",
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Treatment not found")
                .response(statusCode: .badRequest,
                          description: "Missing or incorrectly formatted treatment id")
        }
    }
}

extension TreatmentController {
    // MARK: - CREATE
    /// Create a new treatment
    /// - Parameter req: The incoming request containing the treatment information.
    /// - Returns: A `Treatment` object representing the created treatment.
    /// - Throws: An error if the treatment cannot be created or if the database query fails.
    @Sendable
    func create(req: Request) async throws -> Treatment {
        let input = try req.content.decode(Treatment.Input.self)
        return try await create(from: input, on: req)
    }

    // MARK: - READ
    /// Get all treatments
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An array of `Treatment` objects representing the retrieved treatments.
    /// - Throws: An error if the database query fails.
    /// - Note: This function retrieves all treatments from the database and returns them as an array of `Treatment` objects.
    @Sendable
    func getAll(req: Request) async throws -> [Treatment] {
        try await Treatment
            .query(on: req.db)
            .all()
    }

    /// Get a specific treatment
    /// - Parameter req: The incoming request containing the treatment ID.
    /// - Returns: A `Treatment` object representing the retrieved treatment.
    /// - Throws: An error if the treatment cannot be found or if the database query fails.
    @Sendable
    func getByID(req: Request) async throws -> Treatment {
        return try await getTreatment(on: req)
    }

    /// Get a download token for a specific treatment's dicom
    /// - Parameter req: The incoming request containing the treatment ID.
    /// - Returns: A `String` representing the download token.
    /// - Throws: An error if the treatment cannot be found or if the database query fails.
    /// - Note: This function retrieves the treatment by its ID from the database and retrieves the document associated with it.
    ///     It then constructs the file path for the document and generates a download token.
    ///     The function returns the download token.
    @Sendable
    func getDicomDownloadToken(req: Request) async throws -> String {
        let treatment = try await getTreatment(on: req)
        let document = try await self.getDocument(from: treatment, on: req.db)
        let path = document.path + document.name
        return try await DocumentController().getDownloadToken(at: path, on: req)
    }

    /// Download a specific treatment's dicom
    /// - Parameter req: The incoming request containing the download token.
    /// - Returns: A `Response` object representing the downloaded file.
    /// - Throws: An error if the download token is missing or if the file cannot be found or if the database query fails.
    /// - Note: This function retrieves the download token from the request parameters and validates it.
    ///     It then retrieves the file download from the database using the token.
    ///     If the file download is not found, it throws a `notFound` error.
    ///     If the file download is found, it retrieves the file path from the database.
    ///     It then constructs the file path for the document and downloads the file.
    @Sendable
    func downloadDicom(req: Request) async throws -> Response {
        guard let token = req.parameters.get("token") else {
            throw Abort(.badRequest, reason: "badRequest.token")
        }

        let fileDownload = try await FileDownloadController().getFileDownload(with: token, on: req)
        try await FileDownloadController().validate(fileDownload)

        let filePath = req.application.directory.resourcesDirectory + "Uploads/" + fileDownload.filePath
        let response = try await DocumentController().download(at: filePath, on: req)

        // Update used at parameter and save
        fileDownload.usedAt = .now
        try await fileDownload.update(on: req.db)

        return response
    }

    /// Get a specific treatment's patient
    /// - Parameter req: The incoming request containing the treatment ID.
    /// - Returns: A `Patient` object representing the retrieved patient.
    /// - Throws: An error if the treatment cannot be found or if the database query fails.
    /// - Note: This function retrieves the treatment by its ID from the database and retrieves the patient associated with it.
    @Sendable
    func getPatient(req: Request) async throws -> Patient {
        let treatment = try await getTreatment(on: req)
        return try await treatment.$patient.get(on: req.db)
    }

    /// Get a specific treatment's surgery plans
    /// - Parameter req: The incoming request containing the treatment ID.
    /// - Returns: An array of `SurgeryPlan` objects representing the retrieved surgery plans.
    /// - Throws: An error if the treatment cannot be found or if the database query fails.
    /// - Note: This function retrieves the treatment by its ID from the database and retrieves the surgery plans associated with it.
    @Sendable
    func getSurgeryPlans(req: Request) async throws -> [SurgeryPlan] {
        let treatment = try await getTreatment(on: req)
        return try await treatment.$surgeryPlans.get(on: req.db)
    }

    // MARK: - UPDATE
    /// Update a specific treatment
    /// - Parameter req: The incoming request containing the treatment ID and updated information.
    /// - Returns: A `Treatment` object representing the updated treatment.
    /// - Throws: An error if the treatment cannot be found or if the database update fails.
    /// - Note: This function retrieves the treatment by its ID from the database and validates the update input.
    @Sendable
    func update(req: Request) async throws -> Treatment {
        let treatment = try await getTreatment(on: req)
        let updateInput = try req.content.decode(Treatment.UpdateInput.self)

        try await TreatmentUpdateMiddleware().validate(updateInput, with: treatment.$patient.id, on: req.db)

        let updatedTreatment = updateInput.update(treatment)
        try await updatedTreatment.update(on: req.db)

        return updatedTreatment
    }

    // MARK: - DELETE
    /// Delete all treatments
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves all treatments from the database, and deletes each treatment one by one. It returns a 204 No Content status upon successful deletion of all treatments.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the treatments are deleted from the database, including their associated documents.
    ///     Use this function only if you want to delete all treatments from the database.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting all treatments will remove all associated documents from the database.
    ///    Ensure that you have proper backups and authorization before using this function.
    @Sendable
    func deleteAll(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        let treatments = try await Treatment
            .query(on: req.db)
            .all()

        for treatment in treatments {
            _ = try await delete(treatment: treatment, on: req)
        }

        return .noContent

    }

    /// Delete a specific treatment
    /// - Parameter req: The incoming request containing the treatment ID.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the treatment cannot be found or if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves a treatment by its ID from the database, and deletes it. It returns a 204 No Content status upon successful deletion of the treatment.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the treatment is deleted from the database, including its associated documents.
    ///     Use this function only if you want to delete a specific treatment from the database.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting a treatment will remove its associated documents from the database.
    ///    Ensure that you have proper backups and authorization before using this function.
    @Sendable
    func delete(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)
        let treatment = try await getTreatment(on: req)
        return try await delete(treatment: treatment, on: req)
    }
}

// MARK: - Utils
extension TreatmentController {
    /// Create a new treatment
    /// - Parameters:
    ///   - input: The `Treatment.Input` containing the treatment information.
    ///   - req: The incoming request containing the database connection.
    /// - Returns: A `Treatment` object representing the created treatment.
    /// - Throws: An error if the treatment cannot be created or if the database query fails.
    /// - Note: This function validates the input parameters and creates a new treatment with the provided information.
    func create(from input: Treatment.Input, on req: Request) async throws -> Treatment {
        try await TreatmentMiddleware().validate(input, with: input.patientID, on: req.db)
        let treatment = input.toModel()
        try await treatment.save(on: req.db)
        return treatment
    }

    /// Get a document from a treatment
    /// - Parameters:
    ///   - treatment: The `Treatment` object representing the treatment.
    ///   - db: The database connection to use for retrieving the document.
    /// - Returns: A `Document` object representing the retrieved document.
    /// - Throws: An error if the document cannot be found or if the database query fails.
    /// - Note: This function retrieves the document associated with the treatment by filtering the `Document` table using the treatment's `dicomID`.
    ///      It returns the first matching document found in the database.
    private func getDocument(from treatment: Treatment, on db: Database) async throws -> Document {
        let document = try await DocumentController().getDocument(with: treatment.dicomID, on: db)
        return document
    }

    /// Get a treatment by its ID
    /// - Parameter req: The incoming request containing the treatment ID.
    /// - Returns: A `Treatment` object representing the retrieved treatment.
    /// - Throws: An error if the treatment cannot be found or if the database query fails.
    /// - Note: This function retrieves the treatment by its ID from the request parameters.
    ///     It returns the first matching treatment found in the database.
    ///     If no matching treatment is found, it throws a `notFound` error.
    ///     If the treatment ID is missing or incorrectly formatted, it throws a `badRequest` error.
    private func getTreatment(on req: Request) async throws -> Treatment {
        guard let id = req.parameters.get("treatmentID", as: Treatment.IDValue.self) else {
            throw Abort(.badRequest, reason: "badRequest.missingTreatmentID")
        }

        guard let treatment = try await Treatment.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.treatment")
        }

        return treatment
    }

    /// Get a treatment by its ID
    /// - Parameters:
    ///   - id: The ID of the treatment to be retrieved.
    ///   - db: The database connection to use for retrieving the treatment.
    /// - Returns: A `Treatment` object representing the retrieved treatment.
    /// - Throws: An error if the treatment cannot be found or if the database query fails.
    /// - Note: This function retrieves the treatment by its ID from the database using the provided ID.
    ///     It returns the first matching treatment found in the database.
    ///     If no matching treatment is found, it throws a `notFound` error.
    ///     If the ID is not provided, it throws a `badRequest` error.
    ///     If the treatment ID is not a valid ID, it throws a `badRequest` error.
    func get(with id: Treatment.IDValue, on db: Database) async throws -> Treatment {
        guard let treatment = try await Treatment.find(id, on: db) else {
            throw Abort(.notFound, reason: "notFound.treatment")
        }

        return treatment
    }

    /// Delete a treatment
    /// - Parameters:
    ///   - treatment: The `Treatment` object representing the treatment to be deleted.
    ///   - req: The incoming request containing the database connection.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the treatment cannot be found or if the database deletion fails.
    /// - Note: This function checks if the current user has admin role, retrieves the treatment by its ID from the database, and deletes it. It returns a 204 No Content status upon successful deletion of the treatment.
    /// - Important: This function should be called with caution and should only be used by administrators.
    ///     It ensures that the treatment is deleted from the database, including its associated documents.
    ///     Use this function only if you want to delete a specific treatment from the database.
    /// - Warning: This function should be used with caution and should only be called by administrators.
    ///    Deleting a treatment will remove its associated documents from the database.
    ///    Ensure that you have proper backups and authorization before using this function.
    func delete(treatment: Treatment, on req: Request) async throws -> HTTPResponseStatus {
        // Delete related surgery plans
        let surgeryPlans = try await treatment.$surgeryPlans.query(on: req.db).all()
        for surgeryPlan in surgeryPlans {
            _ = try await SurgeryPlanController().delete(surgeryPlan: surgeryPlan, on: req)
        }

        var documentsToDelete: [Document.IDValue] = []
        documentsToDelete.append(treatment.dicomID)

        for model3D in treatment.model3Ds {
            documentsToDelete.append(model3D)
        }

        let docsToDelete = Array(Set(documentsToDelete))

        for doc in docsToDelete {
            if let doc = try await DocumentController().getOptionalDocument(with: doc, on: req.db) {
                _ = try await DocumentController().delete(document: doc, on: req)
            }
        }

        try await treatment.delete(force: true, on: req.db)

        return .noContent
    }
}
