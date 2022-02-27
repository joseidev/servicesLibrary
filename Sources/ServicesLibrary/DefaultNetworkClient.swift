//
//  File.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation
import Combine

/**
 Network implementation
 
 This class is meant to be used with the NetworkClientManager so is possible to use interceptors.
 It is possible to use the network client directly to make request if you are sure that
 interceptors are not going to be needed.
 */

final public class DefaultNetworkClient: NSObject {

    private let configuration: NetworkClientConfiguration
    private let urlSessionDelegate: DefaulNetworkClientURLSessionDelegate
    private let cancelableSet = Set<AnyCancellable>()
    
    public init(configuration: NetworkClientConfiguration) {
        self.configuration = configuration
        self.urlSessionDelegate = DefaulNetworkClientURLSessionDelegate(configuration: configuration)
        super.init()
    }
    
    struct Response: NetworkResponse {
        let data: Data
        let status: Int
        let headers: [AnyHashable: Any]?
        var body: String {
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    private func requestWithResult(_ networkRequest: NetworkRequest) throws -> Result<Response, NetworkError> {
        let group = DispatchGroup()
        let urlRequest = try buildURLRequest(networkRequest)
        var result: Result<Response, NetworkError> = .failure(NetworkError.timeout)
        var response: HTTPURLResponse?
        group.enter()
        let session = URLSession(configuration: .default, delegate: urlSessionDelegate, delegateQueue: nil)
        session.dataTask(with: urlRequest) { [weak self] data, httpResponse, error in
            defer {
                group.leave()
            }
            response = httpResponse as? HTTPURLResponse
            guard let statusCode = (httpResponse as? HTTPURLResponse)?.statusCode else {
                result = .failure(.unknown)
                return
            }
            if URLError.networkConnectionLost.rawValue == statusCode {
                result = .failure(.network)
                return
            }
            let statusCodeRange = self?.configuration.successStatusCodeRange ?? (200...299)
            guard statusCodeRange.contains(statusCode),
                  let dataTaskResponse = data.map( {Response(data: $0, status: statusCode, headers: response?.allHeaderFields)} ) else {
                      let errorData = NetworkError.ErrorData(
                        statusCode: statusCode,
                        headers: response?.allHeaderFields,
                        body: data,
                        urlSessionError: error)
                      result = .failure(.error(errorData))
                      return
                  }
            result = .success(dataTaskResponse)
        }.resume()
        group.wait()
        return result
    }
    
    private func requestWithPublisher(_ networkRequest: NetworkRequest) throws -> AnyPublisher<NetworkResponse, NetworkError> {
        let urlRequest = try buildURLRequest(networkRequest)
        let session = URLSession(configuration: .default, delegate: urlSessionDelegate, delegateQueue: nil)
        return session.dataTaskPublisher(for: urlRequest)
            .retry(1)
            .tryMap { [weak self] data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.unknown
                }
                if URLError.networkConnectionLost.rawValue == httpResponse.statusCode {
                    throw NetworkError.network
                }
                let statusCodeRange = self?.configuration.successStatusCodeRange ?? (200...299)
                guard statusCodeRange.contains(httpResponse.statusCode) else {
                    throw NetworkError.error(NetworkError.ErrorData(statusCode: httpResponse.statusCode,
                                                                     headers: httpResponse.allHeaderFields,
                                                                     body: data,
                                                                     urlSessionError: nil))
                }
                return Response(data: data, status: httpResponse.statusCode, headers: httpResponse.allHeaderFields)
            }
            .mapError { error -> NetworkError in
                return error as? NetworkError ?? .unknown
            }
            .eraseToAnyPublisher()
    }
}

private extension DefaultNetworkClient {
    func buildURLRequest(_ networkRequest: NetworkRequest) throws -> URLRequest {
        guard let url = URL(string: networkRequest.url) else { throw NetworkError.unknown }
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: configuration.cachePolicy ?? .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: configuration.timeoutInterval ?? 60)
        networkRequest.headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        if let body = networkRequest.body {
            urlRequest.httpBody = body.data(using: String.Encoding.utf8, allowLossyConversion: true)
        }
        urlRequest.httpMethod = networkRequest.method.rawValue
        return urlRequest
    }
}

extension DefaultNetworkClient: NetworkClient {
    public func request(_ request: NetworkRequest) throws -> Result<NetworkResponse, NetworkError> {
        return try self.requestWithResult(request).map({ $0 })
    }
    
    public func request(_ request: NetworkRequest) throws -> AnyPublisher<NetworkResponse, NetworkError> {
        return try self.requestWithPublisher(request)
            .eraseToAnyPublisher()
    }
}
