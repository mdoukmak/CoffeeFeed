//
//  CoffeePostLoader.swift
//  CoffeeFeed
//
//  Created by Muhammad Doukmak on 1/11/22.
//

import Foundation

enum LoadFeedResult {
    case success([CoffeePost])
    case error(Error)
}

protocol CoffeePostLoader {
    func loadPosts(completion: @escaping (LoadFeedResult) -> Void)
}
