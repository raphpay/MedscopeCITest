//
//  DocumentController.swift
//
//
//  Created by Raphaël Payet on 18/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI
import Zip

struct DocumentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Group routes under "/api" and apply APIKeyCheckMiddleware for authentication
        let documents = routes.grouped("api").grouped(APIKeyCheckMiddleware())
        // POST
        try registerPostRoutes(documents)
        // GET
        try registerGetRoutes(documents)
        try registerDownloadRoutes(documents)
        // UPDATE
        // DELETE
        try registerDeleteRoutes(documents)
    }
}

extension DocumentController {
    private func registerPostRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "documents",
                                     description: "Everything about documents")) { documentRoutes in
            // Define middlewares for token-based authentication and user guard
            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            // Apply the authentication middlewares to a specific group of routes
            let tokenAuthGroup = documentRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // Define routes with HTTP methods and their respective handlers
            // POST: Create a new document and upload its related file
            tokenAuthGroup.on(.POST,
                              body: .stream,
                              use: upload)
                .openAPI(
                    summary: "Create a new document and upload its related file",
                    description: "Create a new document and save the file in the database",
                    body: .type(Document.Input.self),
                    contentType: .application(.json),
					response: .type(Document.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .internalServerError,
                          description: "The API couldn't create the directory")
                .response(statusCode: .badRequest,
                          description: "The file name should contain an extension")

            // POST: Create new documents and upload their related files
            tokenAuthGroup.post("upload", "multiple", use: uploadMultiple)
                .openAPI(
                    summary: "Create new documents and upload their related files",
                    description: "Create new documents and save the files in the database",
                    body: .type(Document.MultipleInput.self),
                    contentType: .application(.json),
					response: .type([Document.Output].self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .internalServerError,
                          description: "The API couldn't create the directory")
        }
    }

    private func registerGetRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "documents",
                                     description: "Everything about documents")) { documentRoutes in

            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = documentRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // GET: Get all documents
            tokenAuthGroup.get(use: getAll)
                .openAPI(
                    summary: "Get all documents",
					response: .type([Document.Output].self),
                    responseContentType: .application(.json)
                )

            // GET: Get a specific document by its ID
            tokenAuthGroup.get(":documentID", use: getDocument)
                .openAPI(
                    summary: "Get a specific document",
					response: .type(Document.Output.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Cannot find the Document")
        }
    }

    private func registerDownloadRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "documents",
                                     description: "Everything about documents")) { documentRoutes in
            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = documentRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // GET: Get a unique download token for a specific document
            tokenAuthGroup.get("download", "token", "for", ":documentID", use: getDownloadToken)
                .openAPI(
                    summary: "Get a unique download token for a specific document",
                    response: .type(String.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .badRequest, description: "Missing or incorrect document ID")
                .response(statusCode: .notFound, description: "Cannot find the Document")

            // GET: Get a unique download token for a specific path
            tokenAuthGroup.post("download", "token", "for", "folder", use: getDownloadTokenForFolder)
                .openAPI(
                    summary: "Get a unique download token for a specific path",
                    response: .type(String.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .badRequest, description: "Missing or incorrect document ID")
                .response(statusCode: .notFound, description: "Cannot find the documents at the path")

            // GET: Download a file using a download token
            tokenAuthGroup.get("download", "file", ":token", use: download)
                .openAPI(
                    summary: "Download a file",
                    description: "Download a specific file and retrieve its content",
					responseContentType: .multipart(.byteranges)
                )
                .response(statusCode: .notFound, description: "Cannot find the Document")
                .response(statusCode: .badRequest, description: "Incorrect download token")
                .response(statusCode: .notFound, description: "Download token not found")
                .response(statusCode: .gone, description: "Token expired")
                .response(statusCode: .forbidden, description: "Token already used")

            // GET: Download a zipped folder using a download token
            tokenAuthGroup.get("download", "zipped", "folder", ":token", use: downloadZippedFolder)
                .openAPI(
                    summary: "Download a zipped folder",
                    description: "Download a folder at a specific path and retrieve its content",
					responseContentType: .multipart(.byteranges)
                )
                .response(statusCode: .badRequest, description: "Incorrect download token")
                .response(statusCode: .notFound, description: "Download token not found")
                .response(statusCode: .gone, description: "Token expired")
                .response(statusCode: .forbidden, description: "Token already used")
                .response(statusCode: .internalServerError, description: "Unable to create folder URL")
                .response(statusCode: .internalServerError, description: "Unable to create zip")
        }
    }

    private func registerDeleteRoutes(_ routes: RoutesBuilder) throws {
        routes.group(tags: TagObject(name: "documents",
                                     description: "Everything about documents")) { documentRoutes in
            let tokenAuthMiddleware = Token.authenticator()
            let guardAuthMiddleware = User.guardMiddleware()
            let tokenAuthGroup = documentRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

            // DELETE: Delete all documents
            tokenAuthGroup.delete("all", use: deleteAll)
                .openAPI(
                    summary: "Delete all documents",
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )
            // DELETE: Delete a specific document by its ID
            tokenAuthGroup.delete(":documentID", use: delete)
                .openAPI(
                    summary: "Delete a specific document",
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Cannot find the Document")

            // DELETE: Delete documents at a specific name and path
            tokenAuthGroup.delete("all", "at", "directory", use: deleteAllAtDirectory)
                .openAPI(
                    summary: "Delete documents at a specific name and path",
                    body: .type(Document.DirectoryInput.self),
                    contentType: .application(.json),
                    response: .type(HTTPResponseStatus.self),
                    responseContentType: .application(.json)
                )
                .response(statusCode: .notFound, description: "Cannot find the Document")
        }
    }
}

extension DocumentController {
    // MARK: - CREATE
    /// Handles the creation of a new document and uploads its file.
    ///
    /// This function extracts the necessary headers from the request, then calls the upload method to create the document.
    ///
    /// - Parameter req: The HTTP request containing the document information.
    /// - Returns: An `EventLoopFuture<Document>` representing the created document or an error.
    @Sendable
	func upload(req: Request) -> EventLoopFuture<Document> {
        return getHeaders(from: req).flatMap { result in
            // Call the upload method and return the created Document
			return upload(fileName: result.fileName, filePath: result.filePath, req: req)
        }
    }

    /// Handles the creation of multiple documents and uploads their files.
    ///
    /// This function decodes the `Document.MultipleInput`
	/// from the request body, then calls the upload method for each document in a batch.
    ///
    /// - Parameter req: The HTTP request containing the document information.
    /// - Returns: An array of `EventLoopFuture<Document>`, representing the created documents or errors.
    @Sendable
	func uploadMultiple(req: Request) async throws -> [Document.Output] {
        let input = try req.content.decode(Document.MultipleInput.self)
        let documents = try await uploadWithCollectedBody(with: input, on: req)
		return documents.map { $0.toOutput() }
    }

    // MARK: - READ
    /// Retrieves all documents.
    ///
    /// This function queries the database for all documents and returns them as an array.
    ///
    /// - Parameter req: The HTTP request containing database connection information.
    /// - Returns: An `EventLoopFuture<[Document]>`, representing the list of documents or an error.
    @Sendable
	func getAll(req: Request) async throws -> [Document.Output] {
        let documents = try await Document.query(on: req.db).all()
		return documents.map { $0.toOutput() }
    }

    /// Retrieves a specific document by its ID.
    ///
    /// This function finds a document in the database using its ID. If the document is not found, it throws an `Abort` error with a "notFound.document" reason.
    ///
    /// - Parameter req: The HTTP request containing the document ID and database connection information.
    /// - Returns: A `Document`, representing the retrieved document.
    @Sendable
	func getDocument(req: Request) async throws -> Document.Output {
        guard let document = try await Document.find(req.parameters.get("documentID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.document")
        }

		return document.toOutput()
    }

    /// Retrieves a download token for a specific document.
    ///
    /// This function retrieves the document ID from the request, finds the document in the database, constructs the file path, and then generates and returns a download token.
    ///
    /// - Parameter req: The HTTP request containing the document ID and database connection information.
    /// - Returns: A `String`, representing the download token.
    @Sendable
    func getDownloadToken(req: Request) async throws -> String {
        let documentID = try getDocumentID(from: req)
        let document = try await getDocument(with: documentID, on: req.db)
        let path = document.path + document.name
        return try await getDownloadToken(at: path, on: req)
    }

    /// Retrieves a download token for a specific folder.
    ///
    /// This function decodes `Document.ZipInput` from the request body to get the folder path and then generates and returns a download token.
    ///
    /// - Parameter req: The HTTP request containing the folder path and database connection information.
    /// - Returns: A `String`, representing the download token.
    @Sendable
    func getDownloadTokenForFolder(req: Request) async throws -> String {
        let input = try req.content.decode(Document.ZipInput.self)
        return try await getDownloadToken(at: input.path, on: req)
    }

    /// Downloads a file using a given download token.
    ///
    /// This function retrieves the download token from the request, validates it, constructs the file path, and then downloads the file. It also updates the `FileDownload` record to mark it as used.
    ///
    /// - Parameter req: The HTTP request containing the download token and database connection information.
    /// - Returns: A `Response`, representing the downloaded file.
    @Sendable
    func download(req: Request) async throws -> Response {
        let token = try getToken(on: req)
        let fileDownload = try await FileDownloadController().getFileDownload(with: token, on: req)
        try await FileDownloadController().validate(fileDownload)

        let filePath = req.application.directory.resourcesDirectory + "Uploads/" + fileDownload.filePath
        let response = try await download(at: filePath, on: req)

        fileDownload.usedAt = .now
        try await fileDownload.update(on: req.db)

        return response
    }


    /// Retrieves a download token for a zipped folder.
    ///
    /// This function retrieves the download token from the request, validates it, constructs the folder path, zips the folder contents, and returns the zipped file as a response.
    ///
    /// - Parameter req: The HTTP request containing the download token and database connection information.
    /// - Returns: A `Response`, representing the downloaded zipped folder.
    @Sendable
    func downloadZippedFolder(req: Request) async throws -> Response {
        let token = try getToken(on: req)
        let fileDownload = try await FileDownloadController().getFileDownload(with: token, on: req)

        // Validates the FileDownload record to ensure it can be used for downloading.
        try await FileDownloadController().validate(fileDownload)

        // Construct the path to the folder
        let folderPath = req.application.directory.resourcesDirectory + "Uploads/" + fileDownload.filePath

        // Creates a URL object from the provided folder path.
        guard let folderURL = URL(string: folderPath) else {
            throw Abort(.internalServerError, reason: "internalServerError.unableToCreateFolderURL")
        }

        // Create a temporary directory to store the zipped file
        let tempDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        do {
            // Zips the contents of the folder into a single zip file.
            try Zip.zipFiles(paths: [folderURL], zipFilePath: tempDirectoryURL, password: nil, progress: nil)

            // Create the response with the zipped file
            let response = req.fileio.streamFile(at: tempDirectoryURL.path)

            // Sets the content type and content disposition headers for the response.
            response.headers.add(name: .contentType, value: "application/zip")
            response.headers.add(name: .contentDisposition, value: "attachment; filename=\"$fileDownload.filePath).zip\"")

            // Updates the `FileDownload` record to mark it as used.
            fileDownload.usedAt = .now
            try await fileDownload.update(on: req.db)

            return response
        } catch {
            // Throws an error if there is an issue creating the zip file.
            throw Abort(.internalServerError, reason: "internalServerError.unableToCreateZip")
        }
    }


    // MARK: - UPDATE
    // MARK: - DELETE
    /// Deletes all documents.
    ///
    /// This function checks if the current user has admin role, retrieves all documents from the database, and deletes each document one by one. It returns a 204 No Content status upon successful deletion of all documents.
    ///
    /// - Parameter req: The HTTP request containing database connection information.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    @Sendable
    func deleteAll(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)

        let documents = try await Document.query(on: req.db).all()

        for document in documents {
            _ =  try await delete(document: document, on: req)
        }

        return .noContent
    }

    /// Deletes a specific document by its ID.
    ///
    /// This function checks if the current user has admin role, retrieves a specific document by its ID from the database, and deletes it. It returns a 204 No Content status upon successful deletion of the document.
    ///
    /// - Parameter req: The HTTP request containing the document ID and database connection information.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    @Sendable
    func delete(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)

        let documentID = try getDocumentID(from: req)
        let document = try await getDocument(with: documentID, on: req.db)

        return try await delete(document: document, on: req)
    }

    /// Deletes documents at a specific name and path.
    ///
    /// This function checks if the current user has admin role, retrieves all documents with a specific name and path from the database, and deletes each document one by one. It returns a 204 No Content status upon successful deletion of all documents.
    ///
    /// - Parameter req: The HTTP request containing the directory information (name and path) and database connection information.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    @Sendable
    func deleteAllAtDirectory(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkAdminRole(on: req)

        let input = try req.content.decode(Document.DirectoryInput.self)

        let documents = try await Document
            .query(on: req.db)
            .filter(\.$name == input.name)
            .filter(\.$path == input.path)
            .all()

        for document in documents {
             _ =  try await delete(document: document, on: req)
        }

        return .noContent
    }

}

// MARK: - Private Utils
extension DocumentController {
    // Define a struct to hold the result of headers extraction
    struct HeadersResult {
        let fileName: String
        let filePath: String
    }

    /// Extracts and validates 'fileName' and 'filePath' headers from an incoming request.
    /// - Parameter req: The incoming request from which headers are to be extracted.
    /// - Returns: A `Future` that will resolve with a `HeadersResult` containing the extracted file name and path, or a failure if either header is missing.
    private func getHeaders(from req: Request) -> EventLoopFuture<HeadersResult> {
        // Check if the 'fileName' header is present in the request
        guard let fileName = req.headers.first(name: "fileName") else {
            /// If the 'fileName' header is missing, return a failed future with a bad request error.
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "badRequest.missingFileNameHeader"))
        }

        // Check if the 'filePath' header is present in the request
        guard let filePath = req.headers.first(name: "filePath") else {
            /// If the 'filePath' header is missing, return a failed future with a bad request error.
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "badRequest.missingFilePathHeader"))
        }

        // Create an instance of HeadersResult with the extracted fileName and filePath
        let result = HeadersResult(fileName: fileName, filePath: filePath)

        /// Return a successful future containing the result
        return req.eventLoop.makeSucceededFuture(result)
    }
}

