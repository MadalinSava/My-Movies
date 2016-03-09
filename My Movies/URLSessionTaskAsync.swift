//
//  URLSessionTaskAsync.swift
//  My Movies
//
//  Created by Madalin Sava on 07/12/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

class URLSessionTaskAsync: AsyncResumableTask {
	
	weak var delegate: AsyncTaskDelegate?
	
	let sessionTask: NSURLSessionTask
	
	init(sessionTask: NSURLSessionTask) {
		MemoryProfiler.instance.addRefCount(self.dynamicType)
		self.sessionTask = sessionTask
	}
	
	deinit {
		MemoryProfiler.instance.removeRefCount(self.dynamicType)
	}
	
	func start() {
		sessionTask.resume()
		//NSLog("started task \(sessionTask.taskIdentifier)")
		//print("started task \(sessionTask.taskIdentifier)")
	}
	
	func cancel() {
		/*if sessionTask.state == .Completed {
		
		}
		print("canceling task \(sessionTask.taskIdentifier); state \(sessionTask.state.description)")*/
		
		// the session is responsible for removing it from the queued worker; the session task is not finished immediately after calling cancel()
		sessionTask.cancel()
	}
	
	func pause() {
		sessionTask.suspend()
	}
	
	func resume() {
		sessionTask.resume()
	}
}
