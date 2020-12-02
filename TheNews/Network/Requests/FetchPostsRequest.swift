//
//  FetchPostsRequest.swift
//  TheNews
//
//  Created by Luís Silva on 02/12/2020.
//

import Foundation

extension Network.Request {
    class FetchPosts: NetworkRequest {
        typealias ResultType = [Int]

        let resource: String = "/topstories.json"
        let method: HTTPMethod = .get

        var completionHandler: ((Result<ResultType, NetworkError>) -> Void)?

        func handleResponse(_ result: Result<(Data?, HTTPStatusCode), NetworkError>) {
            switch result {
            case let .success((data, _)):
                guard let data = data else {
                    completionHandler?(.failure(.invalidResponse))
                    return
                }

                do {
                    let postItems = try JSONDecoder().decode(ResultType.self, from: data)
                    completionHandler?(.success(postItems))
                }
                catch(let e) {
                    print(e)
                    completionHandler?(.failure(.parserError))
                }

            case let .failure(error):
                completionHandler?(.failure(error))
            }
        }
    }

}
