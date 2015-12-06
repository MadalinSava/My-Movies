//
//  AsyncTask.swift
//  My Movies
//
//  Created by Madalin Sava on 06/12/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

protocol AsyncTask: class {
	weak var delegate: AsyncTaskDelegate? {get set}
	
	func start()
	
	// call delegate?.didCancel() in the implementation if needed
	func cancel()
}

protocol AsyncResumableTask: AsyncTask {
	func pause()
	
	func resume()
}

protocol AsyncTaskDelegate: class {
	func didCancel()
}

class URLSessionTaskAsync: AsyncResumableTask {
	
	weak var delegate: AsyncTaskDelegate?
	
	let sessionTask: NSURLSessionTask
	
	init(sessionTask: NSURLSessionTask) {
		self.sessionTask = sessionTask
	}
	
	func start() {
		sessionTask.resume()
		print("started task \(sessionTask.taskIdentifier)")
	}
	
	func cancel() {
		if sessionTask.state != .Suspended {
			
		}
		print("canceling task \(sessionTask.taskIdentifier); state \(sessionTask.state.description)")
		sessionTask.cancel()
		delegate?.didCancel()
	}
	
	func pause() {
		sessionTask.suspend()
	}
	
	func resume() {
		sessionTask.resume()
	}
}
