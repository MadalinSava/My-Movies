//
//  SearchResult.swift
//  My Movies
//
//  Created by Madalin Sava on 10/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

class SearchResult {
	let name: String!
	let thumbnailPath: String?
	
	init?(data: JSON) {
		switch data["media_type"] {
		case "movie":
			var tempName = data["title"].stringValue
			if let releaseDate = data["release_date"].string {
				tempName += " (\(releaseDate.substringToIndex(releaseDate.startIndex.advancedBy(4))))"
			}
			name = tempName
			thumbnailPath = data["poster_path"].string
		case "person":
			name = data["name"].stringValue
			thumbnailPath = data["profile_path"].string
		case "tv":
			name = data["name"].stringValue + " (series)"
			thumbnailPath = data["poster_path"].string
		default:
			name = nil
			thumbnailPath = nil
			print("unsupported result")
			//assertionFailure("unsupported result")
			return nil
		}
	}
}
