//
//  Extensions.swift
//  My Movies
//
//  Created by Madalin Sava on 21/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

// MARK: String

// subscripts
extension String {
	
	subscript (i: Int) -> Character {
		return self[self.startIndex.advancedBy(i)]
	}
	
	subscript (i: Int) -> String {
		return String(self[i] as Character)
	}
	
	subscript (start: Int, var end: Int) -> String {
		let firstIndex = (start >= 0 ? startIndex : endIndex)
		let secondIndex = (end > 0 ? startIndex : endIndex)
		return substringWithRange(Range(start: firstIndex.advancedBy(start), end: secondIndex.advancedBy(end)))
	}
}

extension String {
	var lenght: Int {
		return characters.count
	}
}

extension NSTimer {
	
	/*convenience init(timeInterval: NSTimeInterval, target: () -> Void, repeats: Bool = false) {
		print("start init1")
		target()
		//self.init(timeInterval: timeInterval, target: NSBlockOperation(block: {}), selector: "main", userInfo: nil, repeats: repeats)
		self.init(timeInterval: timeInterval, target: "", selector: "main", userInfo: nil, repeats: repeats)
		print("init1 done")
	}*/
	
	/*public convenience init(timeInterval ti: NSTimeInterval, target aTarget: AnyObject, selector aSelector: Selector, repeats yesOrNo: Bool) {
		print("start init2")
		self.init(timeInterval: ti, target: aTarget, selector: aSelector, userInfo: nil, repeats: yesOrNo)
		print("init2 done")
	}*/
	
	private func start() {
		NSRunLoop.currentRunLoop().addTimer(self, forMode: NSDefaultRunLoopMode)
	}
	
	class func schedule(timeInterval: NSTimeInterval, repeats: Bool = false, target: () -> Void) -> NSTimer {
		let timer = NSTimer(timeInterval: timeInterval, target: NSBlockOperation(block: target), selector: "main", userInfo: nil, repeats: repeats)
		timer.start()
		return timer
	}
}
