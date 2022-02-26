//
//  File.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation

public struct InterceptedRequest: NetworkRequest {
    public var method: NetworkRequestMethod
    public var body: String?
    public let serviceName: String
    public let url: String
    public let headers: [String : String]
    
    public init(serviceName: String,
                url: String,
                headers: [String : String],
                method: NetworkRequestMethod,
                body: String?) {
        self.serviceName = serviceName
        self.url = url
        self.headers = headers
        self.body = body
        self.method = method
    }
}
