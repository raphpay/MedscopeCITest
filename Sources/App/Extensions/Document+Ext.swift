//
//  UploadHelpers.swift
//
//
//  Created by Raphaël Payet on 16/07/2024.
//

import Foundation
import Vapor

extension Document {
    /// Get the content type of a file based on its extension
    /// - Parameter fileExtension: The file extension
    /// - Returns: The content type of the file
    /// - Note: This function determines the content type of a file based on its extension.
    ///    It returns "application/octet-stream" if the extension is not recognized.
    ///    The function uses a switch statement to check the file extension and set the content type accordingly.
    static func getContentType(of fileExtension: String)  -> String {
        // Determine the file's extension
        var contentType = "application/octet-stream"

        // Set the Content-Type based on the file extension
        switch fileExtension {
        case "dcm":
            contentType = "application/dicom"
        case "tcl":
            contentType = "application/x-tcl"
        case "stl":
            contentType = "model/stl"
        case "pdf":
            contentType = "application/pdf"
        case "jpg", "png", "jpeg":
            contentType = "image/jpeg"
        case "json":
            contentType = "application/json"
        default:
            contentType = "application/octet-stream"
        }

        return contentType
    }
}
