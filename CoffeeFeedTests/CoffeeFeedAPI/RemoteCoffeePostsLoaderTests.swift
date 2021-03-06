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
        
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversError_onNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500].enumerated()
        samples.forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let json = makePostsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }

    }
    
    func test_load_returnsError_onHTTP200_withInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJSON = Data("invalid JSON".utf8)
            
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversEmptyResult_onHTTP200_withEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = makePostsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversPostsOnHTTP200_withNonEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        let (post1, post1JSON) = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "http://any-url.com")!)
        
        
        let (post2, post2JSON) = makeItem(id: UUID(), description: "A description", location: "A location", imageURL: URL(string: "http://any-url.com")!)
        
        expect(sut, toCompleteWithResult: .success([post1, post2])) {
            let json = makePostsJSON([post1JSON, post2JSON])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_loadDoesNotDeliverResult_afterSUTHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteCoffeePostsLoader? = RemoteCoffeePostsLoader(url: url, client: client)
        var capturedResults: [RemoteCoffeePostsLoader.Result] = []
        
        sut?.load(completion: { capturedResults.append($0) })
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: makePostsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (RemoteCoffeePostsLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCoffeePostsLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func makeItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (CoffeePost, [String:Any]) {
        let item = CoffeePost(id: id, description: description, location: location, imageURL: imageURL)
        
        let itemJSON = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String: Any]()) { acc, e in
            if let value = e.value {
                acc[e.key] = value
            }
        }
        
        return (item, itemJSON)
    }
    
    private func failure(_ error: RemoteCoffeePostsLoader.Error) -> RemoteCoffeePostsLoader.Result {
        return .failure(error)
    }
    
    private func makePostsJSON(_ posts: [[String: Any]]) -> Data {
        let json = ["posts": posts]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteCoffeePostsLoader, toCompleteWithResult expectedResult: RemoteCoffeePostsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedPosts), .success(receivedPosts)):
                XCTAssertEqual(expectedPosts, receivedPosts, file: file, line: line)
            case let (.failure(expectedError as RemoteCoffeePostsLoader.Error), .failure(receivedError as RemoteCoffeePostsLoader.Error)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) received \(receivedResult)")
            }
            
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requests: [(url: URL, completion: (HTTPClientResult) -> Void)] = []
        var requestedURLs: [URL] { requests.map { $0.url } }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            requests.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            requests[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            requests[index].completion(.success(data, response))
        }
    }
}
