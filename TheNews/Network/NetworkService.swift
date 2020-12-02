//
//  NetworkService.swift
//  TheNews
//
//  Created by Luís Silva on 02/12/2020.
//

import Foundation

enum Network {
    enum Request { }
    enum Model { }
}

class NetworkService {
    let baseURL: URL
    let operationQueue: OperationQueue
    let urlSession: URLSession

    init(baseURL: URL) {
        self.baseURL = baseURL
        self.operationQueue = OperationQueue()
        self.urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: operationQueue)
    }

    func perform<T: NetworkRequest>(request: T) {
        let url = self.baseURL.appendingPathComponent(request.resource)
        let urlRequest = URLRequest(url: url)

        let task = self.urlSession.dataTask(with: urlRequest) { (data, urlResponse, error) in
            if let error = error {
                request.handleResponse(.failure(.connectionError(error.localizedDescription)))
                return
            }

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                request.handleResponse(.failure(.invalidResponse))
                return
            }

            request.handleResponse(.success((data, httpResponse.statusCode)))
        }

        task.resume()
    }
}

enum NetworkError: Error {
    case connectionError(String)
    case invalidResponse
    case parserError
}

typealias HTTPStatusCode = Int

protocol NetworkRequest {
    associatedtype ResultType

    var resource: String { get }
    var method: HTTPMethod { get }
    // query items ...
    // form parameters ...

    var completionHandler: ((Result<ResultType, NetworkError>) -> Void)? { get set }

    func handleResponse(_ result: Result<(Data?, HTTPStatusCode), NetworkError>)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    // ...
}
