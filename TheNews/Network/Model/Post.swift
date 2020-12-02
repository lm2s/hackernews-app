//
//  Post.swift
//  TheNews
//
//  Created by Luís Silva on 02/12/2020.
//

import Foundation

extension Network.Model {
    struct Post: Decodable {
        let id: Int
        let title: String
        let url: URL
        let score: Int
        let comments: [Int]

        init(id: Int, title: String, url: URL, score: Int, comments: [Int]) {
            self.id = id
            self.title = title
            self.url = url
            self.score = score
            self.comments = comments
        }

        enum CodingKeys: String, CodingKey {
            case id, title, url, score
            case comments = "kids"
        }
    }
}

extension Network.Model.Post {
    var numberOfComments: Int { return comments.count }
}
