//
//  QueuedAsyncWorker.swift
//  My Movies
//
//  Created by Madalin Sava on 06/12/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

class QueuedAsyncWorker {
	var maxOngoingTasks = 0 {
		didSet {
			startPendingTasks()
		}
	}
	
	let operationQueue: NSOperationQueue
	
	private var numStarted = 0
	private var tasks = [AsyncTask]()
	
	init(operationQueue queue: NSOperationQueue, maxOngoingTasks: Int) {
		self.operationQueue = queue
		self.maxOngoingTasks = maxOngoingTasks
	}
	
	func addTask(task: AsyncTask) {
		runOnOperationQueue(addTask(task))
	}
	
	func remove(predicate: (AsyncTask) -> Bool) {
		if let asyncTask = findTask(predicate) {
			remove(asyncTask)
		} else {
			numStarted--
			startPendingTasks()
		}
	}
	
	// MARK: private
	
	private func findTask(predicate: (AsyncTask) -> Bool) -> AsyncTask? {
		return tasks.findFirst(predicate)
	}
	
	private func remove(task: AsyncTask) {
		for (i, t) in tasks.enumerate() {
			if t === task {
				tasks.removeAtIndex(i)
			}
		}
	}
	
	private func addTask(task: AsyncTask)() {
		tasks.push(task)
		startPendingTasks()
	}
	
	private func startPendingTasks() {
		while numStarted < maxOngoingTasks && tasks.count > 0 {
			let task = tasks.pop()
			task.start()
			numStarted++
		}
	}
	
	private func runOnOperationQueue(block: SimpleBlock) {
		if NSOperationQueue.currentQueue() == operationQueue {
			block()
		} else {
			operationQueue.addOperationWithBlock(block)
		}
	}
}
