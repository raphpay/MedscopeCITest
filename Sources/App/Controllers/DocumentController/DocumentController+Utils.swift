//
//  DocumentController+Utils.swift
//
//
//  Created by Raphaël Payet on 19/07/2024.
//

import Fluent
import Vapor
import NIOCore

// MARK: - GET
extension DocumentController {
    /// Extracts and validates the 'documentID' parameter from an incoming request.
    /// - Parameter req: The incoming request from which the 'documentID' parameter is to be extracted.
    /// - Throws: `Abort` error with a bad request status if the 'documentID' parameter is missing or incorrectly formatted.
    /// - Returns: The validated `Document.IDValue`.
    func getDocumentID(from req: Request) throws -> Document.IDValue {
        guard let documentID = req.parameters.get("documentID", as: Document.IDValue.self) else {
            throw Abort(.badRequest, reason: "badRequest.missingOrIncorrectDocumentID")
        }

        return documentID
    }

    /// Retrieves a `Document` instance from the database using its ID.
    /// - Parameter id: The `Document.IDValue` representing the document's unique identifier.
    /// - Parameter db: The database connection to use for fetching the document.
    /// - Throws: `Abort` error with a not found status if no document is found with the given ID.
    /// - Returns: The retrieved `Document` instance.
	func getDocument(with id: Document.IDValue, on database: Database) async throws -> Document {
        guard let document = try await Document.find(id, on: database) else {
            throw Abort(.notFound, reason: "notFound.document")
        }

        return document
    }

    /// Retrieves an optional `Document` instance from the database using its ID.
    /// - Parameter id: The `Document.IDValue` representing the document's unique identifier.
    /// - Parameter db: The database connection to use for fetching the document.
    /// - Returns: An optional `Document` instance. If no document is found, returns `nil`.h
    func getOptionalDocument(with id: Document.IDValue, on database: Database) async throws -> Document? {
        guard let document = try await Document.find(id, on: database) else {
            return nil
        }

        return document
    }

    /// Downloads a file from the specified path and returns it as an HTTP response.
    /// - Parameter path: The local file system path of the file to be downloaded.
    /// - Parameter req: The incoming request that triggered the download.
    /// - Throws: `Abort` error with a not found status if the file does not exist at the given path.
    /// - Returns: An HTTP `Response` object containing the file data and appropriate headers for download.
    func download(at path: String, on req: Request) async throws -> Response {
        if !FileManager.default.fileExists(atPath: path) {
            throw Abort(.notFound, reason: "notFound.file")
        }

        // Determine the file's extension and content-type
        let fileExtension = (path as NSString).pathExtension.lowercased()
        let contentType = Document.getContentType(of: fileExtension)

        let response = req.fileio.streamFile(at: path)
        response.headers.add(name: .contentType, value: contentType)
        response.headers.add(name: .contentDisposition, value: "attachment; fileName=$path)")

        return response
    }

    /// Generates and returns a download token for the specified file path.
    /// - Parameter path: The local file system path of the file for which to generate a download token.
    /// - Parameter req: The incoming request that triggered the token generation.
    /// - Throws: `Abort` error with a bad request status if no download token can be created.
    /// - Returns: A string representing the generated download token.
    func getDownloadToken(at path: String, on req: Request) async throws -> String {
        let fileDownload = try await FileDownloadController().create(at: path, on: req)
        return fileDownload.downloadToken
    }

    /// Retrieves a token from the incoming request parameters.
    /// - Parameter req: The incoming request containing the token parameter.
    /// - Throws: `Abort` error with a bad request status if the token parameter is missing.
    /// - Returns: A string representing the retrieved token.
    func getToken(on req: Request) throws -> String {
        guard let token = req.parameters.get("token") else {
            throw Abort(.badRequest, reason: "badRequest.token")
        }

        return token
    }
}

