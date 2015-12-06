//
//  QueuedURLSession.swift
//  My Movies
//
//  Created by Madalin Sava on 06/12/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

typealias TaskCompletionBlock = (NSData?, NSURLResponse?, NSError?) -> Void

private struct TaskInfo {
	var data: NSMutableData?
	var response: NSURLResponse?
	var completionHandler: TaskCompletionBlock
	
	init(completionHandler: TaskCompletionBlock) {
		self.completionHandler = completionHandler
	}
	
	mutating func appendData(data: NSData) {
		guard let selfData = self.data else {
			self.data = NSMutableData(data: data)
			return
		}
		selfData.appendData(data)
	}
}

class QueuedURLSession: NSObject, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {
	
	var maxOngoingTasks = 0 {
		didSet {
			worker.maxOngoingTasks = maxOngoingTasks
		}
	}
	
	private var session: NSURLSession! = nil
	private let worker: QueuedAsyncWorker
	
	private var tasksInfo = [NSURLSessionTask: TaskInfo]()
	
	init(configuration: NSURLSessionConfiguration, delegateQueue queue: NSOperationQueue, maxOngoingTasks: Int) {
		self.maxOngoingTasks = maxOngoingTasks
		worker = QueuedAsyncWorker(operationQueue: queue, maxOngoingTasks: maxOngoingTasks)
		
		super.init()
		
		session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: queue)
	}
	
	func dataTaskWithRequest(request: NSURLRequest, completionHandler: TaskCompletionBlock) -> NSURLSessionDataTask {
		let task = session.dataTaskWithRequest(request)
		session.delegateQueue.addOperationWithBlock { [unowned self] in
			assert(NSOperationQueue.currentQueue() == self.session.delegateQueue)
			self.tasksInfo[task] = TaskInfo(completionHandler: completionHandler)
		}
		return task
	}
	
	func startDataTaskWithRequest(request: NSURLRequest, completionHandler: TaskCompletionBlock) -> URLSessionTaskAsync {
		let task = dataTaskWithRequest(request, completionHandler: completionHandler)
		let asyncTask = URLSessionTaskAsync(sessionTask: task)
		worker.addTask(asyncTask)
		return asyncTask
	}
	
	// MARK: delegates
	func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
		// prepare for data
		//print("response for task \(dataTask.taskIdentifier)")
		assert(NSOperationQueue.currentQueue() == session.delegateQueue)
		tasksInfo[dataTask]!.response = response
		completionHandler(.Allow)
	}
	
	func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
		// update data
		//print("data for task \(dataTask.taskIdentifier)")
		assert(NSOperationQueue.currentQueue() == session.delegateQueue)
		tasksInfo[dataTask]!.appendData(data)
	}
	
	func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
		// send completion, cleanup, update worker
		
		assert(NSOperationQueue.currentQueue() == session.delegateQueue)
		//print("completion for task \(task.taskIdentifier); state \(task.state.description)")
		if let taskInfo = tasksInfo[task] {
			taskInfo.completionHandler(taskInfo.data, taskInfo.response, error)
			tasksInfo.removeValueForKey(task)
			//tasksInfo[task] = nil
		}
		
		worker.remove{ (asyncTask: AsyncTask) in
			return (asyncTask as! URLSessionTaskAsync).sessionTask == task
		}
	}
	
	// MARK: private
}
