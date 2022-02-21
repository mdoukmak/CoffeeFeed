//
//  RemoteCoffeePostsLoader.swift
//  CoffeeFeed
//
//  Created by Muhammad Doukmak on 1/11/22.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public final class RemoteCoffeePostsLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([CoffeePost])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                do {
                    let posts = try CoffeePostsMapper.map(data, response: response)
                    completion(.success(posts))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class CoffeePostsMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [CoffeePost] {
        guard response.statusCode == 200 else {
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
