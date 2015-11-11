//
//  Api.swift
//  My Movies
//
//  Created by Madalin Sava on 11/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

extension String: CustomStringConvertible {
	public var description: String {
		get {
			return self
		}
	}
}

class Api {
	
	static let instance = Api()
	
	private let baseUrl = "https://api.themoviedb.org/3"
	private let apiKey = "1ecc4c837d0fa6e033f34771e531b790"
	
	func searchMulti(text: String, page: Int, resultBlock: (NSURLResponse?, NSData?, NSError?) -> Void) {
		let query = text.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
		let stringURL = baseUrl + "/search/multi" + formatParams("query", query, "page", page, withApiKey: true)
		let req = NSURLRequest(URL: NSURL(string: stringURL)!)
		// TODO: NSURLSession
		NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue(), completionHandler: resultBlock)
	}
	
	private func formatParams(params: CustomStringConvertible..., withApiKey: Bool) -> String {
		var ret = ""
		var separator = "?"
		if withApiKey {
			ret += separator + "api_key=\(apiKey)"
			separator = "&"
		}
		
		for var i = 0; i < params.count; i += 2 {
			ret += separator + params[i].description + "=" + params[i+1].description
			separator = "&"
		}
		
		return ret
	}
}
