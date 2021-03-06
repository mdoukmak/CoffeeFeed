//
//  RemoteCoffeePostsLoader.swift
//  CoffeeFeed
//
//  Created by Muhammad Doukmak on 1/11/22.
//

import Foundation

public final class RemoteCoffeePostsLoader: CoffeePostsLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
//    public enum Result: Equatable {
//        case success([CoffeePost])
//        case failure(Error)
//    }
    
    public typealias Result = LoadPostsResult
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(CoffeePostsMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
