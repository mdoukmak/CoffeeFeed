//
//  HTTPClient.swift
//  CoffeeFeed
//
//  Created by Muhammad Doukmak on 2/21/22.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
