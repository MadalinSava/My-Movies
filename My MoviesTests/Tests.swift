//
//  My_MoviesTests.swift
//  My MoviesTests
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import XCTest
@testable import My_Movies

class A {
	func asd() {print("wow")}
}

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
		print("asd")
		class A {
			var x: Int = 1
			
			init() {
				print("init A")
			}
			
			deinit {
				print("deinit A")
			}
		}
		
		class B {
			var a: A? = A()
		}
		
		let b = B()
		
		weak var c: A?
		c = b.a
		
		//b.a = nil
		print(c?.x) // WTF
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
	
	func testNSTimerExtension() {
		let a = A()
		
		//let block = {print("goodie")}
		//let timer = NSTimer(timeInterval: 1.0, target: self, selector: "doRequest", userInfo: nil, repeats: false)
		//let block = NSBlockOperation(block: doRequest)
		//let timer = NSTimer(timeInterval: 1.0, target: block, selector: "main", userInfo: nil, repeats: false)
		//let timer = NSTimer(timeInterval: 1.0, target: NSBlockOperation(block: {}), selector: "main", userInfo: nil, repeats: false)
		//let timer = NSTimer(timeInterval: 1.0, target: block)
		//let timer = NSTimer(timeInterval: 1.0, target: doRequest)
		
		//let _ = NSTimer(timeInterval: 1.0, target: a, selector: "asd", repeats: false)
		let _ = NSTimer.schedule(1.0, target: {print("asd")})
	}
}
