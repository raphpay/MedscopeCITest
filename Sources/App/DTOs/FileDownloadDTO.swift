//
//  FileDownloadDTO.swift
//
//
//  Created by Raphaël Payet on 02/09/2024.
//

import Fluent
import Vapor

extension FileDownload {
    /// Input structure for file download
    /// - Note: This structure is used to represent the input of a file download.
    ///     It contains the path of the file to download.
    struct Input: Content {
        let path: String
    }
}
