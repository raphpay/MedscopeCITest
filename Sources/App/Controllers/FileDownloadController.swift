//
//  FileDownloadController.swift
//
//
//  Created by Raphaël Payet on 02/09/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

struct FileDownloadController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
      // Group routes under "/api" and apply APIKeyCheckMiddleware for authentication
        let fileDownloads = routes.grouped("api", "fileDownloads").grouped(APIKeyCheckMiddleware())
        // Apply Token authentication and User guard middleware
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = fileDownloads.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // POST: Create a new file download
        tokenAuthGroup.post(use: create)
            .excludeFromOpenAPI()
        // GET: Retrieve all file downloads
        tokenAuthGroup.get(use: getAll)
            .excludeFromOpenAPI()

        // GET: Retrieve a file download by token
        tokenAuthGroup.delete("all", use: deleteAll)
            .excludeFromOpenAPI()
    }

    // MARK: - CREATE
    /// Create a new file download
    ///
    /// This function creates a new file download and returns it as a `FileDownload` object.
    /// - Parameter req: The incoming request containing the file path.
    /// - Returns: A `FileDownload` object representing the created file download.
    /// - Throws: An error if the file download cannot be created or if the database query fails.
    /// - Note: The file path is expected to be provided in the request body as JSON.
    ///       The function generates a unique download token and stores it in the database along with the file path.
    ///       The download token is a base64-encoded string that can be used to access the file.
    ///   The download link expires after 1 hour.
    @Sendable
    func create(req: Request) async throws -> FileDownload {
        let path = try req.content.decode(FileDownload.Input.self).path
        return try await create(at: path, on: req)
    }

    // MARK: - READ
    /// Retrieve all file downloads
    ///
    /// This function retrieves all file downloads from the database and returns them as an array of `FileDownload` objects.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An array of `FileDownload` objects representing the retrieved file downloads.
    /// - Throws: An error if the database query fails.
    @Sendable
    func getAll(req: Request) async throws -> [FileDownload] {
        let fileDownloads = try await FileDownload.query(on: req.db).all()
        return fileDownloads
    }

    // MARK: - DELETE
    /// Delete all file downloads
    ///
    /// This function deletes all file downloads from the database.
    /// - Parameter req: The incoming request containing the database connection.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the database deletion fails.
    /// - Note: This function is intended for administrative purposes and should be used with caution.
    ///      It will remove all file downloads from the database, including their associated tokens and paths.
    ///      Use this function only if you want to clear all file downloads.
    ///      It is recommended to implement proper authentication and authorization checks to restrict access to this endpoint.
    @Sendable
    func deleteAll(req: Request) async throws -> HTTPResponseStatus {
        try await FileDownload.query(on: req.db).all().delete(force: true, on: req.db)

        return .noContent
    }
}

extension FileDownloadController {
    /// Create a new file download with a unique token and expiration date.
    /// - Parameters:
    ///   - path: The path of the file to be downloaded.
    ///   - req: The incoming request containing the database connection.
    /// - Returns: A `FileDownload` object representing the created file download.
    /// - Throws: An error if the file download cannot be created or if the database query fails.
    /// - Note: This function generates a unique download token and stores it in the database along with the file path.
    ///      The download token is a base64-encoded string that can be used to access the file.
    ///      The download link expires after 1 hour.
    ///      The function also handles the creation of the file download object and its storage in the database.
    func create(at path: String, on req: Request) async throws -> FileDownload {
        let downloadToken = [UInt8].random(count: 8)
            .base64// Convert to base64 string
                .replacingOccurrences(of: "/", with: "-")
                .replacingOccurrences(of: "+", with: "_")

        // Store the token and associated file path in your database or an in-memory store
        let expiresAt = Date().addingTimeInterval(3600) // Link expires in 1 hour
        let fileDownload = FileDownload(filePath: path, downloadToken: downloadToken, expiresAt: expiresAt)

        try await fileDownload.save(on: req.db)

        return fileDownload
    }

    /// Retrieve a file download by token.
    ///
    /// This function retrieves a file download from the database using its token.
    /// - Parameters:
    ///   - token: The token of the file download to be retrieved.
    ///   - req: The incoming request containing the database connection.
    /// - Returns: A `FileDownload` object representing the retrieved file download.
    /// - Throws: An error if the file download cannot be found or if the database query fails.
    func getFileDownload(with token: String, on req: Request) async throws -> FileDownload {
        guard let fileDownload = try await FileDownload.query(on: req.db).filter(\.$downloadToken == token).first() else {
            throw Abort(.notFound, reason: "notFound.fileDownload")
        }

        return fileDownload
    }

    /// Validates a file download.
    /// - Parameter fileDownload: The file download to be validated.
    /// - Throws: An error if the file download is expired or if it has already been used.
    /// - Note: This function checks if the file download has expired and if it has already been used.
    ///      If either condition is true, it throws an error with a "gone.downloadTokenExpired" or "forbidden.tokenAlreadyUsed" reason.
    ///     This function is intended to be used before allowing the user to download the file.
    ///    It ensures that the file download is still valid and has not been used before.
    /// - Important: This function should be called before allowing the user to download the file.
    ///     It ensures that the file download is still valid and has not been used before.
    ///     If the file download is expired or has already been used, it throws an error.
    func validate(_ fileDownload: FileDownload) async throws {
        if fileDownload.expiresAt < Date() {
            throw Abort(.gone, reason: "gone.downloadTokenExpired")
        }

        if fileDownload.usedAt != nil {
            throw Abort(.forbidden, reason: "forbidden.tokenAlreadyUsed")
        }
    }

    /// Marks a file download as used.
    /// - Parameters:
    ///   - fileDownload: The file download to be marked as used.
    ///   - req: The incoming request containing the database connection.
    ///   - Throws: An error if the file download cannot be updated or if the database query fails.
    /// - Note: This function updates the "usedAt" property of the file download to the current date and time.
    ///      It is used to mark a file download as used after the user has downloaded it.
    ///   This function should be called after the file has been successfully downloaded.
    ///   It ensures that the file download is marked as used and cannot be used again.
    /// - Important: This function should be called after the file has been successfully downloaded.
    ///     It ensures that the file download is marked as used and cannot be used again.
    ///   If the file download cannot be updated or if the database query fails, it throws an error.
    func markAsUsed(_ fileDownload: FileDownload, on req: Request) async throws  {
        fileDownload.usedAt = .now
        try await fileDownload.update(on: req.db)
    }
}
