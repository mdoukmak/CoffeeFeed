//
//  CoffeePostsLoader.swift
//  CoffeeFeed
//
//  Created by Muhammad Doukmak on 1/11/22.
//

import Foundation

public enum LoadPostsResult {
    case success([CoffeePost])
    case failure(Error)
}

public protocol CoffeePostsLoader {
    func load(completion: @escaping (LoadPostsResult) -> Void)
}
