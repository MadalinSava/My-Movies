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

class RequestManager {//: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
	static let instance = RequestManager()
	
	private let foregroundSession: NSURLSession
	private let backgroundSession: NSURLSession
	private let backgroundQueue: NSOperationQueue
	
	func doForegroundRequest(stringURL: String, successBlock: RequestSuccessBlock, errorBlock: ErrorBlock? = nil) {
		
		let req = NSURLRequest(URL: NSURL(string: stringURL)!)
		foregroundSession.dataTaskWithRequest(req) { (data, resp, error) -> Void in
			if data != nil && error == nil {
				successBlock(data!)
			}
			else {
				errorBlock?(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Unknown error, but data is nil"]))
			}
		}.resume()
	}
	
	func doBackgroundRequest(stringURL: String, successBlock: RequestSuccessBlock, errorBlock: ErrorBlock? = nil) {
		
		let req = NSURLRequest(URL: NSURL(string: stringURL)!)
		backgroundSession.dataTaskWithRequest(req) { (data, resp, error) -> Void in
			if data != nil && error == nil {
				successBlock(data!)
			}
			else {
				errorBlock?(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Unknown error, but data is nil"]))
			}
		}.resume()
	}
	
	private init() {
		backgroundQueue = NSOperationQueue()
		foregroundSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
		backgroundSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: backgroundQueue)
	}
}
