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



class RemoteCoffeePostsLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
                
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        
        XCTAssertEqual(url, client.requestedURL)
    }

    private func makeSUT(url: URL = URL(string: "https://any-url.com")!) -> (RemoteCoffeePostsLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCoffeePostsLoader(url: url, client: client)
        return (sut, client)
    }
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}
