//
//  Extensions.swift
//  My Movies
//
//  Created by Madalin Sava on 21/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

typealias SimpleBlock = () -> Void

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
	private func start() {
		NSRunLoop.currentRunLoop().addTimer(self, forMode: NSDefaultRunLoopMode)
	}
	
	class func schedule(timeInterval: NSTimeInterval, target: () -> Void) -> NSTimer {
		let timer = NSTimer(timeInterval: timeInterval, target: NSBlockOperation(block: target), selector: "main", userInfo: nil, repeats: false)
		timer.start()
		return timer
	}
	
	class func scheduleEvery(timeInterval: NSTimeInterval, target: () -> Void) -> NSTimer {
		let timer = NSTimer(timeInterval: timeInterval, target: NSBlockOperation(block: target), selector: "main", userInfo: nil, repeats: true)
		timer.start()
		return timer
	}
}

extension NSURLSessionTaskState: CustomStringConvertible {
	public var description: String {
		switch self {
		case .Running:
			return "Running"
		case .Suspended:
			return "Suspended"
		case .Canceling:
			return "Canceling"
		case .Completed:
			return "Completed"
		}
	}
}

extension Array {
	mutating func push(element: Element) {
		self.append(element)
	}
	
	mutating func pop() -> Element {
		return self.removeFirst()
	}
}
