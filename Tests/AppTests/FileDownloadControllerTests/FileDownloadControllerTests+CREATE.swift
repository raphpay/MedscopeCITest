//
//  FileDownloadControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 14/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - CREATE
extension FileDownloadControllerTests {
    /// Tests the creation of a new file download
    /// - Given: A new file download
    /// - When: The file download is created
    /// - Then: The file download is created
    func testCreateSucceed() async throws {
        let pathInput = FileDownload.Input(path: expectedPath)
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(pathInput)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let fileDownload = try res.content.decode(FileDownload.self)
                XCTAssertEqual(fileDownload.filePath, expectedPath)
            } catch { }
        }
    }
}
