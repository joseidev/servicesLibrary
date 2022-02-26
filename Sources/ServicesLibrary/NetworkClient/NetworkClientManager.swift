//
//  NetworkClientManager.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation

public struct NetworkClientManager {
    
    private let client: NetworkClient
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
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
