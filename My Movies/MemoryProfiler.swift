//
//  MemoryProfiler.swift
//  My Movies
//
//  Created by Madalin Sava on 08/12/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

protocol MemoryTrackable: class {
	static var classId: Int {get set}
}
/*
extension MemoryTrackable {
	var hashValue: Int { return self.dynamicType.classId}
}

func == <T: MemoryTrackable>(a: T, b: T) -> Bool {
	return false
}
*/
/*extension MemoryTrackable {
	static func setClassId() {
		classId = MemoryProfiler.instance.getNextClassId(Self)
	}
}*/

extension TaskChain: MemoryTrackable {
	static var classId: Int = MemoryProfiler.instance.getNextClassId(TaskChain)
}

extension SyncChainTask: MemoryTrackable {
	static var classId: Int = MemoryProfiler.instance.getNextClassId(SyncChainTask)
}

extension AsyncChainTask: MemoryTrackable {
	static var classId: Int = MemoryProfiler.instance.getNextClassId(AsyncChainTask)
}

extension URLSessionTaskAsync: MemoryTrackable {
	static var classId: Int = MemoryProfiler.instance.getNextClassId(URLSessionTaskAsync)
}

class MemoryProfiler {
	static let instance = MemoryProfiler()
	
	private var references = [Int: (AnyClass, Int)]()
	private var currentClassId = 1
	private let operationQueue = NSOperationQueue.mainQueue()
	
	func getNextClassId(type: AnyClass) -> Int {
		references[currentClassId] = (type, 0)
		return currentClassId++
	}
	
	func addRefCount(type: MemoryTrackable.Type) {
		operationQueue.addOperationWithBlock { [unowned self] in
			let id = type.classId
			self.references[id]!.1++
		}
	}
	
	func removeRefCount(type: MemoryTrackable.Type) {
		operationQueue.addOperationWithBlock { [unowned self] in
			let id = type.classId
			self.references[id]!.1--
		}
	}
	
	private init() {
		/*NSTimer.scheduleEvery(3.0) { [unowned self] in
			let vs = self.references//.values
			print(vs.map({ entry in
				//entry.1.0
				return "\(entry.1.0) - \(entry.1.1)"
				//return "\(entry)"
			}))
		}*/
	}
}
