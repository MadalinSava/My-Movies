//
//  RequestManager.swift
//  My Movies
//
//  Created by Madalin Sava on 16/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

typealias SuccessBlock = (JSON) -> Void
typealias ErrorBlock = (NSError) -> Void

class RequestManager {
	static let instance = RequestManager()
	
	func doRequest(stringURL: String, successBlock: SuccessBlock, errorBlock: ErrorBlock? = nil) {
		
		let req = NSURLRequest(URL: NSURL(string: stringURL)!)
		// TODO: NSURLSession
		NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) { (resp, data, error) -> Void in
			// TODO: error handling
			if let error = error {
				errorBlock?(error)
			}
			else {
				successBlock(JSON(data: data!))
			}
		}
	}
}
