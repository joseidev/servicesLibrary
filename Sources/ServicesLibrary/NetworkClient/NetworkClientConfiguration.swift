//
//  NetworkClientConfiguration.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation

/// Configuration for DefatulNetworkClient
public protocol NetworkClientConfiguration {
    /// Range of status code that are considered success. If nil the default range will be (200...299)
    var successStatusCodeRange: ClosedRange<Int>? { get }
    /// If nil default will be .reloadIgnoringLocalAndRemoteCacheData
    var cachePolicy: NSURLRequest.CachePolicy? { get }
    /// If nil default will be 60
    var timeoutInterval: Double? { get }
    /// if true sslPinning is active
    var isSSLPinningActive: Bool { get }
}
