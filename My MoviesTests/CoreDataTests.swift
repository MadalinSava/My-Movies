//
//  CoreDataTests.swift
//  My Movies
//
//  Created by Madalin Sava on 21/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import XCTest
import CoreData
@testable import My_Movies

class CoreDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
	}
	
	func testMovie() {
		let mm = CoreDataManager.instance.createEntity(ofType: ManagedMovie.self)
		mm.id = 123
		mm.title = "test title"
		
		XCTAssertEqual(mm.isInWatchList, false)
		
		let m = Movie(withManagedMovie: mm)
		XCTAssertTrue(m.toggleWatchList())
		XCTAssertEqual(m.isInWatchList, true)
		XCTAssertEqual(m.title, mm.title)
		
		let newTitle = "changed title"
		mm.title = newTitle
		XCTAssertTrue(CoreDataManager.instance.save())
		
		let m2 = Movie(withManagedMovie: mm)
		XCTAssertEqual(m2.title, mm.title)
		XCTAssertEqual(m2.title, newTitle)
		
		
		let mma = CoreDataManager.instance.getObjects(ofType: ManagedMovie.self, withPredicate: NSPredicate(format: "id == %d", 123))
		XCTAssertNotNil(mma)
		XCTAssertNotEqual(mma!.count, 0)
		let mm2 = mma![0]
		
		XCTAssertEqual(mm2.title, newTitle)
	}
}
