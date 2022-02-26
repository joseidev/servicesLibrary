//
//  File.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation

public protocol NetworkRequestInterceptor {
    func interceptRequest(_ request: NetworkRequest) -> NetworkRequest
}
