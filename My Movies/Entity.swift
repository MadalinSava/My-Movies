//
//  Entity.swift
//  My Movies
//
//  Created by Madalin Sava on 22/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation
import SwiftyJSON

class Entity {
	static func createWithData(data: JSON) -> Entity! {
		switch data["media_type"] {
		case "movie":
			return Movie(data: data)
		case "tv":
			return Series()
		default:
			return nil
		}
	}
	
	init() {}
}
