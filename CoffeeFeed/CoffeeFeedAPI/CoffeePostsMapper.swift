//
//  CoffeePostsMapper.swift
//  CoffeeFeed
//
//  Created by Muhammad Doukmak on 2/21/22.
//

import Foundation

final class CoffeePostsMapper {
    private static var OK_200: Int { 200 }
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [CoffeePost] {
        guard response.statusCode == OK_200 else {
            throw RemoteCoffeePostsLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data).posts.map { $0.post }
    }
    private struct Root: Decodable {
        let posts: [Post]
    }
    
    private struct Post: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL
        
        var post: CoffeePost {
            return CoffeePost(id: id, description: description, location: location, imageURL: image)
        }
    }
}
