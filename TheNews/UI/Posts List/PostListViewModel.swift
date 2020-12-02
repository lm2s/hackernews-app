//
//  PostListViewModel.swift
//  TheNews
//
//  Created by Luís Silva on 02/12/2020.
//

import Foundation

protocol PostListViewModelDelegate: AnyObject {
    func postListViewModelDidLoadPosts(_ posts: [Network.Model.Post])
    func postListViewModelLoadFailed(_ error: HackerNewsAPIError)
}

class PostListViewModel {
    weak var delegate: PostListViewModelDelegate?

    let hackerNewsAPI: HackerNewsAPI

    var posts: [Network.Model.Post] = []

    init(hackerNewsAPI: HackerNewsAPI) {
        self.hackerNewsAPI = hackerNewsAPI

        self.posts = hackerNewsAPI.posts
    }

    func fetchPosts() {
        hackerNewsAPI.fetchTopPosts { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(posts):
                self.posts = posts
                self.delegate?.postListViewModelDidLoadPosts(posts)

            case let .failure(error):
                self.delegate?.postListViewModelLoadFailed(error)
            }
        }
    }
}
