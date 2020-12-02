//
//  HackerNewsAPI.swift
//  TheNews
//
//  Created by Luís Silva on 02/12/2020.
//

import Foundation

enum HackerNewsAPIError: Error {
    case networkError(String)
    case unableToFetch
}

class HackerNewsAPI {
    let networkService: NetworkService
    let persistenceController: PersistenceController

    private(set) var posts: [Network.Model.Post] = []

    init(networkService: NetworkService, persistenceController: PersistenceController) {
        self.networkService = networkService
        self.persistenceController = persistenceController

        loadFromCache()
    }

    private func loadFromCache() {
        persistenceController.viewContext.performAndWait {
            let managedPosts = ManagedPost.fetchAll(in: self.persistenceController.viewContext)

            self.posts = managedPosts.enumerated().map {
                let id = Int($1.id)
                let createdAt = $1.createdAt as Date
                let title = $1.title
                let url = URL(string: $1.url)!
                let score = Int($1.score)
                let comments = ($1.comments as? Array<Int>) ?? []
                let index = $0

                return Network.Model.Post(id: id, createdAt: createdAt, title: title, url: url, score: score, comments: comments, index: index)
            }
        }
    }
}

// MARK: - Posts Fetching
extension HackerNewsAPI {
    func fetchTopPosts(completionHandler: @escaping ((_ result: Result<[Network.Model.Post], HackerNewsAPIError>) -> Void)) {
        let request = Network.Request.FetchPosts()

        request.completionHandler = { result in
            switch result {
            case let .success(postsIds):
                print(postsIds)

                var posts: [Network.Model.Post] = []
                let dispatchGroup = DispatchGroup()

                let postsIdsToFetch = postsIds[0..<min(100, postsIds.count)]

                postsIdsToFetch.enumerated().forEach { (index, id) in
                    dispatchGroup.enter()

                    self.fetchPost(id: id) { post in
                        if var p = post {
                            p.index = index
                            posts.append(p)
                        }
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    //posts.sort(by: { $0.score > $1.score } )
                    posts.isEmpty ? completionHandler(.failure(.unableToFetch)) : completionHandler(.success(posts))

                    self.cachePosts(posts)
                }

            case let .failure(error):
                print(error)
                completionHandler(.failure(.networkError(error.localizedDescription)))
            }
        }

        networkService.perform(request: request)
    }

    private func fetchPost(id: Int, completionHandler: @escaping ((_ post: Network.Model.Post?) -> Void)) {
        let request = Network.Request.FetchPost(itemId: id)
        request.completionHandler = { result in
            switch result {
            case let .success(post):
                completionHandler(post)

            case .failure:
                completionHandler(nil)

            }
        }
        networkService.perform(request: request)
    }

    private func cachePosts(_ posts: [Network.Model.Post]) {
        guard !posts.isEmpty else { return }

        persistenceController.viewContext.perform {
            let managedPostsToDelete = ManagedPost.fetchAll(in: self.persistenceController.viewContext)
            managedPostsToDelete.forEach {
                self.persistenceController.viewContext.delete($0)
            }

            posts.forEach {
                let managedPost = ManagedPost(context: self.persistenceController.viewContext)
                managedPost.id = Int64($0.id)
                managedPost.createdAt = $0.createdAt as NSDate
                managedPost.title = $0.title
                managedPost.url = $0.url.absoluteString
                managedPost.score = Int64($0.score)
                managedPost.comments = $0.comments as NSArray
                managedPost.index = Int64($0.index)
            }

            do {
                try self.persistenceController.viewContext.save()

                print("cached \(posts.count) posts")
            }
            catch(let e) {
                assertionFailure("Failed to cache posts \(e)")
            }
        }
    }
}
