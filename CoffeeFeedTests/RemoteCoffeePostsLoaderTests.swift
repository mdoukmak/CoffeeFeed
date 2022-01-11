//
//  RemoteCoffeePostsLoaderTests.swift
//  CoffeeFeedTests
//
//  Created by Muhammad Doukmak on 1/11/22.
//

import XCTest

class RemoteCoffeePostsLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteCoffeePostsLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        let sut = RemoteCoffeePostsLoader()
                
        XCTAssertNil(client.requestedURL)
    }

}
