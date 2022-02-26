//
//  File.swift
//  
//
//  Created by Jose Ignacio de Juan Díaz on 26/2/22.
//

import Foundation

class DefaulNetworkClientURLSessionDelegate: NSObject {
    
    let configuration: NetworkClientConfiguration
    
    init(configuration: NetworkClientConfiguration) {
        self.configuration = configuration
    }

}

private extension DefaulNetworkClientURLSessionDelegate {
    struct Certificate {
        
        let filePath: String
        
        func secCertificate() -> SecCertificate? {
            guard
                let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.bundlePath + "/" + filePath)),
                let certificate = SecCertificateCreateWithData(nil, data as CFData)
            else {
                return nil
            }
            return certificate
        }
    }
    
    func certificatesForSSLPinning() -> [SecCertificate] {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath) else { return [] }
        let certificates: [SecCertificate] = files.compactMap { file in
            guard file.suffix(4) == ".cer" else { return nil }
            let certificate = Certificate(filePath: file)
            let secCertificate = certificate.secCertificate()
            return secCertificate
        }
        return certificates
    }
    
    func reject(with completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)) {
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    func accept(with serverTrust: SecTrust, _ completionHandler: ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)) {
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}

extension DefaulNetworkClientURLSessionDelegate: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if !configuration.isSSLPinningActive && challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            completionHandler(.useCredential, challenge.protectionSpace.serverTrust.map(URLCredential.init))
        } else {
            var secResult = SecTrustResultType.invalid
            guard
                challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                let serverTrust = challenge.protectionSpace.serverTrust,
                SecTrustEvaluate(serverTrust, &secResult) == errSecSuccess,
                let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0),
                self.certificatesForSSLPinning().contains(serverCert)
            else {
                return self.reject(with: completionHandler)
            }
            self.accept(with: serverTrust, completionHandler)
        }
    }
}

extension DefaulNetworkClientURLSessionDelegate: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}
