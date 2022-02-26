//
//  NetworkClientManager.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation

/**
 Class with method to make network requests
 
 This class wrapps the network client and applies the interceptors to the network request and response.
 */
public struct NetworkClientManager {
    
    private let client: NetworkClient
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
    /**
     Method to make request injecting interceptors
     
     - Parameter request: A NetworkRequest
     - Parameter requestInterceptors: These interceptors will modify the request
     - Parameter responseInterceptors: These interceptores will modify the response
     - Throws:
        - NetworkError.network
        if there is no conexion
        - NetworkError.timeout
        if no response is obtained
        - NetworkError.ErrorData
        If the service returns status code different to 200...299
        or no data is received
     - Returns: A result object modified by the interceptors
     */
    public func request(_ request: NetworkRequest,
                        requestInterceptors: [NetworkRequestInterceptor],
                        responseInterceptors: [NetworkResponseInterceptor]) throws -> Result<NetworkResponse, NetworkError> {
        let request = requestInterceptors.reduce(request) { request, interceptor in
            return interceptor.interceptRequest(request)
        }
        let result = try self.client.request(request)
        let response: Result<NetworkResponse, NetworkError> = try responseInterceptors.reduce(result) { result, interceptor in
            switch result {
            case .success(let response):
                return try interceptor.interceptResponse(response)
            case .failure:
                return result
            }
        }
        return response
    }
}
