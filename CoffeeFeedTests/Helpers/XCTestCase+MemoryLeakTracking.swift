//
//  XCTestCase+MemoryLeakTracking.swift
//  CoffeeFeedTests
//
//  Created by Muhammad Doukmak on 2/21/22.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated", file: file, line: line)
        }
    }
}
