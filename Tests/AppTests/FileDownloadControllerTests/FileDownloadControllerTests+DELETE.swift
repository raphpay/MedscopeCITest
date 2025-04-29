//
//  FileDownloadControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 14/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Delete all
extension FileDownloadControllerTests {
    /// Tests the deletion of all file downloads
    /// - Given: A new file download
    /// - When: The file download is deleted
    /// - Then: The file download is deleted
    func testDeleteAllSucceed() async throws {
        let _ = try await FileDownloadControllerTests().create(at: expectedPath, on: app.db)

        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            do {
                let fileDownloads = try await FileDownload.query(on: app.db).all()
                XCTAssertEqual(fileDownloads.count, 0)
            } catch { }
        }
    }
}
