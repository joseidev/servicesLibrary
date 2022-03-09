//
//  NetworkClientConfiguration.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation

/// Configuration for DefatulNetworkClient
public struct NetworkClientConfiguration {
    let successStatusCodeRange: ClosedRange<Int>
    let cachePolicy: NSURLRequest.CachePolicy
    let timeoutInterval: Double
    let isSSLPinningActive: Bool
    
    public static func getDefaultConfiguration() -> NetworkClientConfiguration {
        return NetworkClientConfiguration(
            successStatusCodeRange: (200...299),
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 60,
            isSSLPinningActive: false)
    }
}