// MARK: - CREATE
extension DocumentController {
    /// Uploads a file to the specified directory and returns a `Document` instance representing the uploaded file.
    /// - Parameters:
    ///   - fileName: The original name of the uploaded file.
    ///   - filePath: The path where the file should be stored in the upload directory.
    ///   - req: The incoming request containing the file data.
    /// - Returns: An `EventLoopFuture<Document>` that will resolve with a `Document` instance representing the uploaded file or fail with an error if the upload process encounters issues.
    func upload(fileName: String, filePath: String, req: Request) -> EventLoopFuture<Document> {
        enum BodyStreamWritingToDiskError: Error {
            case streamFailure(Error)
            case fileHandleClosedFailure(Error)
            case multipleFailures([BodyStreamWritingToDiskError])
        }

        // Construct the directory path where the file will be uploaded
        let directory = req.application.directory.resourcesDirectory + "Uploads/" + filePath

        // Ensure the upload directory exists and create it if it doesn't.
        do {
            try FileManager.default.createDirectory(atPath: directory,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            // Failed to create upload directory
            return req.eventLoop.makeFailedFuture(Abort(.internalServerError,
                                                        reason: "internalServerError.directoryCreation"))
        }

        // Generate a unique file name to avoid conflicts in the upload directory.
        let uniqueFileName = generateUniqueFileName(for: fileName, in: directory)
        let document = Document(name: uniqueFileName, path: filePath)

        return req.application.fileio.openFile(
            path: directory + uniqueFileName,
            mode: .write,
            flags: .allowFileCreation(),
            eventLoop: req.eventLoop
        ).flatMap { fileHandle in
            let promise = req.eventLoop.makePromise(of: Document.self)
            let fileHandleBox = NIOLoopBound(fileHandle, eventLoop: req.eventLoop)

            // Process the incoming file data and write it to disk.
            req.body.drain { part in
                let fileHandle = fileHandleBox.value
                switch part {
                case .buffer(let buffer):
                    return req.application.fileio.write(
                        fileHandle: fileHandle,
                        buffer: buffer,
                        eventLoop: req.eventLoop
                    )
                case .error(let drainError):
                    do {
                        try fileHandle.close()
                        promise.fail(BodyStreamWritingToDiskError.streamFailure(drainError))
                    } catch {
                        promise.fail(BodyStreamWritingToDiskError.multipleFailures([
                            .fileHandleClosedFailure(error),
                            .streamFailure(drainError)
                        ]))
                    }
                    return req.eventLoop.makeSucceededFuture(())
                case .end:
                    do {
                        try fileHandle.close()
                        document.save(on: req.db).whenComplete { result in
                            switch result {
                            case .success:
                                promise.succeed(document)
                            case .failure(let error):
                                promise.fail(error)
                            }
                        }
                    } catch {
                        promise.fail(BodyStreamWritingToDiskError.fileHandleClosedFailure(error))
                    }
                    return req.eventLoop.makeSucceededFuture(())
                }
            }

            return promise.futureResult
        }
    }


    /// Uploads multiple documents to the specified directory and returns an array of `Document` instances representing the uploaded files.
    /// - Parameters:
    ///   - input: The `Document.MultipleInput` containing the directory path and file names.
    ///   - req: The incoming request containing the file data.
    /// - Returns: An array of `Document` instances representing the uploaded files.
    func uploadWithCollectedBody(with input: Document.MultipleInput, on req: Request) async throws -> [Document] {
        var documents: [Document] = []
        let uploadPath = req.application.directory.resourcesDirectory + "Uploads/" + input.path

        if !FileManager.default.fileExists(atPath: uploadPath) {
            do {
                try FileManager.default.createDirectory(atPath: uploadPath, withIntermediateDirectories: true)
            } catch {
                throw Abort(.internalServerError, reason: "internalServerError.failedToCreateDirectory")
            }
        }

        for file in input.files {
            let fileName = file.filename.replacingOccurrences(of: " ", with: "")
            let uniqueFileName = generateUniqueFileName(for: fileName, in: uploadPath)
            try await req.fileio.writeFile(file.data, at: uploadPath + uniqueFileName )
            let document = Document(name: uniqueFileName, path: input.path)
            try await document.save(on: req.db)
            documents.append(document)
        }

        return documents
    }

    // TODO: Use this more widely
    /// Retrieves a `Document` instance from the database using its ID.
    /// - Parameter id: The `Document.IDValue` representing the document's unique identifier.
    /// - Parameter req: The incoming request that contains the database connection.
    /// - Throws: `Abort` error with a not found status if no document is found with the given ID.
    /// - Returns: The retrieved `Document` instance.
    func getDocument(with id: Document.IDValue, on req: Request) async throws -> Document {
        guard let document = try await Document.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.document")
        }

        return document
    }

    /// Generates a unique file name to avoid conflicts in the specified directory.
    /// - Parameters:
    ///   - fileName: The original name of the file.
    ///   - directory: The directory where the file will be stored.
    /// - Returns: A unique file name with an incremented suffix if necessary.
    private func generateUniqueFileName(for fileName: String, in directory: String) -> String {
        var uniqueFileName = fileName
        _ = (fileName as NSString).pathExtension
        _ = (fileName as NSString).deletingPathExtension

        var suffix = 1
        while FileManager.default.fileExists(atPath: directory + uniqueFileName) {
            uniqueFileName = "$fileNameWithoutExtension)-$suffix).$fileExtension)"
            suffix += 1
        }

        return uniqueFileName
    }

}

// MARK: - DELETE
extension DocumentController {
    /// Deletes a document from the database and removes its associated file from the file system.
    /// - Parameters:
    ///   - document: The `Document` instance to be deleted.
    ///   - req: The incoming request containing the database connection.
    /// - Returns: An `HTTPResponseStatus` indicating that no content is being returned (204 No Content).
    /// - Throws: An error if the file deletion fails or if the document cannot be deleted from the database.
    /// - Note: This method also attempts to delete any empty directories that may have been created during the upload process.
    /// - Note: The method uses a while loop to traverse up the directory structure and delete any empty directories.
    func delete(document: Document, on req: Request) async throws -> HTTPResponseStatus {
        let baseDirectory = req.application.directory.resourcesDirectory + "Uploads/"
        let filePath = baseDirectory + document.path + document.name
        if FileManager.default.fileExists(atPath: filePath) {
            try FileManager.default.removeItem(atPath: filePath)
        }

        // Delete empty directories
        var currentPath = (filePath as NSString).deletingLastPathComponent
        while currentPath.hasPrefix(baseDirectory) && currentPath != baseDirectory {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: currentPath)
                if contents.isEmpty {
                    try FileManager.default.removeItem(atPath: currentPath)
                } else {
                    break // Directory not empty, stop here
                }
            } catch {
                // Failed to remove directory
                break
            }
            currentPath = (currentPath as NSString).deletingLastPathComponent
        }

        try await document.delete(force: true, on: req.db)

        return .noContent
    }
}
