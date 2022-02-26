//
//  RepositoryError.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation

public enum NetworkError: Error {
    
    case error(ErrorData)
    case unknown
    case network
    case timeout
    
    public struct ErrorData {
        public let statusCode: Int
        public let headers: [AnyHashable: Any]?
        public let body: Data?
        public let urlSessionError: Error?
        
        public init(statusCode: Int,
                    headers: [AnyHashable: Any]?,
                    body: Data?,
                    urlSessionError: Error?) {
            self.statusCode = statusCode
            self.headers = headers
            self.body = body
            self.urlSessionError = urlSessionError
        }
    }
}
