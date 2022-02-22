//
//  CoffeeFeedAPIEndToEndTests.swift
//  CoffeeFeedAPIEndToEndTests
//
//  Created by Muhammad Doukmak on 2/21/22.
//

import XCTest
import CoffeeFeed

class CoffeeFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGetCoffeeFeedResult_matchesFixedTestAccountData() {
        let testServerURL = URL(string: "https://api.mockaroo.com/api/42ef8100?count=1&key=ab4ba600")!
        let client = URLSessionHTTPClient()
        let loader = RemoteCoffeePostsLoader(url: testServerURL, client: client)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: LoadPostsResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 15.0)
        switch receivedResult {
        case .success(let posts):
            XCTAssertEqual(posts.count, 1)
        default:
            XCTFail("Expected success")
        }
    }

}
