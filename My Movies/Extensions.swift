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
	
	class func schedule(timeInterval: NSTimeInterval, repeats: Bool = false, target: () -> Void) -> NSTimer {
		let timer = NSTimer(timeInterval: timeInterval, target: NSBlockOperation(block: target), selector: "main", userInfo: nil, repeats: repeats)
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
/*
extension Array where Element: AnyObject {
	mutating func removeElement(element: Element) {
		for (i, el) in self.enumerate() {
			if el === element {
				removeAtIndex(i)
				break
			}
		}
		let a = findFirst { (el: Element) -> Bool in
			return el === element
		}
		/*if let index = self.indexOf(element) {
			self.removeAtIndex(index)
		}*/
	}
}*/
//extension Array where Element: AnyObject {}
/*
extension CollectionType where Self.Generator.Element: AnyObject {
	func indexOf(element: Self.Generator.Element) -> Int? {
		for (i, e) in self.enumerate() {
			if element === e {
				return i
			}
		}
		return nil
	}
	
	mutating func removeElement(element: Self.Generator.Element) {
		if let index = self.indexOf(element) {
			//remo
		}
	}
}*/
/*
extension Array {
	mutating func removeObject<U where Element: AnyObject, U: AnyObject>(object: U) {
		for (idx, objectToCompare) in enumerate() {
			if let to = objectToCompare as? U {
				if object === to {
					self.removeAtIndex(idx)
				}
			}
		}
	}
}*/

extension CollectionType {
	func findFirst(predicate: (Self.Generator.Element) -> Bool) -> Self.Generator.Element? {
		if let index = self.indexOf(predicate) {
			return self[index]
		}
		return nil
	}
}
