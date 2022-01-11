//
//  CoffeePostsLoader.swift
//  CoffeeFeed
//
//  Created by Muhammad Doukmak on 1/11/22.
//

import Foundation

enum LoadPostsResult {
    case success([CoffeePost])
    case error(Error)
}

protocol CoffeePostsLoader {
    func loadPosts(completion: @escaping (LoadPostsResult) -> Void)
}
