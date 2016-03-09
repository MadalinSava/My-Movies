//
//  TaskChain.swift
//  My Movies
//
//  Created by Madalin Sava on 09/12/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

typealias TaskChainCompletion = (Bool) -> Void

class TaskChain: AsyncTask, ChainTaskDelegate {
	
	var currentTask: ChainTask? {
		didSet {
			currentTask?.delegate = self
		}
	}
	
	var completionBlock: TaskChainCompletion?
	
	private(set) lazy var didFinish: ChainTaskDelegateFinish? = { [unowned self] (task: ChainTask) in
		self.operationQueue.addOperationWithBlock { [weak self] in
			if self?.currentTask != nil {
				self?.currentTask = task.next
				self?.start()
			}
		}
	}
	
	private let operationQueue: NSOperationQueue
	private let taskOperationQueue: NSOperationQueue
	
	init(operationQueue: NSOperationQueue, completion: TaskChainCompletion? = nil) {
		//print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++ init chain")
		
		self.operationQueue = operationQueue
		operationQueue.maxConcurrentOperationCount = 1
		
		taskOperationQueue = NSOperationQueue()
		taskOperationQueue.maxConcurrentOperationCount = 1
		taskOperationQueue.qualityOfService = operationQueue.qualityOfService
		
		completionBlock = completion
		
		MemoryProfiler.instance.addRefCount(self.dynamicType)
	}
	
	func start() {
		if let currentTaskStart = currentTask?.start {
			taskOperationQueue.addOperationWithBlock {// [unowned self] in
				currentTaskStart()
			}
		} else {
			completionBlock?(true)
		}
	}
	
	func cancel() {
		self.operationQueue.addOperationWithBlock { [weak self] in
			self?.didFinish = nil
			guard self?.currentTask != nil else {
				return
			}
			
			let currentTaskCancel = self?.currentTask?.cancel
			self?.currentTask = nil
			let completion = self?.completionBlock
			//self.completionBlock = nil
			self?.taskOperationQueue.addOperationWithBlock {// [unowned self] in
				currentTaskCancel?()
				completion?(false)
			}
		}
	}
	
	deinit {
		//print("--------------------------------------------------------- deinit chain")
		
		MemoryProfiler.instance.removeRefCount(self.dynamicType)
	}
}

protocol ChainTask: class {
	weak var delegate: ChainTaskDelegate? {get set}
	
	var start: SimpleBlock! {get set}
	var next: ChainTask? {get set}
	
	func cancel()
}

extension ChainTask {
	func done() {
		delegate?.didFinish?(task: self)
	}
}

typealias ChainTaskDelegateFinish = (task: ChainTask) -> Void
protocol ChainTaskDelegate: class {
	var didFinish: ChainTaskDelegateFinish? {get}
}

class SyncChainTask: ChainTask {
	
	weak var delegate: ChainTaskDelegate?
	
	var start: SimpleBlock!
	var next: ChainTask? {
		didSet {
			assert(next?.start != nil, "next task needs to have a start closure")
		}
	}
	
	init() {
		//print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++ init sync")
		MemoryProfiler.instance.addRefCount(self.dynamicType)
	}
	
	deinit {
		//print("--------------------------------------------------------- deinit sync")
		MemoryProfiler.instance.removeRefCount(self.dynamicType)
	}
	
	func cancel() {
		// cannot cancel; maybe set next to nil?
	}
}

class AsyncChainTask: ChainTask {
	
	weak var delegate: ChainTaskDelegate?
	
	var start: SimpleBlock!
	var next: ChainTask? {
		didSet {
			assert(next?.start != nil, "next task needs to have a start closure")
		}
	}
	
	var task: AsyncTask?
	
	init() {
		//print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++ init Async")
		MemoryProfiler.instance.addRefCount(self.dynamicType)
	}
	
	deinit {
		//print("--------------------------------------------------------- deinit Aync")
		MemoryProfiler.instance.removeRefCount(self.dynamicType)
	}
	
	func cancel() {
		task?.cancel()
	}
}
