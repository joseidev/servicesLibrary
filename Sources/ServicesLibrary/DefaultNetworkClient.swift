//
//  File.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation
import SwiftUI

final public class DefaultNetworkClient: NSObject {

    private let configuration: NetworkClientConfiguration
    private let urlSessionDelegate: DefaulNetworkClientURLSessionDelegate
    
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
    
    private func request(url: String, headers: [String: String], body: String?, method: NetworkRequestMethod) throws -> Result<Response, NetworkError> {
        let group = DispatchGroup()
        let urlRequest = try buildURLRequest(url, headers: headers, method: method, body: body)
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
        if let statusCode = response?.statusCode {
            try self.evaluateStatusCode(statusCode)
        }
        return result
    }
}

private extension DefaultNetworkClient {
    func evaluateStatusCode(_ statusCode: Int) throws {
        switch statusCode {
        case URLError.networkConnectionLost.rawValue: throw NetworkError.network
        default: break
        }
    }
    
    func buildURLRequest(_ url: String, headers: [String: String], method: NetworkRequestMethod, body: String?) throws -> URLRequest {
        guard let url = URL(string: url) else { throw NetworkError.unknown }
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: configuration.cachePolicy ?? .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: configuration.timeoutInterval ?? 60)
        headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        if let body = body {
            urlRequest.httpBody = body.data(using: String.Encoding.utf8, allowLossyConversion: true)
        }
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}

extension DefaultNetworkClient: NetworkClient {
    public func request(_ request: NetworkRequest) throws -> Result<NetworkResponse, NetworkError> {
        return try self.request(
            url: request.url,
            headers: request.headers,
            body: request.body,
            method: request.method
        ).map({ $0 })
    }
}
