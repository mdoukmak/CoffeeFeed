//
//  RemoteCoffeePostsLoaderTests.swift
//  CoffeeFeedTests
//
//  Created by Muhammad Doukmak on 1/11/22.
//

import XCTest
import CoffeeFeed


class RemoteCoffeePostsLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
                
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversError_onClientError() {
        let (sut, client) = makeSUT()
        
        var capturedErrors: [RemoteCoffeePostsLoader.Error] = []
        sut.load { capturedErrors.append($0) }

        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversError_onNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500].enumerated()
        samples.forEach { index, code in
            var capturedErrors: [RemoteCoffeePostsLoader.Error] = []
            sut.load { capturedErrors.append($0) }
        
            client.complete(withStatusCode: code, at: index)
        
            XCTAssertEqual(capturedErrors, [.invalidData])
        }

    }

    private func makeSUT(url: URL = URL(string: "https://any-url.com")!) -> (RemoteCoffeePostsLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCoffeePostsLoader(url: url, client: client)
        return (sut, client)
    }
    private class HTTPClientSpy: HTTPClient {
        var requests: [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)] = []
        var requestedURLs: [URL] { requests.map { $0.url } }
        
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            requests.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            requests[index].completion(error, nil)
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )
            requests[index].completion(nil, response)
        }
    }
}
