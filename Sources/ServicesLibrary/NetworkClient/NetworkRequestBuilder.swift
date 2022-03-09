//
//  File.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation

/// Utility class to create and modify NetworkRequest objects
public class NetworkRequestBuilder {
    private struct Request: NetworkRequest {
        let method: NetworkRequestMethod
        let serviceName: String
        let url: String
        let headers: [String: String]
        let body: Data?
    }
    
    private struct BuilderError: Error {}
    
    /// Adds query params to a NetworkRequest
    ///  - Returns: Returns the same NetworkRequest with the query params added
    public static func addQueryParams(_ networkRequest: NetworkRequest, queryParams: [String: String]) throws -> NetworkRequest {
        guard var urlComponents = URLComponents(string: networkRequest.url) else { throw BuilderError() }
        urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = urlComponents.url?.absoluteString else { throw BuilderError() }
        return Request(
            method: networkRequest.method,
            serviceName: networkRequest.serviceName,
            url: url,
            headers: networkRequest.headers,
            body: networkRequest.body)
    }

    /// Creates a NetworkRequest with the body formatted with form-urlEncoded format
    ///  - Returns: Returns a NetworkRequest object
    public static func buildWithURLEncodedBody(method: NetworkRequestMethod,
                                        serviceName: String,
                                        url: String,
                                        headers: [String: String],
                                        body: [String: String]) throws -> NetworkRequest {
        var urlComponents = URLComponents()
        let queryItems = body.map({URLQueryItem(name: $0.key, value: $0.value)})
        urlComponents.queryItems = queryItems
        guard let urlFormBody = urlComponents.query,
        let data =  urlFormBody.data(using: String.Encoding.utf8, allowLossyConversion: true) else { throw BuilderError() }
        return Request(
            method: method,
            serviceName: serviceName,
            url: url,
            headers: headers,
            body: data)
    }
    
    /// Creates a NetworkRequest with the body formatted with JSONEncoder
    ///  - Returns: Returns a NetworkRequest object
    public static func buildWithJSONEncodedBody<Body: Encodable>(method: NetworkRequestMethod,
                                        serviceName: String,
                                        url: String,
                                        headers: [String: String],
                                        body: Body) throws -> NetworkRequest {
        let encodedBody = try JSONEncoder().encode(body)
        return Request(
            method: method,
            serviceName: serviceName,
            url: url,
            headers: headers,
            body: encodedBody)
    }
}
