//
//  DocumentDTO.swift
//
//
//  Created by Raphaël Payet on 21/06/2024.
//

import Fluent
import Vapor
import VaporToOpenAPI

// MARK: Upload
extension Document {
	  /// Input structure for document
    /// - Note: This structure is used to represent the input of a document.
    ///    It contains the name, path, and file of the document.
    ///   The `toModel` function converts the input to a `Document` model.
  struct Input: Content, WithExample {
        let name: String
        let path: String
        let file : File

        /// Convert the input to a `Document` model
        /// - Parameter treatmentID: The ID of the treatment associated with the document. Default is nil.
        /// - Returns: A `Document` model representing the converted input.
        /// - Note: This function converts the input to a `Document` model.
        ///     It sets the name and path of the document.
        ///     If a treatment ID is provided, it sets the treatment ID of the document.
        ///     The function returns the converted `Document` model.
        func toModel(_ treatmentID: UUID? = nil) -> Document {
            Document(name: self.name, path: self.path)
        }

		static var example: Input {
			.init(name: "example.pdf",
				  path: "path/to/example/",
				  file: .init(data: Data().base64EncodedString(),
							  filename: "example.pdf"))
		}
    }

	  /// MultipleInput structure for document
    /// - Note: This structure is used to represent the input of multiple documents.
    ///    It contains an array of files and a path.
  struct MultipleInput: Content, WithExample {
        let files: [File]
        let path: String

		static var example: Document.MultipleInput {
			.init(files: [.init(data: Data().base64EncodedString(),
								filename: "example.pdf"),
						  .init(data: Data().base64EncodedString(),
											  filename: "example2.pdf")
			], path: "path/to/example/")
		}
    }
}

// MARK: Get
extension Document {
    /// ZipInput structure for document
    /// - Note: This structure is used to represent the input of a zipped folder.
    ///    It contains the path of the folder.
    struct ZipInput: Content, WithExample {
        let path: String

		static var example: ZipInput {
			.init(path: "path/to/example/")
		}
    }
}

// MARK: Delete
extension Document {
    /// DirectoryInput structure for document
    /// - Note: This structure is used to represent the input of a directory.
    ///   It contains the name and path of the directory.
    struct DirectoryInput: Content, WithExample {
        let name: String
        let path: String

		static var example: Document.DirectoryInput {
			.init(name: "example.pdf", path: "path/to/example/")
		}
    }
}

// MARK: - Output
extension Document {
  /// Output structure for Document
  /// - Note: This structure is used to represent the output of a Document
  /// It contains the id, name, path, and updatedDate timestamp of the document
	struct Output: Content, WithExample {
		let id: UUID?
		let name: String
		let path: String
		let updatedAt: Date?

		static var example: Output {
			.init(id: UUID(),
				  name: "example.pdf",
				  path: "path/to/example/",
				  updatedAt: .now)
		}
	}
}
