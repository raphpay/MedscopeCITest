//
//  FileDownloadControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 03/09/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Get All
extension FileDownloadControllerTests {
    /// Tests the retrieval of all file downloads
    /// - Given: A new file download
    /// - When: The file downloads are retrieved
    /// - Then: The file downloads are retrieved
    func testGetAllWithDataSucceed() async throws {
        let _ = try await FileDownloadControllerTests().create(at: expectedPath, on: app.db)

        try await app.test(.GET, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let fileDownloads = try res.content.decode([FileDownload].self)
                XCTAssertEqual(fileDownloads.count, 1)
                XCTAssertEqual(fileDownloads[0].filePath, expectedPath)
            } catch { }
        }
    }

    /// Tests the retrieval of all file downloads
    /// - Given: No file downloads
    /// - When: The file downloads are retrieved
    /// - Then: The file downloads are retrieved
    /// Note: The file downloads can be empty.
    func testGetAllWithoutDataSucceed() async throws {
        try await app.test(.GET, baseURL) { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let fileDownloads = try res.content.decode([FileDownload].self)
                XCTAssertEqual(fileDownloads.count, 0)
            } catch { }
        }
    }
}
