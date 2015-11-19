//
//  Movie.swift
//  My Movies
//
//  Created by Madalin Sava on 16/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

class Movie {
	
	let title: String
	let id: Int
	let releaseDate: String?
	
	private(set) var posterPath: String? = nil
	private(set) var overview: String? = nil
	private(set) var youtubeTrailer: String? = nil
	private(set) var runTime: Int? = nil
	private(set) var genreList: [String] = [String]()
	
	var releaseYear: String? {
		get {
			guard let date = releaseDate else {
				return nil
			}
			return date.substringToIndex(date.startIndex.advancedBy(4))
		}
	}
	
	init(data: JSON) {
		
		title = data["title"].stringValue
		id = data["id"].intValue
		releaseDate = data["release_date"].string~?
		
		addData(data)
	}
	
	func addData(data: JSON) {
		//print(data)
		
		posterPath ?=~? data["poster_path"].string
		overview ?=~? data["overview"].string
		runTime ?=~? data["runtime"].int
		
		for genre in data["genres"].arrayValue {
			genreList.append(genre["name"].stringValue)
		}
		
		//let youtubeTrailers = data["trailers"]["youtube"].arrayValue
		//if youtubeTrailers.count > 0 {
		//youtubeTrailer = youtubeTrailers[0]["source"].string
		youtubeTrailer ?=~? data["trailers"]["youtube"][0]["source"].string
		//}
		//else {
		//youtubeTrailer = nil
		//}
	}
}
