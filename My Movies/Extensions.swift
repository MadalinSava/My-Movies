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
	
	subscript (start: Int, end: Int) -> String {
		let firstIndex = (start >= 0 ? startIndex : endIndex)
		let secondIndex = (end > 0 ? startIndex : endIndex)
		return substringWithRange(firstIndex.advancedBy(start)..<secondIndex.advancedBy(end))
	}
}

extension String {
	var length: Int {
		return characters.count
	}
}

extension String: CustomStringConvertible {
	public var description: String {
		get {
			return self
		}
	}
}

extension NSTimer {
	private func start() {
		NSRunLoop.currentRunLoop().addTimer(self, forMode: NSDefaultRunLoopMode)
	}
	
	class func schedule(timeInterval: NSTimeInterval, target: () -> Void) -> NSTimer {
		let timer = NSTimer(timeInterval: timeInterval, target: NSBlockOperation(block: target), selector: #selector(NSBlockOperation.main), userInfo: nil, repeats: false)
		timer.start()
		return timer
	}
	
	class func scheduleEvery(timeInterval: NSTimeInterval, target: () -> Void) -> NSTimer {
		let timer = NSTimer(timeInterval: timeInterval, target: NSBlockOperation(block: target), selector: #selector(NSBlockOperation.main), userInfo: nil, repeats: true)
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

import RxSwift
import RxCocoa

extension ObservableType {

	/**
	Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.

	`throttle` and `debounce` are synonyms.

	- seealso: [debounce operator on reactivex.io](http://reactivex.io/documentation/operators/debounce.html)

	- parameter dueTime: Throttling duration for each element.
	- parameter scheduler: Scheduler to run the throttle timers and send events on.
	- returns: The throttled sequence.
	*/
	@warn_unused_result(message = "http://git.io/rxs.uo")
	public func throttle(dueTime: RxTimeInterval)
					-> Observable<E> {
		return throttle(dueTime, scheduler: MainScheduler.instance)
	}
}

extension UISearchBar {
	
	public var rx_cancel: ControlEvent<Void> {
		let source = self.rx_delegate.observe(#selector(UISearchBarDelegate.searchBarCancelButtonClicked))
			.map { _ -> Void in
				MainScheduler.ensureExecutingOnScheduler()
			}
			.takeUntil(rx_deallocated)
		
		return ControlEvent(events: source)
	}
}
