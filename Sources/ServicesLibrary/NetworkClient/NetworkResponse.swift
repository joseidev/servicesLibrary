//
//  NetworkResponse.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation

public protocol NetworkResponse {
    var body: String { get }
    var data: Data { get }
    var status: Int { get }
    var headers: [AnyHashable: Any]? { get }
}
