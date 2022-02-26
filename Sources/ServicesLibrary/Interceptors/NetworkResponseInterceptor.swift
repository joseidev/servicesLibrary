//
//  NetworkResponseInterceptor.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation

public protocol NetworkResponseInterceptor {
    func interceptResponse(_ response: NetworkResponse) throws -> Result<NetworkResponse, NetworkError>
}
