//
//  CoffeePostsMapper.swift
//  CoffeeFeed
//
//  Created by Muhammad Doukmak on 2/21/22.
//

import Foundation

final class CoffeePostsMapper {
    private static var OK_200: Int { 200 }
    
    private struct Root: Decodable {
        let posts: [Post]
        
        var feed: [CoffeePost] {
            return posts.map { $0.post }
        }
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
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteCoffeePostsLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            return RemoteCoffeePostsLoader.Result.failure(RemoteCoffeePostsLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }

}
