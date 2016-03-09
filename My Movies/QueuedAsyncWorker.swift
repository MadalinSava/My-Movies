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
	
	//private var currentTaskId??
	private var runningTasks = [AsyncTask]()
	private var queuedTasks = [AsyncTask]()
	
	init(operationQueue queue: NSOperationQueue, maxOngoingTasks: Int) {
		self.operationQueue = queue
		self.maxOngoingTasks = maxOngoingTasks
		
		operationQueue.maxConcurrentOperationCount = 1
	}
	
	func addTask(task: AsyncTask) {
		runOnOperationQueue(addTask(task))
	}
	
	func remove(predicate: (AsyncTask) -> Bool) {
		if let index = queuedTasks.indexOf(predicate) {
			queuedTasks.removeAtIndex(index)
		} else {
			let index = runningTasks.indexOf(predicate)!
			//NSLog("finished task \((runningTasks[index] as! URLSessionTaskAsync).sessionTask.taskIdentifier)")
			runningTasks.removeAtIndex(index)
			startPendingTasks()
		}
	}
	
	func remove(task: AsyncTask) {
		runOnOperationQueue { [unowned self] in
			for (i, t) in self.queuedTasks.enumerate() {
				if t === task {
					self.queuedTasks.removeAtIndex(i)
					return
				}
			}
			for (i, t) in self.runningTasks.enumerate() {
				if t === task {
					self.runningTasks.removeAtIndex(i)
					self.startPendingTasks()
					return
				}
			}
		}
	}
	
	// MARK: private
	private func addTask(task: AsyncTask)() {
		queuedTasks.push(task)
		startPendingTasks()
	}
	
	private func startPendingTasks() {
		while runningTasks.count < maxOngoingTasks && queuedTasks.count > 0 {
			let task = queuedTasks.pop()
			task.start()
			runningTasks.append(task)
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
