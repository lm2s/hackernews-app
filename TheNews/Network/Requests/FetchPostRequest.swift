//
//  FetchPostRequest.swift
//  TheNews
//
//  Created by Luís Silva on 02/12/2020.
//

import Foundation

extension Network.Request {
    class FetchPost: NetworkRequest {
        typealias ResultType = Network.Model.Post

        let itemId: Int

        var resource: String { return "/item/\(itemId).json" }
        let method: HTTPMethod = .get

        var completionHandler: ((Result<ResultType, NetworkError>) -> Void)?

        init(itemId: Int) {
            self.itemId = itemId
        }

        func handleResponse(_ result: Result<(Data?, HTTPStatusCode), NetworkError>) {
            switch result {
            case let .success((data, _)):
                guard let data = data else {
                    completionHandler?(.failure(.invalidResponse))
                    return
                }

                do {
                    let post = try JSONDecoder().decode(ResultType.self, from: data)
                    completionHandler?(.success(post))
                }
                catch {
                    completionHandler?(.failure(.parserError))
                }

            case let .failure(error):
                completionHandler?(.failure(error))
            }
        }
    }

}
