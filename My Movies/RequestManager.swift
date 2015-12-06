//
//  RequestManager.swift
//  My Movies
//
//  Created by Madalin Sava on 16/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

typealias RequestSuccessBlock = (NSData) -> Void
typealias ErrorBlock = (NSError) -> Void

class RequestManager {
	static let instance = RequestManager()
	
	private let foregroundSession: QueuedURLSession
	private let backgroundSession: QueuedURLSession
	private let backgroundQueue: NSOperationQueue
	
	func doForegroundRequest(stringURL: String, successBlock: RequestSuccessBlock, errorBlock: ErrorBlock? = nil) -> AsyncTask {
		return doRequestInSession(foregroundSession, stringURL: stringURL, successBlock: successBlock, errorBlock: errorBlock)
	}
	
	func doBackgroundRequest(stringURL: String, successBlock: RequestSuccessBlock, errorBlock: ErrorBlock? = nil) -> AsyncTask {
		return doRequestInSession(backgroundSession, stringURL: stringURL, successBlock: successBlock, errorBlock: errorBlock)
	}
	
	// MARK: private stuff
	private init() {
		
		backgroundQueue = NSOperationQueue()
		backgroundQueue.qualityOfService = NSQualityOfService.UserInitiated
		backgroundQueue.maxConcurrentOperationCount = 1
		// TODO: request task resume queue
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		//sessionConfig.HTTPMaximumConnectionsPerHost = 1
		sessionConfig.timeoutIntervalForRequest = 5
		//sessionConfig.timeoutIntervalForResource = 10
		
		foregroundSession = QueuedURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegateQueue: NSOperationQueue.mainQueue(), maxOngoingTasks: 10)
		
		backgroundSession = QueuedURLSession(configuration: sessionConfig, delegateQueue: backgroundQueue, maxOngoingTasks: 10)
	}
	
	private func doRequestInSession(session: QueuedURLSession, stringURL: String, successBlock: RequestSuccessBlock, errorBlock: ErrorBlock? = nil) -> AsyncTask {
		let req = NSURLRequest(URL: NSURL(string: stringURL)!)
		let task = session.startDataTaskWithRequest(req, completionHandler: requestFinished(successBlock,  errorBlock))
		return task
	}
	
	private func requestFinished(successBlock: RequestSuccessBlock, _ errorBlock: ErrorBlock?)(data: NSData?, resp: NSURLResponse?, error: NSError?) {
		//print("completed handler - ", resp)
		if data != nil && error == nil {
			successBlock(data!)
		}
		else {
			let error = error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Unknown error, but data is nil"])
			print(error.localizedDescription)
			errorBlock?(error)
		}
	}
}
