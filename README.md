# ServicesLibrary

Networking library 


### Request
The request method from NetworkClientManager takes as arguments arrays of interceptors, one for request and another for response interceptors.

The interceptors modify the request or response.

```swift
// Result as returned object
func request(_ request: NetworkRequest,
                        requestInterceptors: [NetworkRequestInterceptor],
                        responseInterceptors: [NetworkResponseInterceptor]) throws -> Result<NetworkResponse, NetworkError>

// AnyPublisher as returned object
func request(_ request: NetworkRequest,
                        requestInterceptors: [NetworkRequestInterceptor]) throws -> AnyPublisher<NetworkResponse, NetworkError>
```


### Request interceptors
One use case for request interceptors is to add common headers to different requests as for example an authentication header.

### Response interceptors
Response interceptors are used to make validations or modify the response before is returned.
