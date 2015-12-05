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

class RequestManager: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
	static let instance = RequestManager()
	
	private var foregroundSession: NSURLSession! = nil
	private var backgroundSession: NSURLSession! = nil
	private let backgroundQueue: NSOperationQueue
	private var numOngoingTasks = [NSURLSession: Int]()
	private var maxOngoingTasks = [NSURLSession: Int]()
	private var pendingTasks = [NSURLSession: [NSURLSessionTask]]()
	
	func doForegroundRequest(stringURL: String, successBlock: RequestSuccessBlock, errorBlock: ErrorBlock? = nil) {
		doRequestInSession(foregroundSession, stringURL: stringURL, successBlock: successBlock, errorBlock: errorBlock)
	}
	
	func doBackgroundRequest(stringURL: String, successBlock: RequestSuccessBlock, errorBlock: ErrorBlock? = nil) {
		doRequestInSession(backgroundSession, stringURL: stringURL, successBlock: successBlock, errorBlock: errorBlock)
	}
	
	// MARK: delegates
	
	func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
		print("completed delegate - ", task.response)
	}
	
	// MARK: private stuff
	
	private override init() {
		
		backgroundQueue = NSOperationQueue()
		backgroundQueue.qualityOfService = NSQualityOfService.UserInitiated
		backgroundQueue.maxConcurrentOperationCount = 1
		// TODO: request task resume queue
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		//sessionConfig.timeoutIntervalForRequest = 5
		//sessionConfig.timeoutIntervalForResource = 10
		
		super.init()
		
		foregroundSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
		numOngoingTasks[foregroundSession] = 0
		maxOngoingTasks[foregroundSession] = 10
		pendingTasks[foregroundSession] = [NSURLSessionTask]()
		
		backgroundSession = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: backgroundQueue)
		numOngoingTasks[backgroundSession] = 0
		maxOngoingTasks[backgroundSession] = 5
		pendingTasks[backgroundSession] = [NSURLSessionTask]()
	}
	
	private func doRequestInSession(session: NSURLSession, stringURL: String, successBlock: RequestSuccessBlock, errorBlock: ErrorBlock? = nil) {
		let req = NSURLRequest(URL: NSURL(string: stringURL)!)
		let task = session.dataTaskWithRequest(req, completionHandler: requestFinished(session, successBlock,  errorBlock))
		if numOngoingTasks[session] < maxOngoingTasks[session] {
			task.resume()
			numOngoingTasks[session] = numOngoingTasks[session]! + 1
		} else {
			pendingTasks[session]!.append(task)
		}
	}
	
	private func requestFinished(session: NSURLSession, _ successBlock: RequestSuccessBlock, _ errorBlock: ErrorBlock?)(data: NSData?, resp: NSURLResponse?, error: NSError?) {
		
		if numOngoingTasks[session] == maxOngoingTasks[session] && pendingTasks[session]!.count > 0 {
			let task = pendingTasks[session]?.removeFirst()
			task!.resume()
		} else {
			numOngoingTasks[session] = numOngoingTasks[session]! - 1
		}
		
		//print("completed handler - ", resp)
		if data != nil && error == nil {
			successBlock(data!)
		}
		else {
			errorBlock?(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Unknown error, but data is nil"]))
		}
	}
}
