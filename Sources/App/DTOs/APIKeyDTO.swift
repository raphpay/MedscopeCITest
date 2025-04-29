//
//  APIKeyDTO.swift
//
//
//  Created by Raphaël Payet on 13/07/2024.
//

import Fluent
import Vapor

extension APIKey {
    /// Input structure for API key
    /// - Note: This structure is used to represent the input of an API key.
    ///     It contains the name of the API key.
    ///     The `generate` function generates a random API key of a specified length.
    struct Input: Content {
        let name: String

        /// Generate a random API key
        /// - Parameter length: The length of the generated API key. Default is 32 characters.
        /// - Returns: A random string of the specified length.
        /// - Note: This function generates a random string of the specified length using the provided characters.
        ///     It uses the characters "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".
        ///     The function returns the generated string.
        func generate(_ length: Int = 32) -> String {
            let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let charactersArray = Array(characters)
            var value = ""

            for _ in 0..<length {
                if let randomCharacter = charactersArray.randomElement() {
                    value.append(randomCharacter)
                }
            }

            return value
        }
    }

    /// Output structure for API key
    /// - Note: This structure is used to represent the output of an API key.
    ///     It contains the name and value of the API key.
    struct Output: Content {
        let name: String
        let value: String
    }
}
