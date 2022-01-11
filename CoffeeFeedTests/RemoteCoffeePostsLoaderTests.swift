//
//  RemoteCoffeePostsLoaderTests.swift
//  CoffeeFeedTests
//
//  Created by Muhammad Doukmak on 1/11/22.
//

import XCTest

class RemoteCoffeePostsLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteCoffeePostsLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://any-url.com")!

        let _ = RemoteCoffeePostsLoader(url: url, client: client)
                
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsFromURL() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteCoffeePostsLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(url, client.requestedURL)
    }

}
