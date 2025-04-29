//
//  FileDownload+Ext.swift
//
//
//  Created by Raphaël Payet on 03/09/2024.
//

@testable import App
import XCTVapor
import Fluent

extension FileDownloadControllerTests {
    /// Create a new file download
    /// - Parameters:
    ///     - path: The path of the file to download
    ///     - db: The database connection to use for the creation
    /// - Returns: The created file download
    /// - Throws: An error if the file download creation fails
    func create(at path: String, on db: Database) async throws -> FileDownload {
        let downloadToken = [UInt8].random(count: 8).base64

        let expiresAt = Date().addingTimeInterval(3600)
        let fileDownload = FileDownload(filePath: path, downloadToken: downloadToken, expiresAt: expiresAt)

        try await fileDownload.save(on: db)

        return fileDownload
    }
}
