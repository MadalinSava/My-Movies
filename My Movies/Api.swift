//
//  Api.swift
//  My Movies
//
//  Created by Madalin Sava on 11/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

import RxSwift

import Alamofire
import RxAlamofire
import SwiftyJSON

typealias ApiCallSuccessBlock = (JSON) -> Void
typealias ParamDictionary = [String: AnyObject]

class Api {
	
	static let instance: Api = Api()
	
	private let baseUrl = "https://api.themoviedb.org/3"
	private let apiKey = "1ecc4c837d0fa6e033f34771e531b790"
	
	func searchMultiRx(text: String, page: Int) -> Observable<JSON> {
		let query = text.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
		return Manager.sharedInstance.rx_JSON(.GET, baseUrl + "/search/multi", parameters: addApiKey(["query": query, "page": page]))
			.map { JSON($0) }
	}
	
	func requestMovieDetails(movieId: Int, success: ApiCallSuccessBlock, error: ErrorBlock? = nil) {
		let stringURL = baseUrl + "/movie/\(movieId)" + formatParams("append_to_response", "trailers,images", withApiKey: true)
		RequestManager.instance.doForegroundRequest(stringURL, successBlock: { (data) in
			success(JSON(data: data))
		}, errorBlock: error)
	}
	
	lazy var config: Observable<JSON> = {
		return Manager.sharedInstance.rx_JSON(.GET, self.baseUrl + "/configuration", parameters: self.addApiKey())
			.map { JSON($0) }
			.share()
	}()
	
	private init() {
		_ = config.subscribe()
	}
	
	private func addApiKey(params: ParamDictionary = ParamDictionary()) -> ParamDictionary {
		var apiKeyParams = params
		apiKeyParams["api_key"] = self.apiKey
		return apiKeyParams
	}
	
	private func formatParams(params: CustomStringConvertible..., withApiKey: Bool) -> String {
		var ret = ""
		var separator = "?"
		if withApiKey {
			ret += separator + "api_key=\(apiKey)"
			separator = "&"
		}
		
		for i in ((0..<params.count/2).map { $0 * 2 }) {
			ret += separator + params[i].description + "=" + params[i+1].description
			separator = "&"
		}
		
		return ret
	}
}
