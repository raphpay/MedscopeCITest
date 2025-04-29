//
//  File.swift
//  
//
//  Created by Raphaël Payet on 01/08/2024.
//

@testable import App
import XCTVapor
import Fluent

struct Utils {
    static func prepareHeaders(apiKey: APIKey?, token: Token?, on req: XCTHTTPRequest) -> XCTHTTPRequest {
        var newReq = req
        if let token = token {
            newReq.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }
        if let apiKey = apiKey {
            newReq.headers.add(name: "api-key", value: apiKey.value)
        }
        
        return newReq
    }
    
    static func prepareDocumentHeaders(fileName: String?, filePath: String?, fileContent: Data?, req: XCTHTTPRequest) -> XCTHTTPRequest {
        var newReq = req
        
        if let fileName = fileName {
            newReq.headers.add(name: "fileName", value: fileName)
        }
        if let filePath = filePath {
            newReq.headers.add(name: "filePath", value: filePath)
        }
        if fileName != nil && filePath != nil,
           let fileContent = fileContent {
            newReq.headers.contentType = .json
            newReq.body = .init(data: fileContent)
        }
        
        return newReq
    }
}
