//
//  CoffeePost.swift
//  CoffeeFeed
//
//  Created by Muhammad Doukmak on 1/11/22.
//

import Foundation

public struct CoffeePost: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
