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
        let createdAt: Date
        let title: String
        let url: URL
        let score: Int
        let comments: [Int]
        var index: Int = 0

        init(id: Int, createdAt: Date, title: String, url: URL, score: Int, comments: [Int], index: Int) {
            self.id = id
            self.createdAt = createdAt
            self.title = title
            self.url = url
            self.score = score
            self.comments = comments
            self.index = index
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try container.decode(Int.self, forKey: .id)
            self.title = try container.decode(String.self, forKey: .title)
            self.url = try container.decode(URL.self, forKey: .url)
            self.score = try container.decode(Int.self, forKey: .score)
            self.comments = try container.decode([Int].self, forKey: .comments)

            let createdAtSeconds = try container.decode(TimeInterval.self, forKey: .createdAt)
            self.createdAt = Date(timeIntervalSince1970: createdAtSeconds)
        }

        enum CodingKeys: String, CodingKey {
            case id, title, url, score
            case comments = "kids"
            case createdAt = "time"
        }
    }
}

extension Network.Model.Post {
    var numberOfComments: Int { return comments.count }
}
