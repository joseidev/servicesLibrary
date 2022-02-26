//
//  NetworkRequest.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation

public protocol NetworkRequest {
    var method: NetworkRequestMethod { get }
    var serviceName: String { get }
    var url: String { get }
    var headers: [String: String] { get }
    var body: String? { get }
}

public enum NetworkRequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
