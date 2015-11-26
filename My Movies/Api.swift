//
//  Api.swift
//  My Movies
//
//  Created by Madalin Sava on 11/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

class Api {
	
	static let instance: Api = Api()
	
	private let baseUrl = "https://api.themoviedb.org/3"
	private let apiKey = "1ecc4c837d0fa6e033f34771e531b790"
	
	private var configuration: JSON! = nil
	private var configurationCallbacks = [SuccessBlock]()
	
	func searchMulti(text: String, page: Int, success: SuccessBlock, error: ErrorBlock? = nil) {
		let query = text.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
		let stringURL = baseUrl + "/search/multi" + formatParams("query", query, "page", page, withApiKey: true)
		RequestManager.instance.doRequest(stringURL, successBlock: success, errorBlock: error)
	}
	
	func requestMovieDetails(movieId: Int, success: SuccessBlock, error: ErrorBlock? = nil) {
		let stringURL = baseUrl + "/movie/\(movieId)" + formatParams("append_to_response", "trailers,images", withApiKey: true)
		RequestManager.instance.doRequest(stringURL, successBlock: success, errorBlock: error)
	}
	
	func getConfiguration(success: SuccessBlock) {
		if configuration != nil {
			success(configuration)
		}
		else {
			print("wait")
			configurationCallbacks.append(success)
		}
	}
	
	private init() {
		requestConfiguration()
	}
	
	private func requestConfiguration() {
		let stringURL = baseUrl + "/configuration" + formatParams(withApiKey: true)
		RequestManager.instance.doRequest(stringURL, successBlock: { [unowned self] (config) in
			self.configuration = config
			for callback in self.configurationCallbacks {
				callback(config)
			}
			self.configurationCallbacks.removeAll()
			}, errorBlock: {
			(error) in
			print(error.localizedDescription)
		})
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
