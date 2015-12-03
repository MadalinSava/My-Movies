//
//  My_MoviesTests.swift
//  My MoviesTests
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import XCTest
@testable import My_Movies

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testExample() {
    }
	
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
	
	func testOperators() {
		var a: String = ""
		XCTAssertEqual(a~?, nil)
		var b: String? = ""
		b ?=~? a
	}
	
	func testStringSubscripts() {
		let str = "0123456789"
		XCTAssertEqual(str[0, 0], str)
		XCTAssertEqual(str[0, 1], "0")
		XCTAssertEqual(str[1, 1], "")
		XCTAssertEqual(str[0, -1], "012345678")
		XCTAssertEqual(str[1, 0], "123456789")
		XCTAssertEqual(str[1, -1], "12345678")
		XCTAssertEqual(str[1, 2], "1")
		XCTAssertEqual(str[-1, 0], "9")
		XCTAssertEqual(str[-1, -1], "")
		XCTAssertEqual(str[-2, -1], "8")
	}
    
}
