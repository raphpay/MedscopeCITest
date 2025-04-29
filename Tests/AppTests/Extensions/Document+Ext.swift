//
//  Document+Ext.swift
//
//
//  Created by Raphaël Payet on 25/07/2024.
//

@testable import App
import XCTVapor
import Fluent

extension DocumentControllerTests {
    /// Create a new document
    /// - Parameters:
    ///   - db: The database connection to use for the creation
    /// - Returns: The created document
    /// - Throws: An error if the document creation fails
    func createExpectedDocument(on db: Database) async throws -> Document {
        let document = Document(name: expectedFileName, path: expectedFilePath)
        try await document.save(on: db)
        return document
    }

    /// Create a new document
    /// - Parameters:
    ///   - db: The database connection to use for the creation
    /// - Returns: The created document
    /// - Throws: An error if the document creation fails
    func createExpectedFile(with data: Data, at path: String) throws {
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        let fileDirectory = path + expectedFileName
        FileManager.default.createFile(atPath: fileDirectory, contents: data)
    }
}
