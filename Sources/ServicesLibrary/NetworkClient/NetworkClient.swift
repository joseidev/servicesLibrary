//
//  NetworkClient.swift
//  TestProject
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Combine

public protocol NetworkClient {
    func request(_ request: NetworkRequest) throws -> Result<NetworkResponse, NetworkError>
    func request(_ request: NetworkRequest) throws -> AnyPublisher<NetworkResponse, NetworkError>
}
