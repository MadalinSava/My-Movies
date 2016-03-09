//
//  OperationChainTest.swift
//  My Movies
//
//  Created by Madalin Sava on 07/12/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import XCTest
@testable import My_Movies

class OperationChainTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testAllCases() {
		let maxCase = 13
		for i in 0...maxCase { // 0 for no cancel
			NSLog("--------- RUNNING TEST CASE \(i) --------------")
			testCase(i)
		}
	}
	
	func testSpecificCase() {
		let currentCase = 13
		NSLog("--------- RUNNING TEST CASE \(currentCase) --------------")
		testCase(currentCase)
	}

	func testCase(caseIndex: Int) {
		
		let expectation = expectationWithDescription("chain task")
		
		let operationQueue = NSOperationQueue()
		
		var chain: TaskChain? = TaskChain(operationQueue: operationQueue, completion: { didSucceed in
			NSLog("chain completed with " + (didSucceed ? "SUCCESS" : "FAILURE"))
			expectation.fulfill()
		})
		
		weak var weakNext: ChainTask?
		
		let e = expectationWithDescription("delayed cancel")
		if caseIndex != 12 {
			e.fulfill()
		}
		
		var firstTask: AsyncChainTask? = AsyncChainTask()
		firstTask!.start = { [weak firstTask] in
			if caseIndex == 2 {
				chain!.cancel()
			}
			firstTask!.task = RequestManager.instance.doBackgroundRequest("http://www.google.com", successBlock:  { [weak firstTask] _ in
				
				NSLog("completed async request with success")
				
				if caseIndex == 4 {
					chain!.cancel()
				}
				let next = SyncChainTask()
				if caseIndex == 5 {
					chain!.cancel()
				}
				next.start = { [weak next] in
					if caseIndex == 10 {
						chain!.cancel()
					}
					//wait here
					var x = 0
					if caseIndex == 12 {
						NSOperationQueue().addOperationWithBlock {
							var y = 0
							NSLog("start sync delayed cancel")
							for _ in 0..<Int(1000100000) {
								y--
							}
							NSLog("do sync delayed cancel")
							chain?.cancel()
							e.fulfill()
						}
					}
					NSLog("-------------------------------start sync")
					for _ in 0..<Int(1000000000) {
						x++
					}
					NSLog("-------------------------------end sync")
					next?.done()
					if caseIndex == 11 {
						chain!.cancel()
					}
				}
				if caseIndex == 6 {
					chain!.cancel()
				}
				weakNext = next
				if caseIndex == 7 {
					chain!.cancel()
				}
				firstTask?.next = next
				if caseIndex == 8 {
					chain!.cancel()
				}
				firstTask?.done()
				if caseIndex == 9 {
					chain!.cancel()
				}
			}, errorBlock: { [weak firstTask] _ in
				NSLog("completed async request with error")
				if caseIndex == 12 {
					e.fulfill()
				}
				
				if caseIndex == 4 {
					chain!.cancel()
				}
				firstTask?.done()
				if caseIndex == 5 {
					chain!.cancel()
				}
			})
			if caseIndex == 3 {
				chain!.cancel()
			}
			
			NSLog("started async request")
			
			var x = 0
			if caseIndex == 13 {
				NSOperationQueue().addOperationWithBlock {
					NSLog("start Async delayed cancel")
					for _ in 0..<Int(10000000) {
						x--
					}
					NSLog("do Async delayed cancel")
					chain?.cancel()
				}
			}
		}
		
		chain!.currentTask = firstTask
		weak var firstTaskRef = firstTask
		firstTask = nil
		
		chain!.start()
		if caseIndex == 1 {
			chain!.cancel()
		}
		
		waitForExpectationsWithTimeout(100.0) { (error) -> Void in
			XCTAssertNil(chain!.currentTask, "the chain's current task should be nil")
			if error != nil {
				print(error?.localizedDescription)
			}
		}
		
		
		chain = nil
		
		let cleanupExpectation = self.expectationWithDescription("cleanup")
		operationQueue.addOperationWithBlock {
			cleanupExpectation.fulfill()
		}
		
		self.waitForExpectationsWithTimeout(0.01, handler: { (error) -> Void in
			XCTAssertNil(firstTaskRef, "first task should be nil")
			XCTAssertNil(weakNext, "second task should be nil")
			if error != nil {
				print(error?.localizedDescription)
			}
		})
    }
/*
    func testPerformanceExample() {
        // This is an example of a performance test case.
		self.measureBlock {
			var x = 0
			for _ in 0..<Int(1000000000) {
				x++
			}
        }
    }*/

}
